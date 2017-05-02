//
//  CitySelectController.m
//  GoalGroup
//
//  Created by MacMini on 3/9/15.
//  Copyright (c) 2015 KCHN. All rights reserved.
//

#import "CitySelectController.h"
#import "Common.h"

@interface CitySelectController ()

@end

@implementation CitySelectController

@synthesize beforeSelected;

+ (CitySelectController *)sharedInstance
{
    @synchronized(self)
    {
        if (gCitySelectController == nil)
            gCitySelectController = [[CitySelectController alloc] init];
    }
    return gCitySelectController;
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        titles = [[NSMutableArray alloc] init];
        
        for (NSDictionary *item in CITYS) {
            [titles addObject:[item objectForKey:@"city"]];
        }
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = LANGUAGE(@"select city");
    UIView *backButtonRegion = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 48, 24)];
    UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(8, -4, 30, 30)]; //Modified By Boss.2015/05/02
    [backButton setImage:[UIImage imageNamed:@"move_forward"] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(backToPage) forControlEvents:UIControlEventTouchDown];
    [backButtonRegion addSubview:backButton];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButtonRegion];
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
    NSString *cellIndetifier = @"cellIndentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIndetifier];
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIndetifier];
    }

    NSString *cellTitle = [titles objectAtIndex:indexPath.row];
    cell.textLabel.text = cellTitle;
    
    if (beforeSelected != nil && [beforeSelected compare:cellTitle] == NSOrderedSame)
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    
    for (int i = 0; i < titles.count; i ++) {
        [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]].accessoryType = UITableViewCellAccessoryNone;
    }
    
    
    ((UITableViewCell *)[tableView cellForRowAtIndexPath:indexPath]).accessoryType = UITableViewCellAccessoryCheckmark;
    
    NSString *sel = [titles objectAtIndex:indexPath.row];
    if (![beforeSelected isEqualToString:sel])
    {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"ACTIVE_ZONE"];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"STADIUM_ZONE"];
    }

    [self.delegate selectedCityWithIndex:indexPath.row];
}

#pragma Events
- (void)backToPage
{
//    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"ACTIVE_ZONE"];
//    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"STADIUM_ZONE"];
    [Common BackToPage];
}
@end
