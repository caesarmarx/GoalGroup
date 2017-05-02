//
//  ClubSelectController.m
//  GoalGroup
//
//  Created by MacMini on 3/11/15.
//  Copyright (c) 2015 KCHN. All rights reserved.
//

#import "ClubSelectController.h"
#import "Common.h"

@interface ClubSelectController ()
{
    NSMutableArray *titles;
}
@end

@implementation ClubSelectController

+ (ClubSelectController *)sharedInstance
{
    @synchronized(self)
    {
        if (gClubSelectController == nil)
            gClubSelectController = [[ClubSelectController alloc] init];
    }
    return gClubSelectController;
}

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
    titles = [[NSMutableArray alloc] init];
    
    for (NSDictionary *item in [[ClubManager sharedInstance] adminClub]) {
        [titles addObject:[item valueForKey:@"club_name"]];
    }
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
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell  == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    cell.textLabel.text = [titles objectAtIndex:indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    int club = [[[ADMINCLUBS objectAtIndex:indexPath.row] valueForKey:@"club_id"] intValue];
    [self.delegate clubSelectClick:club];
}

@end
