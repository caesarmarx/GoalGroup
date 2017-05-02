//
//  ClubMemberController.m
//  GoalGroup
//
//  Created by KCHN on 2/25/15.
//  Copyright (c) 2015 KCHN. All rights reserved.
//

#import "ClubMemberController.h"
#import "PlayerListRecord.h"
#import "MemberItemView.h"
#import "PlayerDetailController.h"
#import "ClubMemberListController.h"
#import "DiscussRoomManager.h"
#import "NSPosition.h"
#import "Common.h"

@interface ClubMemberController ()
{
    NSInteger backgroundHeight;
}
@end

static NSInteger kItemViewIndex = 100;

@implementation ClubMemberController

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

+ (ClubMemberController *)sharedInstance
{
    @synchronized(self)
    {
        if (gClubMemberController == nil)
            gClubMemberController = [[ClubMemberController alloc] init];
    }
    return gClubMemberController;
}

- (id)initWithClubID:(int)clubid
{
    self = [super init];
    nMineClubID = clubid;
    self.title = [NSString stringWithFormat:@"%@%@", [[ClubManager sharedInstance] stringClubNameWithID:clubid], LANGUAGE(@"club_menu_first")];
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    dropedMembers = [[NSMutableDictionary alloc] init];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self configureUI];
    
    dragDropManager = [OBDragDropManager sharedManager];
    
    [self clearContents];
    [[HttpManager sharedInstance] browseMemberListWithDelegate:self withClubID:[NSArray arrayWithObject:[NSNumber numberWithInt:nMineClubID]]];
}

- (void) configureUI
{
    UIView *backButtonRegion = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 48, 24)];
    UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(8, -4, 30, 30)]; //Modified By Boss.2015/05/02
    [backButton setImage:[UIImage imageNamed:@"move_forward"] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(backPressed:) forControlEvents:UIControlEventTouchDown];
    [backButtonRegion addSubview:backButton];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButtonRegion];
    self.view.backgroundColor = [UIColor whiteColor];
    
#ifdef IOS_VERSION_7
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)]) //iOS7
        self.edgesForExtendedLayout = UIRectEdgeNone;
