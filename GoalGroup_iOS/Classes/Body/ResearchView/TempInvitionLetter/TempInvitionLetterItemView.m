//
//  TempInvitionLetterItemView.m
//  GoalGroup
//
//  Created by KCHN on 2/22/15.
//  Copyright (c) 2015 KCHN. All rights reserved.
//

#import "TempInvitionLetterItemView.h"
#import "Common.h"

@implementation TempInvitionLetterItemView
{
    UIView *topView;
    UIView *swipeView;
}
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        swiped = NO;
        
        int h = SCREEN_WIDTH / 1.7;
        topView = [[UIView alloc] initWithFrame:CGRectMake(3, 2, SCREEN_WIDTH - 6, h - 4)];
        topView.backgroundColor = [UIColor colorWithRed:11/255.f green:197/255.f blue:96/255.f alpha:1.f];
        topView.layer.cornerRadius = 8;
        topView.layer.masksToBounds = YES;
        
        itemView = [[ChallengeItemView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH - 6,  h - 4)];
        itemView.showTeam = YES;
        itemView.detail = YES;
        itemView.letterMode = YES;
        itemView.delegate = self;
        UIGraphicsBeginImageContext(itemView.frame.size);
        [[UIImage imageNamed:@"challenge_cell_bg"] drawInRect:itemView.bounds];
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        itemView.backgroundColor = [UIColor colorWithPatternImage:image];
        [topView addSubview:itemView];
        
        swipeView = [[UIView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 60 - 10, 2, 60 + 6, h - 4)];
        swipeView.layer.cornerRadius = 8;
        swipeView.backgroundColor = [UIColor colorWithRed:7/255.f green:118/255.f blue:58/255.f alpha:1.f];
        
        UIButton *acceptButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [acceptButton setImage:IMAGE(@"invitiation_edit") forState: UIControlStateNormal];
        [acceptButton addTarget:self action:@selector(acceptButtonClick) forControlEvents:UIControlEventTouchDown];
        acceptButton.frame = CGRectMake(22, h / 2 - 60, 30, 30);
        
        UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [cancelButton setImage:IMAGE(@"invitiation_delete") forState:UIControlStateNormal];
        [cancelButton addTarget:self action:@selector(cancelButtonClick) forControlEvents:UIControlEventTouchDown];
        cancelButton.frame = CGRectMake(22, h / 2 + 30, 30, 30);
        
        [swipeView addSubview:cancelButton];
        [swipeView addSubview:acceptButton];
        
        [self.contentView addSubview:swipeView];
        [self.contentView addSubview:topView];
        
        UISwipeGestureRecognizer *leftGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(leftSwiped:)];
        [leftGesture setDirection:UISwipeGestureRecognizerDirectionLeft];
        
        UISwipeGestureRecognizer *rightGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(rightSwiped:)];
        [rightGesture setDirection:UISwipeGestureRecognizerDirectionRight];
        
        [self.contentView addGestureRecognizer:rightGesture];
        [self.contentView addGestureRecognizer:leftGesture];
        

    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma Events
- (void)leftSwiped:(UISwipeGestureRecognizer *)g
{
    topView.layer.cornerRadius = 0;
    topView.layer.masksToBounds = NO;
    if (swiped)
        return;
    
    swiped = YES;
    [self openMenuView];
}


- (void)rightSwiped:(UISwipeGestureRecognizer *)g
{
    if (!swiped)
        return;
    
    swiped = NO;
    [self closeMenuView];
}

- (void)openMenuView
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDuration:0.5];
    [UIView setAnimationBeginsFromCurrentState:YES];
    
    topView.frame = CGRectMake(topView.frame.origin.x - 60, topView.frame.origin.y, topView.frame.size.width, topView.frame.size.height);
    topView.backgroundColor = [UIColor colorWithRed:11/255.f green:197/255.f blue:96/255.f alpha:1.f];
    
    [UIView commitAnimations];
    
    [self.delegate menuDidShowInCell:self];
}

- (void)closeMenuView
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDuration:0.5];
    [UIView setAnimationBeginsFromCurrentState:YES];
    
    topView.frame = CGRectMake(topView.frame.origin.x + 60, topView.frame.origin.y, topView.frame.size.width, topView.frame.size.height);
    topView.backgroundColor = [UIColor whiteColor];
    
    [UIView commitAnimations];
    
    [self.delegate menuDidHideInCell];
}

- (void)closeMenu
{
    [self rightSwiped:nil];
    topView.layer.cornerRadius = 8;
    topView.layer.masksToBounds = YES;
}

- (void)acceptButtonClick
{
    [self.delegate doClickAgree:self];
}

- (void)cancelButtonClick
{
    [self.delegate doClickDisagress:self];
}
#pragma UserDefined
- (void)drawTempLetterWithRecord:(ChallengeListRecord *)record
{
    [itemView dataWithChallengeItem:record];
    [self setNeedsDisplay];
}

#pragma ChallengeItemViewDelegate
- (void)doClickClubDetail:(NSInteger)nClubID
{
    [self.delegate doClickClubDetail:self clubID:nClubID];
}
@end
