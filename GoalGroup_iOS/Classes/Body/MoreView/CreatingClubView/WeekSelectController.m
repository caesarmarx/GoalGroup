//
//  WeekSelectController.m
//  GoalGroup
//
//  Created by KCHN on 2/10/15.
//  Copyright (c) 2015 KCHN. All rights reserved.
//

#import "WeekSelectController.h"
#import "Common.h"

@interface WeekSelectController ()

@end

@implementation WeekSelectController

+ (WeekSelectController *) sharedInstance
{
    @synchronized(self)
    {
        if (gWeekSelectController == nil) {
            gWeekSelectController = [[WeekSelectController alloc] initWithStyle:UITableViewStyleGrouped];
        }
    }
    return gWeekSelectController;
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        titles = [NSArray arrayWithObjects:
                  LANGUAGE(@"week_mon") ,
                  LANGUAGE(@"week_tue"),
                  LANGUAGE(@"week_web"),
                  LANGUAGE(@"week_thu"),
                  LANGUAGE(@"week_fri"),
                  LANGUAGE(@"week_sat"),
                  LANGUAGE(@"week_sun"),
                  nil];
        self.title = LANGUAGE(@"SEARCH_COND_WEEK");
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.backgroundColor = [UIColor ggaGrayBackColor];
    self.tableView.backgroundView = nil;
    
    //In IOS, in default, header padding is 35pixel.
    self.tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.tableView.bounds.size.width, 0.01f)]; //Added By Boss.2015/05/06
    self.view.backgroundColor = [UIColor ggaGrayBackColor];
    UIView *backButtonRegion = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 48, 24)];
    UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(8, -4, 30, 30)]; //Modified By Boss.2015/05/02
    [backButton setImage:[UIImage imageNamed:@"move_forward"] forState:UIControlStateNormal];

    [backButton addTarget:self action:@selector(backToPage:) forControlEvents:UIControlEventTouchUpInside];
    [backButtonRegion addSubview:backButton];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButtonRegion];
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
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
        if (!((storedWorkDays == nil) || [storedWorkDays  isEqual: @""])) {
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
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (cell.accessoryType == UITableViewCellAccessoryNone) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
}

- (void)backToPage:(id)sender
{
    ggaAppDelegate *appDelegate = APP_DELEGATE;
    [appDelegate.ggaNav popViewControllerAnimated:YES];
}

@end
