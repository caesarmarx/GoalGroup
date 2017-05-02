/*
 * Copyright (c) 2011-2012 Matthijs Hollemans
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

#import "MHTabBarController.h"
#import "SettingsViewController.h"
#import "CreatingClubController.h"
#import "MakingChallengeController.h"
#import "MakingDiscussController.h"
#import "ClubRoomViewController.h"
#import "DiscussRoomManager.h"
#import "UIColor+User.h"
#import "PlayerDetailController.h"
#import "Common.h"

static const NSInteger TagOffset = 1000;

@implementation MHTabBarController
{
	UIView *contentContainerView;
    UIView *tabLine;
    UIView *tabButtonsContainerView;

}

@synthesize delegates;

- (id)initWithModeTop
{
    self = [super init];
    if (self)
        modeTop = YES;
    return self;
}

- (id)initWithSocialMode
{
    self = [super init];
    if (self){
        modeTop = YES;
        socialMode = YES;
    }
    return self;
}
- (void)viewDidLoad
{
	[super viewDidLoad];

	self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

    if (modeTop)
    {
        float y = 0; //IOS_VERSION < 7.0 ? -20.f : 0;
        // Position on Top
        CGRect rect = CGRectMake(0.0f, y, self.view.bounds.size.width, self.tabBarHeight);
        tabButtonsContainerView = [[UIView alloc] initWithFrame:rect];
        tabButtonsContainerView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        tabButtonsContainerView.backgroundColor = [UIColor ggaPinkLightColor];
        [self.view addSubview:tabButtonsContainerView];
        
        rect.origin.y = self.tabBarHeight + y;
        rect.size.height = self.view.bounds.size.height - self.tabBarHeight;
        contentContainerView = [[UIView alloc] initWithFrame:rect];
        contentContainerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self.view addSubview:contentContainerView];
        
        [self reloadTabButtons];
    }
    else
    {
        // Position on Bottom
#ifdef IOS_VERSION_7
        if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1) {
            self.edgesForExtendedLayout = UIRectEdgeNone;
            self.extendedLayoutIncludesOpaqueBars = NO;
            self.automaticallyAdjustsScrollViewInsets = NO;
        }
#endif
        
        CGRect rect = CGRectMake(0.0f, self.view.bounds.size.height - self.tabBarHeight - self.navigationController.navigationBar.bounds.size.height,
                                 self.view.bounds.size.width, self.tabBarHeight);
#ifdef IOS_VERSION_7
        if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1) {
            rect.origin.y -= [[UIApplication sharedApplication] statusBarFrame].size.height;
        }
#endif
        tabButtonsContainerView = [[UIView alloc] initWithFrame:rect];
        tabButtonsContainerView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [self.view addSubview:tabButtonsContainerView];
        
        rect = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height - self.navigationController.navigationBar.bounds.size.height);
        contentContainerView = [[UIView alloc] initWithFrame:rect];
        contentContainerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        [self.view addSubview:contentContainerView];
        [self.view setBackgroundColor:[UIColor whiteColor]];
        [self reloadTabButtons];
        
        tabLine = [[UIView alloc] initWithFrame:CGRectMake(tabButtonsContainerView.frame.origin.x, tabButtonsContainerView.frame.origin.y, tabButtonsContainerView.frame.size.width, 0.6)];
        [tabLine setBackgroundColor:[UIColor colorWithRed:160/255.0f green:160/255.0f blue:160
                                     /255.0f alpha:1.0f]];
        [self.view addSubview:tabLine];
        
        if (self.delegates == nil) {
            self.delegates = [[NSMutableArray alloc] init];
        }
        
        [self.navigationItem setHidesBackButton:YES animated:NO];
    }
    
}

- (void)viewDidAppear:(BOOL)animated
{
    ggaAppDelegate *appDelegate = APP_DELEGATE;
    if (uidForRemoteNotification != -1)
    {
        if ([[ClubManager sharedInstance] checkMyClub:roomIDForRemoteNotification])
        {
            //구락부마당채팅
            ClubRoomViewController *clubRoomVC = [[ClubRoomViewController alloc] initWithNibName:@"ClubRoomViewController" clubID:roomIDForRemoteNotification bundle:nil];
            [appDelegate.ggaNav pushViewController:clubRoomVC animated:YES];
        }
        else
        {
            //상의마당채팅
            ConferenceListRecord *record = nil;
            for (DiscussRoomItem *item in [[DiscussRoomManager sharedInstance] getChatRooms])
            {
                int nRoomID = [item intWithRoomID];
                
                if (roomIDForRemoteNotification != nRoomID) continue;
                
                int team1 = [item intWithSendClubID];
                int team2 = [item intWithRecvClubID];
                int nGameType = [item intWithGameType];
                int nGameID = [item intWithGameID];
                int unread = [item unreadCount];
                int players = [item intWithGamePlayers];
                NSString *teamStr1 = [item stringWithSendName];
                NSString *teamStr2 = [item stringWithRecvName];
                NSString *gameDate = [item stringWithGameDate];
                NSString *img1 = [item stringWithSendImageUrl];
                NSString *img2 = [item stringWithRecvImageUrl];
                int challState = [item intWithChallState];
                int gameState = [item intWithGameState];
                NSString *lastChatInfo = [item lastChatMsgMan];
                
                //상의마당정보얻기
                ConferenceListRecord *record = [[ConferenceListRecord alloc] initWithID:nRoomID sendImage:img1 recvImage:img2 dateTime:gameDate gameType:nGameType gameId:nGameID team1:team1 team2:team2 teamStr1:teamStr1 teamStr2:teamStr2 unread:unread players:players challState:challState gameState:gameState lastChatInfo:lastChatInfo];
                
            }
            
            if (record != nil)
            {
                
                ClubRoomViewController *vc = [[ClubRoomViewController alloc] initWithNibName:@"ClubRoomViewController" conference:record];
                [appDelegate.ggaNav pushViewController:vc animated:YES];
            }
        }
        
        uidForRemoteNotification = -1;
    }
    if (userRegisteredSuccessfully)
    {
        [appDelegate.ggaNav pushViewController:[[PlayerDetailController alloc] initWithPlayerID:UID showInviteButton:NO] animated:YES];
        userRegisteredSuccessfully = NO;
    }
    
    if (savedNotification != nil)
        [APP_DELEGATE checkNotification:savedNotification];
}

- (void)viewWillLayoutSubviews
{
	[super viewWillLayoutSubviews];
	[self layoutTabButtons];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	// Only rotate if all child view controllers agree on the new orientation.
	for (UIViewController *viewController in self.viewControllers)
	{
		if (![viewController shouldAutorotateToInterfaceOrientation:interfaceOrientation])
			return NO;
	}
	return YES;
}

- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];

	if ([self isViewLoaded] && self.view.window == nil)
	{
		self.view = nil;
		tabButtonsContainerView = nil;
		contentContainerView = nil;
	}
}

- (void)addDelegate:(id<MHTabBarControllerDelegate>)delegate
{
    if (self.delegates == nil) {
        self.delegates = [[NSMutableArray alloc] init];
    }
    [self.delegates addObject:delegate];
}

- (void)reloadTabButtons
{
	[self removeTabButtons];
	[self addTabButtons];

	// Force redraw of the previously active tab.
	NSUInteger lastIndex = _selectedIndex;
	_selectedIndex = NSNotFound;
	self.selectedIndex = lastIndex;
}

- (void)addTabButtons
{
	NSUInteger index = 0;
	for (UIViewController *viewController in self.viewControllers)
	{
		UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
		button.tag = TagOffset + index;
		button.titleLabel.font = [UIFont boldSystemFontOfSize:self.tabButtonFontSize];

        NSString *tmp = viewController.tabBarItem.title;
        if ([tmp length] == 4)
            tmp = LANGUAGE(@"challenge");
        
		[button setTitle: tmp forState:UIControlStateNormal];
        [button setImage:viewController.tabBarItem.image forState:UIControlStateNormal];
		[button setBackgroundColor:self.tabButtonBackgroundColor];
        [button setTitleColor:self.tabButtonTitleColor forState:UIControlStateNormal];
        button.adjustsImageWhenHighlighted = NO;
		[button addTarget:self action:@selector(tabButtonPressed:) forControlEvents:UIControlEventTouchDown];

		[tabButtonsContainerView addSubview:button];

		++index;
	}
    
    [self.view bringSubviewToFront:tabButtonsContainerView];
    [self.view bringSubviewToFront:tabLine];
}

- (void)removeTabButtons
{
	while ([tabButtonsContainerView.subviews count] > 0)
	{
		[[tabButtonsContainerView.subviews lastObject] removeFromSuperview];
	}
}

- (void)layoutTabButtons
{
	NSUInteger index = 0;
	NSUInteger count = [self.viewControllers count];
	CGRect rect = CGRectMake(0.0f, 0.0f, floorf(self.view.bounds.size.width / count), self.tabBarHeight);
	NSArray *buttons = [tabButtonsContainerView subviews];
	for (UIButton *button in buttons)
	{
		button.frame = rect;
		rect.origin.x += rect.size.width;
        int imageWidth = button.imageView.bounds.size.width;
        int imageHeight = button.imageView.bounds.size.height;
        int titleWidth = button.titleLabel.bounds.size.width;
        int titleHeight = button.titleLabel.bounds.size.height;
        [button setTitleEdgeInsets:UIEdgeInsetsMake(imageHeight, -imageWidth, 0, 0)];
        [button setImageEdgeInsets:UIEdgeInsetsMake(0, 0, titleHeight, -titleWidth)];
		++index;
	}
}

- (void)setViewControllers:(NSArray *)newViewControllers
{
	UIViewController *oldSelectedViewController = self.selectedViewController;

	// Remove the old child view controllers.
	for (UIViewController *viewController in _viewControllers)
	{
		[viewController willMoveToParentViewController:nil];
		[viewController removeFromParentViewController];
	}

	_viewControllers = [newViewControllers copy];

	// This follows the same rules as UITabBarController for trying to
	// re-select the previously selected view controller.
	NSUInteger newIndex = [_viewControllers indexOfObject:oldSelectedViewController];
	if (newIndex != NSNotFound)
		_selectedIndex = newIndex;
	else if (newIndex < [_viewControllers count])
		_selectedIndex = newIndex;
	else
		_selectedIndex = 0;

	// Add the new child view controllers.
	for (UIViewController *viewController in _viewControllers)
	{
		[self addChildViewController:viewController];
		[viewController didMoveToParentViewController:self];
	}

	if ([self isViewLoaded])
		[self reloadTabButtons];
}

- (void)setSelectedIndex:(NSUInteger)newSelectedIndex
{
	[self setSelectedIndex:newSelectedIndex animated:NO];
}

- (void)setSelectedIndex:(NSUInteger)newSelectedIndex animated:(BOOL)animated
{
	if ([self.delegates count] > 0)
    {
        UIViewController *toViewController = (self.viewControllers)[newSelectedIndex];
        
        for (id delegate in self.delegates) {
            if ([delegate respondsToSelector:@selector(mh_tabBarController:shouldSelectViewController:atIndex:)]) {
                [delegate mh_tabBarController:self shouldSelectViewController:toViewController atIndex:newSelectedIndex];
            }
        }
    }
    
	if (![self isViewLoaded])
	{
		_selectedIndex = newSelectedIndex;
	}
	else if (_selectedIndex != newSelectedIndex)
	{
		UIViewController *fromViewController;
		UIViewController *toViewController;
        
		if (_selectedIndex != NSNotFound)
		{
			UIButton *fromButton = (UIButton *)[tabButtonsContainerView viewWithTag:TagOffset + _selectedIndex];
			[self deselectTabButton:fromButton];
			fromViewController = self.selectedViewController;
		}
        
		NSUInteger oldSelectedIndex = _selectedIndex;
		_selectedIndex = newSelectedIndex;
        
		UIButton *toButton;
		if (_selectedIndex != NSNotFound)
		{
			toButton = (UIButton *)[tabButtonsContainerView viewWithTag:TagOffset + _selectedIndex];
			[self selectTabButton:toButton];
			toViewController = self.selectedViewController;
		}
        
        
		if (toViewController == nil)  // don't animate
		{
			[fromViewController.view removeFromSuperview];
		}
		else if (fromViewController == nil)  // don't animate
		{
			toViewController.view.frame = contentContainerView.frame;
			[self.view addSubview:toViewController.view];
            
			//if ([self.delegate respondsToSelector:@selector(mh_tabBarController:didSelectViewController:atIndex:)])
			//	[self.delegate mh_tabBarController:self didSelectViewController:toViewController atIndex:newSelectedIndex];
		}
		else if (animated)
		{
			CGRect rect = contentContainerView.frame;
			if (oldSelectedIndex < newSelectedIndex)
				rect.origin.x = rect.size.width;
			else
				rect.origin.x = -rect.size.width;
            
			toViewController.view.frame = rect;
			tabButtonsContainerView.userInteractionEnabled = NO;
            
			[self transitionFromViewController:fromViewController
				toViewController:toViewController
				duration:0.3f
				options:UIViewAnimationOptionLayoutSubviews | UIViewAnimationOptionCurveEaseOut
				animations:^
				{
					CGRect rect = fromViewController.view.frame;
					if (oldSelectedIndex < newSelectedIndex)
						rect.origin.x = -rect.size.width;
					else
						rect.origin.x = rect.size.width;

					fromViewController.view.frame = rect;
					toViewController.view.frame = contentContainerView.frame;
				}
				completion:^(BOOL finished)
				{
					tabButtonsContainerView.userInteractionEnabled = YES;
					if ([self.delegates count] > 0) {
						UIViewController *toViewController = (self.viewControllers)[newSelectedIndex];
						
						for (id delegate in self.delegates) {
							if ([delegate respondsToSelector:@selector(mh_tabBarController:didSelectViewController:atIndex:)]) {
								[delegate mh_tabBarController:self didSelectViewController:toViewController atIndex:newSelectedIndex];
							}
						}
					}
				}
			];
		}
		else  // not animated
		{
			[fromViewController.view removeFromSuperview];

			toViewController.view.frame = contentContainerView.bounds;
			[contentContainerView addSubview:toViewController.view];
            
			if ([self.delegates count] > 0) {
				UIViewController *toViewController = (self.viewControllers)[newSelectedIndex];
				for (id delegate in self.delegates) {
					if ([delegate respondsToSelector:@selector(mh_tabBarController:didSelectViewController:atIndex:)]) {
						[delegate mh_tabBarController:self didSelectViewController:toViewController atIndex:newSelectedIndex];
					}
				}
			}
		}
        
		[self updateNavigationItems];
		
		[self.view bringSubviewToFront:tabButtonsContainerView];
		[self.view bringSubviewToFront:tabLine];
	}
}

- (void)updateNavigationItems
{
//    self.navigationItem.rightBarButtonItem = self.selectedViewController.navigationItem.rightBarButtonItem;
//    self.navigationItem.leftBarButtonItem = self.selectedViewController.navigationItem.leftBarButtonItem;
}

- (UIViewController *)selectedViewController
{
	if (self.selectedIndex != NSNotFound)
		return (self.viewControllers)[self.selectedIndex];
	else
		return nil;
}

- (void)setSelectedViewController:(UIViewController *)newSelectedViewController
{
	[self setSelectedViewController:newSelectedViewController animated:NO];
}

- (void)setSelectedViewController:(UIViewController *)newSelectedViewController animated:(BOOL)animated
{
	NSUInteger index = [self.viewControllers indexOfObject:newSelectedViewController];
	if (index != NSNotFound)
		[self setSelectedIndex:index animated:animated];
}

- (void)tabButtonPressed:(UIButton *)sender
{
	[self setSelectedIndex:sender.tag - TagOffset animated:YES];
}

#pragma mark - Change these methods to customize the look of the buttons

- (void)selectTabButton:(UIButton *)button
{
    [self setTitle:self.selectedViewController.title];
    [button setTitleColor:self.tabButtonSelTitleColor forState:UIControlStateNormal];
    [button setBackgroundColor:self.tabButtonSelBackgroundColor];
    
    if (modeTop)
        return;
    switch (self.selectedIndex)
    {
        case 0:
            [button setImage: IMAGE(@"challenge_select") forState:UIControlStateNormal];
            break;
            
        case 1:
            [button setImage: IMAGE(@"discuss_select") forState:UIControlStateNormal];
            break;
            
        case 2:
            [button setImage: IMAGE(@"club_select") forState:UIControlStateNormal];
            break;
            
        case 3:
            [button setImage: IMAGE(@"search_select") forState:UIControlStateNormal];
            break;
            
        default:
            break;
    }

}

- (void)deselectTabButton:(UIButton *)button
{
    [button setTitleColor:self.tabButtonTitleColor forState:UIControlStateNormal];
    [button setBackgroundColor:self.tabButtonBackgroundColor];

    if (modeTop)
        return;
    switch (self.selectedIndex)
    {
        case 0:
            [button setImage: [UIImage imageNamed:@"challenge_normal"] forState:UIControlStateNormal];
            break;
            
        case 1:
            [button setImage: [UIImage imageNamed:@"discuss_normal"] forState:UIControlStateNormal];
            break;
            
        case 2:
            [button setImage: [UIImage imageNamed:@"club_normal"] forState:UIControlStateNormal];
            break;
            
        case 3:
            [button setImage: [UIImage imageNamed:@"search_normal"] forState:UIControlStateNormal];
            break;
            
        default:
            break;
    }

}

- (void)rightSwiped:(UISwipeGestureRecognizer *)gesture
{
}

- (void)leftSwiped:(UISwipeGestureRecognizer *)gesture
{
}

#pragma MakingDiscussControllerDelegate
- (void)makingDiscussSuccess
{
    [Common BackToPage];
    [self setSelectedIndex:1];
}
@end
