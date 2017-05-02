//
//  TeamSelectController.m
//  GoalGroup
//
//  Created by MacMini on 3/14/15.
//  Copyright (c) 2015 KCHN. All rights reserved.
//

#import "TeamSelectController.h"
#import "Common.h"

@interface TeamSelectController ()
{
    NSMutableArray *clubs;
}
@end

@implementation TeamSelectController


- (id)initAdminMonoSelModeWithDelegate:(id<TeamSelectControllerDelegate>)delegate
{
    self.delegate = delegate;
    adminMode = YES;
    mutilMode = NO;
    return [self init];
}

- (id)initNormalMultiSelectModeWithDelegate:(id<TeamSelectControllerDelegate>)delegate
{
    self.delegate = delegate;
    adminMode = NO;
    mutilMode = YES;
    return [self init];
}

- (id)initNormalMonoSelectModeWithDelegate:(id<TeamSelectControllerDelegate>)delegate
{
    self.delegate = delegate;
    adminMode = NO;
    mutilMode = NO;
    return [self init];
}


- (id)initAdminMutliSelectModeWithDelegate:(id<TeamSelectControllerDelegate>)delegate
{
    self.delegate = delegate;
    adminMode = YES;
    mutilMode = YES;
    return [self init];
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        clubs = [[NSMutableArray alloc] init];
        [clubs addObjectsFromArray:adminMode? ADMINCLUBS: CLUBS];
    }
    return self;
}

- (void)viewDidLoad
{
    self.title = LANGUAGE(@"SELECT_CLUB");
    
    [super viewDidLoad];
    
    UIView *backButtonView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 48, 24)];
    UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(8, -4, 30, 30)]; //Modified By Boss.2015/05/02
    [backButton setImage:[UIImage imageNamed:@"move_forward"] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(backToPage) forControlEvents:UIControlEventTouchDown];
    [backButtonView addSubview:backButton];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButtonView];
    
    if (!mutilMode)
        return;
    
    UIView *confirmButtonView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 48, 24)];
    UIButton *confirmButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 48, 24)];
    confirmButton.titleLabel.font = FONT(14.f);
    [confirmButton setTitle:LANGUAGE(@"yes") forState:UIControlStateNormal];
    [confirmButton addTarget:self action:@selector(confirm) forControlEvents:UIControlEventTouchDown];
    [confirmButtonView addSubview:confirmButton];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:confirmButtonView];

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
    return clubs.count;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (!mutilMode)
    {
        [self.delegate teamSelected:[[[clubs objectAtIndex:indexPath.row] objectForKey:@"club_id"] intValue]];
        [Common BackToPage];
    }
    else
    {
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        
        cell.accessoryType = cell.accessoryType == UITableViewCellAccessoryCheckmark? UITableViewCellAccessoryNone:UITableViewCellAccessoryCheckmark;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = [NSString stringWithFormat:@"cellIndetifier_%ld", indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.textLabel.text = [[clubs objectAtIndex:indexPath.row] objectForKey:@"club_name"];
    }
    // Configure the cell...
    
    return cell;
}

- (void)backToPage
{
    [Common BackToPage];
}

- (void)confirm
{
    NSMutableArray *sels = [[NSMutableArray alloc] init];
    for (int i = 0; i < clubs.count; i ++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        
        if (cell.accessoryType == UITableViewCellAccessoryCheckmark)
        {
            [sels addObject:[NSNumber numberWithInt:[[[clubs objectAtIndex:i] objectForKey:@"club_id"] intValue]]];
        }
    }
    
    if ([sels count] == 0)
    {
        [AlertManager AlertWithMessage:LANGUAGE(@"No club is selected")];
        return;
    }
    [self.delegate multiTeamSelected:sels];
    [Common BackToPage];
}
@end
