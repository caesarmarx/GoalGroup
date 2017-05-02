//
//  ZoneSelectController.m
//  GoalGroup
//
//  Created by MacMini on 3/10/15.
//  Copyright (c) 2015 KCHN. All rights reserved.
//

#import "ZoneSelectController.h"
#import "DistrictManager.h"
#import "Common.h"

@interface ZoneSelectController ()
{
    int cityIndex;
}
@end

@implementation ZoneSelectController

- (id)initWithCityIndex:(int)index
{
    cityIndex = index;
    titles = [[NSMutableArray alloc] init];
    
    for (NSDictionary *item in [[DistrictManager sharedInstance] districtsWithCityIndex:cityIndex]) {
        [titles addObject:[item objectForKey:@"district"]];
    }
    
    return [self init];
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        
    }
    return self;
}

- (id)initWithAllArea
{
    cityIndex = NSNotFound;
    titles = [[NSMutableArray alloc] init];
    for (NSDictionary *item in [[DistrictManager sharedInstance] districtsWithAllIndex])
        [titles addObject:[item objectForKey:@"district"]];
    return [self init];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSString *selCellIdentifier = [[NSUserDefaults standardUserDefaults] objectForKey:@"ZONE_SELECT_FOR_WHAT"];
    if ([selCellIdentifier compare:@"ACTIVE_ZONE"] == NSOrderedSame)
        self.title = LANGUAGE(@"active zone with out comma");
    else
        self.title = LANGUAGE(@"home zone without comma");
    
    UIView *backButtonView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 48, 24)];
    UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(8, -4, 30, 30)]; //Modified By Boss.2015/05/02
    [backButton setImage:[UIImage imageNamed:@"move_forward"] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(backToPage) forControlEvents:UIControlEventTouchDown];
    [backButtonView addSubview:backButton];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButtonView];
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    NSString *selCellIdentifier = [[NSUserDefaults standardUserDefaults] objectForKey:@"ZONE_SELECT_FOR_WHAT"];
    
//    if ([selCellIdentifier isEqualToString:@"ACTIVE_ZONE"])
//    {
        NSString *storedZone = @"";
        for (int i = 0; i < titles.count; i++) {
            UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
            
            if (cell.accessoryType == UITableViewCellAccessoryCheckmark)
            {
                if (![storedZone isEqual:@""])
                    storedZone = [NSString stringWithFormat:@"%@,%@", storedZone, [titles objectAtIndex:i]];
                else
                    storedZone = [titles objectAtIndex:i];
            }
        }
        [[NSUserDefaults standardUserDefaults] setObject:storedZone forKey:[[NSUserDefaults standardUserDefaults] objectForKey:@"ZONE_SELECT_FOR_WHAT"]];
//    }
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
    NSString *cellIndentifier = [NSString stringWithFormat:@"cellIndentifier_%@", [titles objectAtIndex:indexPath.row]];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIndentifier];
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIndentifier];
        
        NSString *selCellIdentifier = [[NSUserDefaults standardUserDefaults] objectForKey:@"ZONE_SELECT_FOR_WHAT"];
        
//        if ([selCellIdentifier isEqualToString:@"ACTIVE_ZONE"])
//        {
            NSString *storedZone = [[NSUserDefaults standardUserDefaults] objectForKey:
                                    [[NSUserDefaults standardUserDefaults] objectForKey:@"ZONE_SELECT_FOR_WHAT"]];
            
            if (!(storedZone == nil || [storedZone isEqual:@""]))
            {
                if ([storedZone rangeOfString:[titles objectAtIndex:indexPath.row]].location == NSNotFound)
                    cell.accessoryType = UITableViewCellAccessoryNone;
                else
                    cell.accessoryType = UITableViewCellAccessoryCheckmark;
            }
            else
                cell.accessoryType = UITableViewCellAccessoryNone;
//        }
        
        cell.textLabel.text = [titles objectAtIndex:indexPath.row];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    NSString *selCellIdentifier = [[NSUserDefaults standardUserDefaults] objectForKey:@"ZONE_SELECT_FOR_WHAT"];
    
    if ([selCellIdentifier isEqualToString:@"STADIUM_ZONE"])
    {
//        [[NSUserDefaults standardUserDefaults] setObject:[titles objectAtIndex:indexPath.row]
//                                                  forKey:[[NSUserDefaults standardUserDefaults] objectForKey:@"ZONE_SELECT_FOR_WHAT"]];
//        [self backToPage];
        for (int i = 0; i < titles.count; i ++) {
            UITableViewCell *cll = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
            cll.accessoryType = UITableViewCellAccessoryNone;
        }
        cell.accessoryType= UITableViewCellAccessoryCheckmark;
    }
    else
        cell.accessoryType = cell.accessoryType == UITableViewCellAccessoryCheckmark? UITableViewCellAccessoryNone: UITableViewCellAccessoryCheckmark;
}

#pragma Events
- (void)backToPage
{
    [Common BackToPage];
}

@end