#endif
    
    if ([[ClubManager sharedInstance] checkAdminClub:nMineClubID])
    {
        UIView *saveButtonRegion = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 48, 37)];
        UIButton *saveButton = [[UIButton alloc] initWithFrame:CGRectMake(18, 0, 24, 22)]; //Modified By Boss.2015/05/13
        [saveButton setImage:IMAGE(@"save_ico") forState:UIControlStateNormal];
        [saveButton setTag:1001];
        saveButton.titleLabel.font = FONT(14.f);
        [saveButton addTarget:self action:@selector(savePressed:) forControlEvents:UIControlEventTouchDown];
        [saveButtonRegion addSubview:saveButton];
        
        UIButton *lblButton = [[UIButton alloc] initWithFrame:CGRectMake(18, 23, 24, 15)];
        [lblButton setTitle:LANGUAGE(@"lbl_club_detail_save") forState:UIControlStateNormal];
        lblButton.titleLabel.textColor = [UIColor whiteColor];
        lblButton.titleLabel.font = FONT(12.f);
        [lblButton addTarget:self action:@selector(savePressed:) forControlEvents:UIControlEventTouchDown];
        [saveButtonRegion addSubview:lblButton];
        
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:saveButtonRegion];
    }
    
    
    backgroundHeight = SCREEN_HEIGHT - 64;

    //background
    UIImageView *yard = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, backgroundHeight)];
    yard.image = IMAGE(@"club_member_bg");
    [self.view addSubview:yard];
    
    //subViews
    CGRect viewFrame = self.view.frame;
    int subviewWidth = viewFrame.size.width;
    int subviewHeight = (SCREEN_HEIGHT - 64) / 5; //viewFrame.size.height / 5;
    
    forwardViewContents = [[NSMutableArray alloc] init];
    middleViewContents = [[NSMutableArray alloc] init];
    defenceViewContents = [[NSMutableArray alloc] init];
    keeperViewContents = [[NSMutableArray alloc] init];
    
    UILabel *label;
    CGRect frame;
    UIView *backView;
    
    //background
    for (int i=0; i<2; i++)
    {
        frame = CGRectMake(0, subviewHeight * (i * 2 + 1), subviewWidth, subviewHeight);
        backView = [[UIView alloc] initWithFrame:frame];
        backView.backgroundColor = [UIColor ggaWhiteColor];
        backView.alpha = 0.2f;
        [self.view addSubview:backView];
    }
    
    //detail view
    if (captainView && captainView.record)
    {
        
    }
    else
    {
    	captainView = [[MemberItemView alloc] initWithFrame:CGRectMake(subviewWidth / 2 - 100, 16, 72, 72)];
        captainView.healthEffect = NO;
    }
    captainView.delegate = self;
    [captainView setBackgroundColor:[UIColor ggaTransParentColor]];
    [self.view addSubview:captainView];

    label = [[UILabel alloc] init];
    label.textAlignment = NSTextAlignmentCenter;
    label.font = FONT(16.f);
    label.text = LANGUAGE(@"LEADING");
    label.textColor = [UIColor ggaWhiteColor];
    label.backgroundColor = [UIColor ggaBlackColor];
    label.alpha = 0.65f;
    label.layer.cornerRadius = 10;
    label.layer.masksToBounds = YES;
    label.frame = CGRectMake(12, (subviewHeight - 24) / 2, 48, 24);
    [self.view addSubview:label];

    if (corchView && corchView.record)
    {
        
    }
    else
    {
    	corchView = [[MemberItemView alloc] initWithFrame:CGRectMake(subviewWidth / 2 + 28, 16, 72, 72)];
        corchView.healthEffect = NO;
    }
    corchView.delegate = self;
    [corchView setBackgroundColor:[UIColor ggaTransParentColor]];
    [self.view addSubview:corchView];
    
    label = [[UILabel alloc] init];
    label.textAlignment = NSTextAlignmentCenter;
    label.font = FONT(16.f);
    label.text = LANGUAGE(@"TRAINING");
    label.textColor = [UIColor ggaWhiteColor];
    label.backgroundColor = [UIColor ggaBlackColor];
    label.alpha = 0.65f;
    label.layer.cornerRadius = 10;
    label.layer.masksToBounds = YES;
    label.frame = CGRectMake(subviewWidth - 60 , (subviewHeight - 24) / 2, 48, 24);
    [self.view addSubview:label];
    
    //delete
    frame = CGRectMake(subviewWidth/ 2 - 32, 12, 64, 64);
    trashView = [[UIView alloc] initWithFrame:frame];
    trashView.backgroundColor = [UIColor ggaTransParentColor];
    [self.view addSubview:trashView];
    UIImageView *deleteImage = [[UIImageView alloc] initWithImage:IMAGE(@"delete")];
    [deleteImage setFrame:CGRectMake(0, 0, trashView.bounds.size.width, trashView.bounds.size.height)];
    [trashView addSubview:deleteImage];
    
    frame = CGRectMake(0, subviewHeight * 1, subviewWidth, subviewHeight);
    forwardView = [[UIScrollView alloc] initWithFrame:frame];
    forwardView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleRightMargin;
    forwardView.backgroundColor = [UIColor ggaTransParentColor];
    [self.view addSubview:forwardView];
    
    label = [[UILabel alloc] init];
    label.textAlignment = NSTextAlignmentCenter;
    label.font = FONT(16.f);
    label.text = LANGUAGE(@"FRONT_YARD");
    label.textColor = [UIColor ggaWhiteColor];
    label.backgroundColor = [UIColor ggaBlackColor];
    label.alpha = 0.65f;
    label.layer.cornerRadius = 10;
    label.layer.masksToBounds = YES;
    label.frame = CGRectMake((subviewWidth - 48) / 2 , frame.origin.y + 4, 48, 24);
    [self.view addSubview:label];
    
    frame = CGRectMake(0, subviewHeight * 2, subviewWidth, subviewHeight);
    middleView = [[UIScrollView alloc] initWithFrame:frame];
    middleView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin;
    middleView.backgroundColor = [UIColor ggaTransParentColor];
    [self.view addSubview:middleView];
    
    label = [[UILabel alloc] init];
    label.textAlignment = NSTextAlignmentCenter;
    label.font = FONT(16.f);
    label.text = LANGUAGE(@"MIDDLE_YARD");
    label.textColor = [UIColor ggaWhiteColor];
    label.backgroundColor = [UIColor ggaBlackColor];
    label.alpha = 0.65f;
    label.layer.cornerRadius = 10;
    label.layer.masksToBounds = YES;
    label.frame = CGRectMake((subviewWidth - 48) / 2 , frame.origin.y + 4, 48, 24);
    [self.view addSubview:label];
    
    frame = CGRectMake(0, subviewHeight * 3, subviewWidth, subviewHeight);
    defenceView = [[UIScrollView alloc] initWithFrame:frame];
    defenceView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin;
    defenceView.backgroundColor = [UIColor ggaTransParentColor];
    [self.view addSubview:defenceView];
    
    label = [[UILabel alloc] init];
    label.textAlignment = NSTextAlignmentCenter;
    label.font = FONT(16.f);
    label.text = LANGUAGE(@"BACK_YARD");
    label.textColor = [UIColor ggaWhiteColor];
    label.backgroundColor = [UIColor ggaBlackColor];
    label.alpha = 0.65f;
    label.layer.cornerRadius = 10;
    label.layer.masksToBounds = YES;
    label.frame = CGRectMake((subviewWidth - 48) / 2 , frame.origin.y + 4, 48, 24);
    [self.view addSubview:label];
    
    frame = CGRectMake(0, subviewHeight * 4, subviewWidth, subviewHeight);
    keeperView = [[UIScrollView alloc] initWithFrame:frame];
    keeperView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin;
    keeperView.backgroundColor = [UIColor ggaTransParentColor];
    [self.view addSubview:keeperView];
    
    label = [[UILabel alloc] init];
    label.textAlignment = NSTextAlignmentCenter;
    label.font = FONT(16.f);
    label.text = LANGUAGE(@"ClubMemberController_label_1");
    label.textColor = [UIColor ggaWhiteColor];
    label.backgroundColor = [UIColor ggaBlackColor];
    label.alpha = 0.65f;
    label.layer.cornerRadius = 10;
    label.layer.masksToBounds = YES;
    label.frame = CGRectMake((subviewWidth - 48) / 2 , frame.origin.y + 4, 48, 24);
    [self.view addSubview:label];
    
    trashView.dropZoneHandler =
    forwardView.dropZoneHandler =
    middleView.dropZoneHandler =
    defenceView.dropZoneHandler =
    keeperView.dropZoneHandler = self;
}

