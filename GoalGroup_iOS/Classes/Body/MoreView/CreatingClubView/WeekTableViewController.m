//
//  Setting5WeekTableViewController.m
//  mmj
//
//  Created by pcbeta on 14-10-2.
//  Copyright (c) 2014年 JinYongHao. All rights reserved.
//

#import "WeekTableViewController.h"
#import "Common.h"

@interface WeekTableViewController ()

@end

@implementation WeekTableViewController
+ (WeekTableViewController *)sharedInstance
{
    @synchronized(self)
    {
        if (gWeekTableViewController == nil)
            gWeekTableViewController = [[WeekTableViewController alloc] initWithStyle:UITableViewStyleGrouped];
    }
    return gWeekTableViewController;
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        titles = [NSArray arrayWithObjects:
                  @"星期日",
                  @"星期一",
                  @"星期二",
                  @"星期三",
                  @"星期四",
                  @"星期五",
                  @"星期六", nil];
        self.title = @"工作日";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    self.tableView.backgroundColor = [UIColor mmjGrayLightColor];
    self.tableView.backgroundView = nil;
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewWillDisappear:(BOOL)animated
{
    NSString *selectedWeekDays = @"";
    for (NSInteger i = 0; i < 7; i ++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        if (cell.accessoryType == UITableViewCellAccessoryCheckmark) {
            if ([selectedWeekDays isEqual: @""]) {
                selectedWeekDays = cell.textLabel.text;
            }
            else {
                selectedWeekDays = [NSString stringWithFormat:@"%@,%@", selectedWeekDays, cell.textLabel.text];
            }
        }
    }
    [[NSUserDefaults standardUserDefaults] setObject:selectedWeekDays forKey:@"WorkDays"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

#pragma UITableViewDataSource & UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 7;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40.f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        NSString *storedWorkDays = [[NSUserDefaults standardUserDefaults] objectForKey:@"WorkDays"];
        if (![storedWorkDays  isEqual: @""]) {
            if ([storedWorkDays rangeOfString:[titles objectAtIndex:indexPath.row]].location == NSNotFound) {
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
            else {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            }
        }
        else
        {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
    }
    cell.textLabel.text = [titles objectAtIndex:indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (cell.accessoryType == UITableViewCellAccessoryNone) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
}

/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
