//
//  SexSelectController.m
//  GoalGroup
//
//  Created by MacMini on 3/17/15.
//  Copyright (c) 2015 KCHN. All rights reserved.
//

#import "SexSelectController.h"
#import "Common.h"

@interface SexSelectController ()
{
    NSArray *titles;
}
@end

@implementation SexSelectController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title =LANGUAGE(@"SEX");
    titles = [NSArray arrayWithObjects:LANGUAGE(@"MALE"), LANGUAGE(@"FEMALE"), nil];
    
    UIView *backButtonView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 48, 24)];
    UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(8, -4, 30, 30)]; //Modified By Boss.2015/05/02
    [backButton setImage:[UIImage imageNamed:@"move_forward"] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(backToPage) forControlEvents:UIControlEventTouchDown];
    [backButtonView addSubview:backButton];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButtonView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return titles.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40.f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = @"cellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == Nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.textLabel.text = [titles objectAtIndex:indexPath.row];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self.delegate sexSelected:indexPath.row];
}

#pragma UserDefined
- (void)backToPage
{
    [Common BackToPage];
}

@end