-(void) viewDidLayoutSubviews
{
    trashView.hidden = YES;
    [self layoutScrollView:forwardView withContents:forwardViewContents];
    [self layoutScrollView:middleView withContents:middleViewContents];
    [self layoutScrollView:defenceView withContents:defenceViewContents];
    [self layoutScrollView:keeperView withContents:keeperViewContents];
}



#pragma User Definded
- (void)sortAndLayoutMembers
{
    MemberItemView *item;
    NSMutableArray *corchMembers = [[NSMutableArray alloc] init];
    NSMutableArray *captainMembers = [[NSMutableArray alloc] init];
    
    for (int i =0; i < [members count]; i++)
    {
        PlayerListRecord *record = [members objectAtIndex:i];
       
        if (dropedMembers && [dropedMembers count] > 0)
        {
            NSString *key = [NSString stringWithFormat:@"%d" , [record intWithPlayerID]];
            MemberItemView *dropMember = [dropedMembers valueForKey:key];
            if (dropMember)
                [record setPositionInGameWithInt:[dropMember.record valueWithPositionInGame]];
            
        }
        
        item = [[MemberItemView alloc] initWithFrame:CGRectMake(10, 10, 40, 40)];
        item.delegate = self;
        item.tag = kItemViewIndex ++;
        [item drawWithRecord:record];
        [item setBackgroundColor:[UIColor ggaTransParentColor]];
        if ([[ClubManager sharedInstance] checkAdminClub:nMineClubID])
        {
            UIGestureRecognizer *recognizer = [dragDropManager createLongPressDragDropGestureRecognizerWithSource:self];
            [item addGestureRecognizer:recognizer];
        }

        int userType = [record intWithUserType];
        if ((userType & CLUB_USER_POST_CAPTAIN) == CLUB_USER_POST_CAPTAIN)
            [captainMembers addObject:record];
        if ((userType & CLUB_USER_POST_CORCH) == CLUB_USER_POST_CORCH)
            [corchMembers addObject:record];

        NSString *positionStr = [NSPosition stringFirstWithIntegerPosition:[record valueWithPositionInGame]];
        if ([positionStr isEqualToString:LANGUAGE(@"ClubMemberController_Forward")]) //forward
        {
            [record setPositionInGameWithInt:CLUB_POSITIONINGAME_FORWARD];
            [forwardView addSubview: item];
            [forwardViewContents addObject: item];
            
        }
        else if ([positionStr isEqualToString:LANGUAGE(@"MIDDLE_YARD")]) //middle
        {
            [record setPositionInGameWithInt:CLUB_POSITIONINGAME_MIDDLE];
            [middleView addSubview: item];
            [middleViewContents addObject: item];
        }
        else if ([positionStr isEqualToString:LANGUAGE(@"ClubMemberController_Defence")]) //defence
        {
            [record setPositionInGameWithInt:CLUB_POSITIONINGAME_DEFENCE];
            [defenceView addSubview: item];
            [defenceViewContents addObject: item];
        }
        else if ([positionStr isEqualToString: LANGUAGE(@"ClubMemberController_label_1")]) //keeper
        {
            [record setPositionInGameWithInt:CLUB_POSITIONINGAME_KEEPER];
            [keeperView addSubview: item];
            [keeperViewContents addObject: item];
        }
        
        if (corchView.record && [corchView.record intWithPlayerID] == [record intWithPlayerID])
        {
            corchView.record = record;
        }
        if (captainView.record && [captainView.record intWithPlayerID] == [record intWithPlayerID])
        {
            captainView.record = record;
        }
    }
    
    if (corchMembers.count == 0)
        [corchMembers addObject:[[PlayerListRecord alloc] init]];
    if (captainMembers.count == 0)
        [captainMembers addObject:[[PlayerListRecord alloc] init]];
    
    if (corchView.record)
    {
         [corchView drawCorchWithRecord:corchView.record];
    }
    else
    {
        corchView.record = (PlayerListRecord *)[corchMembers objectAtIndex: 0];
        [corchView drawCorchWithRecord:(PlayerListRecord *)[corchMembers objectAtIndex: 0]];
    }
    
    
    if (captainView.record)
    {
        [captainView drawCaptainWithRecord:captainView.record];
    }
    else
    {
        captainView.record = (PlayerListRecord *)[captainMembers objectAtIndex: 0];
        [captainView drawCaptainWithRecord:(PlayerListRecord *)[captainMembers objectAtIndex: 0]];
    }
    
    [self layoutScrollView:forwardView withContents:forwardViewContents];
    [self layoutScrollView:middleView withContents:middleViewContents];
    [self layoutScrollView:defenceView withContents:defenceViewContents];
    [self layoutScrollView:keeperView withContents:keeperViewContents];
}

- (void)backPressed:(id)sender
{
    [Common BackToPage];
}

- (void)savePressed:(id)sender
{
    NSLog(@"savePressed:");
    
    NSString *userIdStr = @"";
    NSString *positionStr = @"";
    NSString *captainIdStr = @"0";
    NSString *corchIdStr = @"0";
    NSString *delUserIdStr = @"";
    
    PlayerListRecord *item;
    for (int i=0; i<members.count; i++)
    {
        item = [members objectAtIndex:i];
        userIdStr = [userIdStr stringByAppendingFormat:@"%d", [item intWithPlayerID]];
        positionStr = [positionStr stringByAppendingFormat:@"%d", [item valueWithPositionInGame]];
        if (i < members.count - 1)
        {
            userIdStr = [userIdStr stringByAppendingString:@","];
            positionStr = [positionStr stringByAppendingString:@","];
        }
    }
    if ([captainView.record intWithPlayerID] != 0)
        captainIdStr = [NSString stringWithFormat:@"%d", [captainView.record intWithPlayerID]];
    if ([corchView.record intWithPlayerID] != 0)
        corchIdStr = [NSString stringWithFormat:@"%d", [corchView.record intWithPlayerID]];
    
    for (int i=0; i<deletedMembers.count; i++)
    {
        item = [deletedMembers objectAtIndex:i];
        delUserIdStr = [delUserIdStr stringByAppendingFormat:@"%d", [item intWithPlayerID]];
        if (i < deletedMembers.count - 1)
            delUserIdStr = [delUserIdStr stringByAppendingString:@","];
    }

    [AlertManager WaitingWithMessage];
    [[HttpManager sharedInstance] saveMemberListWithDelegate:self
                                                        data:[NSArray arrayWithObjects:userIdStr, positionStr, corchIdStr, captainIdStr, delUserIdStr, nil]];
}



#pragma MemeberItemViewDelegate
- (void)memberItemClicked:(MemberItemView *)item withUserType:(int)type withPlayerId:(int)playerId
{
    ggaAppDelegate *appDelegate = APP_DELEGATE;
    UIViewController *vc;

//    int nClubID = [[[NSUserDefaults standardUserDefaults] objectForKey:@"CLUBDETAIL_CLUBID"] intValue];

    if (item == corchView)
    {
        if ([[ClubManager sharedInstance] checkAdminClub:nMineClubID])
        vc = [[ClubMemberListController alloc] initWithMembers:members delegate:self chooseCorch:YES];
    }
    else if (item == captainView)
    {
        if ([[ClubManager sharedInstance] checkAdminClub:nMineClubID])
            [AlertManager ConfirmWithDelegate:self message:LANGUAGE(@"would you like to change captain") cancelTitle:LANGUAGE(@"cancel") okTitle:LANGUAGE(@"ok") tag:1200];
    }
    else
        vc = [[PlayerDetailController alloc] initWithPlayerID:playerId showInviteButton:NO];

    [appDelegate.ggaNav pushViewController:vc animated:YES];
}



#pragma ClubMemberListControllerDelegate
- (void)didSelectedWithRecord:(PlayerListRecord *)record chooseCorch:(BOOL)chooseCorch
{
    if ([[ClubManager sharedInstance] checkAdminClub:nMineClubID])
    {
        if (chooseCorch)
        {
            corchView.record = record;
            [corchView drawCorchWithRecord:record];
        }
        else
        {
            captainView.record = record;
            [captainView drawCaptainWithRecord:record];
        }
    }
    else
        [AlertManager AlertWithMessage:LANGUAGE(@"no_manager")];
}



#pragma HttpManagerDelegate
- (void)browseMemberListResultWithErrorCode:(int)errorCode data:(NSArray *)data
{
    [members addObjectsFromArray:data];
    [self sortAndLayoutMembers];
}

- (void)saveMemberListResultWithErrorCode:(int)errorCode status:(int)status
{
    [AlertManager HideWaiting];
    if (errorCode != ProtocolErrorTypeNone || status != 1)
        [AlertManager AlertWithMessage:LANGUAGE(@"failed")];
    else
    {
        [AlertManager AlertWithMessage:LANGUAGE(@"save success")];
        
        int uid = [[[NSUserDefaults standardUserDefaults] objectForKey:@"LOGIN_DATA_UID"] intValue];
        int captainId = [captainView.record intWithPlayerID];
        if (uid != captainId)
        {
            int nClubID = [[[NSUserDefaults standardUserDefaults] objectForKey:@"CLUBDETAIL_CLUBID"] intValue];
            [[ClubManager sharedInstance] removeAdminClub:nClubID];
            [[DiscussRoomManager sharedInstance] removeChatRoomsWithClubID:nClubID];
        }
        
        [self clearContents];
        [[HttpManager sharedInstance] browseMemberListWithDelegate:self withClubID:[NSArray arrayWithObject:[NSNumber numberWithInt:nMineClubID]]];
    }
}

#pragma Drag&Drop
-(void) layoutScrollView:(UIScrollView*)scrollView withContents:(NSMutableArray*)contents
{
    CGRect bounds = scrollView.bounds;
    __block CGRect contentBounds = bounds;
    
    CGSize margin = CGSizeMake(4.0, 8.0);
    CGFloat itemWidth = bounds.size.height - 32;
    CGFloat itemHeight = bounds.size.height - 32;
    CGFloat x = margin.width;
    
    for (UIView *view in contents)
    {
        CGRect frame = CGRectMake(x, 32, itemWidth, itemHeight);
        view.frame = frame;
        x += itemWidth;
        contentBounds = CGRectUnion(contentBounds, frame);
    }
    
    scrollView.contentSize = contentBounds.size;
}

-(NSInteger) insertionIndexForLocation:(CGPoint)location withContents:(NSArray*)contents
{
    CGFloat minDistance = CGFLOAT_MAX;
    NSInteger insertionIndex = 0;
    for (UIView *view in contents)
    {
        CGFloat locationToView = location.x - CGRectGetMidX(view.frame);
        if (locationToView > 0 && locationToView < minDistance)
        {
            minDistance = locationToView;
            insertionIndex = [contents indexOfObject:view] + 1;
        }
    }
    return insertionIndex;
}



#pragma mark - OBOvumSource
-(OBOvum *) createOvumFromView:(UIView*)sourceView
{
    trashView.hidden = NO;
    
    OBOvum *ovum = [[OBOvum alloc] init];
    ovum.dataObject = [NSNumber numberWithInteger:sourceView.tag];
    return ovum;
}

-(UIView *) createDragRepresentationOfSourceView:(UIView *)sourceView inWindow:(UIWindow*)window
{
    CGRect frame = [sourceView convertRect:sourceView.bounds toView:sourceView.window];
    frame = [window convertRect:frame fromWindow:sourceView.window];
    
    MemberItemView *dragView = [[MemberItemView alloc] initWithFrame:frame];
    [dragView drawWithRecord:((MemberItemView *)sourceView).record];
    [dragView setBackgroundColor:[UIColor ggaTransParentColor]];
    
    return dragView;
}

-(void) dragViewWillAppear:(UIView *)dragView inWindow:(UIWindow*)window atLocation:(CGPoint)location
{
    dragView.transform = CGAffineTransformIdentity;
    dragView.alpha = 0.0;
    
    [UIView animateWithDuration:0.25 animations:^{
        dragView.center = location;
        dragView.transform = CGAffineTransformMakeScale(0.85, 0.85);
        dragView.alpha = 0.75;
    }];  
}



#pragma mark - OBDropZone

static NSInteger kLabelTag = 2323;

-(OBDropAction) ovumEntered:(OBOvum*)ovum inView:(UIView*)view atLocation:(CGPoint)location
{
    
    CGFloat red = 0.33 + 0.66 * location.y / self.view.frame.size.height;
    view.layer.borderColor = [UIColor colorWithRed:red green:0.0 blue:0.0 alpha:1.0].CGColor;
    view.layer.borderWidth = 2.0;
    
    return OBDropActionMove;
}

-(OBDropAction) ovumMoved:(OBOvum*)ovum inView:(UIView*)view atLocation:(CGPoint)location
{
    CGFloat hiphopopotamus = 0.33 + 0.66 * location.y / self.view.frame.size.height;
    
    view.layer.borderColor = [UIColor colorWithRed:0.0 green:hiphopopotamus blue:0.0 alpha:1.0].CGColor;
    view.layer.borderWidth = 2.0;
    
    UILabel *label = (UILabel*) [ovum.dragView viewWithTag:kLabelTag];
    label.text = [NSString stringWithFormat:@"Ovum at %@", NSStringFromCGPoint(location)];
    
    return OBDropActionMove;
}

-(void) ovumExited:(OBOvum*)ovum inView:(UIView*)view atLocation:(CGPoint)location
{
    view.layer.borderColor = [UIColor clearColor].CGColor;
    view.layer.borderWidth = 0.0;
}

-(void) ovumDropped:(OBOvum*)ovum inView:(UIView*)view atLocation:(CGPoint)location
{
    trashView.hidden = YES;
    
    view.layer.borderColor = [UIColor clearColor].CGColor;
    view.layer.borderWidth = 0.0;
    
    if ([ovum.dataObject isKindOfClass:[NSNumber class]])
    {
        MemberItemView *itemView = (MemberItemView *)[self.view viewWithTag:[ovum.dataObject integerValue]];
        if (itemView)
        {
            NSMutableArray *viewContents;
            if (view == forwardView)
            {
                viewContents = forwardViewContents;
                [itemView.record setPositionInGameWithInt:CLUB_POSITIONINGAME_FORWARD];
            }
            else if (view == middleView)
            {
                viewContents = middleViewContents;
                [itemView.record setPositionInGameWithInt:CLUB_POSITIONINGAME_MIDDLE];
            }
            else if (view == defenceView)
            {
                viewContents = defenceViewContents;
                [itemView.record setPositionInGameWithInt:CLUB_POSITIONINGAME_DEFENCE];
            }
            else if (view == keeperView)
            {
                viewContents = keeperViewContents;
                [itemView.record setPositionInGameWithInt:CLUB_POSITIONINGAME_KEEPER];
            }
            
            if (view == trashView && captainView.record == itemView.record)
                [AlertManager AlertWithMessage:LANGUAGE(@"select another admin")];
            else
            {
                [itemView removeFromSuperview];
                if ([forwardViewContents containsObject:itemView])
                    [forwardViewContents removeObject:itemView];
                else if ([middleViewContents containsObject:itemView])
                    [middleViewContents removeObject:itemView];
                else if ([defenceViewContents containsObject:itemView])
                    [defenceViewContents removeObject:itemView];
                else if ([keeperViewContents containsObject:itemView])
                    [keeperViewContents removeObject:itemView];
                
                NSInteger insertionIndex = [self insertionIndexForLocation:location withContents:viewContents];
                [view insertSubview:itemView atIndex:insertionIndex];
                [viewContents insertObject:itemView atIndex:insertionIndex];
                NSString *key = [NSString stringWithFormat:@"%d", [itemView.record intWithPlayerID]];
                [dropedMembers setValue:itemView forKey:key];
            }
        }
    }
}

-(void) handleDropAnimationForOvum:(OBOvum*)ovum withDragView:(UIView*)dragView dragDropManager:(OBDragDropManager*)dragDropManager
{
    MemberItemView *itemView = nil;
    if ([ovum.dataObject isKindOfClass:[NSNumber class]])
        itemView = (MemberItemView *)[self.view viewWithTag:[ovum.dataObject integerValue]];
    
    if (itemView)
    {
        // Set the initial position of the view to match that of the drag view
        CGRect dragViewFrameInTargetWindow = [ovum.dragView.window convertRect:dragView.frame toWindow:itemView.superview.window];
        dragViewFrameInTargetWindow = [itemView.superview convertRect:dragViewFrameInTargetWindow fromView:itemView.superview.window];
        itemView.frame = dragViewFrameInTargetWindow;
        CGRect viewFrame = [ovum.dragView.window convertRect:itemView.frame fromView:itemView.superview];
        
        void (^animation)() = ^{
            dragView.frame = viewFrame;
            dragView.alpha = 0.0f;
            
            if (itemView.superview == trashView)
            {
                //delete
                if (captainView.record != itemView.record)
                {
                    [itemView removeFromSuperview];
                    [members removeObject:((MemberItemView *)itemView).record];
                    [deletedMembers addObject:((MemberItemView*)itemView).record];
                    if (corchView.record == itemView.record)
                        [corchView drawCorchWithRecord:[[PlayerListRecord alloc] init]];
                }
            }
            
            [self layoutScrollView:forwardView withContents:forwardViewContents];
            [self layoutScrollView:middleView withContents:middleViewContents];
            [self layoutScrollView:defenceView withContents:defenceViewContents];
            [self layoutScrollView:keeperView withContents:keeperViewContents];
        };
        
        [dragDropManager animateOvumDrop:ovum withAnimation:animation completion:nil];
    }
}

- (void)clearContents
{
    members = [[NSMutableArray alloc] init];
    deletedMembers = [[NSMutableArray alloc] init];
    
    for (UIView *item in forwardView.subviews)
    {
        [item removeFromSuperview];
    }
    [forwardViewContents removeAllObjects];

    for (UIView *item in middleView.subviews)
    {
        [item removeFromSuperview];
    }
    [middleViewContents removeAllObjects];
   
    for (UIView *item in defenceView.subviews)
    {
        [item removeFromSuperview];
    }
    [defenceViewContents removeAllObjects];
    
    for (UIView *item in keeperView.subviews)
    {
        [item removeFromSuperview];
    }
    [keeperViewContents removeAllObjects];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 1200)
    {
        switch (buttonIndex) {
            case 0:
                break;
            case 1:
            {
                if ([[ClubManager sharedInstance] checkAdminClub:nMineClubID])
                {
                    ggaAppDelegate *appDelegate = APP_DELEGATE;
                    ClubMemberListController *vc = [[ClubMemberListController alloc] initWithMembers:members delegate:self chooseCorch:NO];
                    [appDelegate.ggaNav pushViewController:vc animated:YES];
                }

            }
                break;
            default:
                break;
        }
    }
}
@end
