//
//  PositionSelectController.m
//  GoalGroup
//
//  Created by MacMini on 3/17/15.
//  Copyright (c) 2015 KCHN. All rights reserved.
//

#import "PositionSelectController.h"
#import "Common.h"

@interface PositionSelectController ()
{
    NSArray *titles;
}
@end

@implementation PositionSelectController

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
    self.title = LANGUAGE(@"POSITION");
    
    titles = [NSArray arrayWithArray:DETAILPOSITIONS];
    
    self.tableView.backgroundColor = [UIColor ggaGrayBackColor];
    self.tableView.backgroundView = nil;
    
    self.view.backgroundColor = [UIColor ggaGrayBackColor];
    UIView *backButtonRegion = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 48, 24)];
    UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(8, -4, 30, 30)]; //Modified By Boss.2015/05/02
    [backButton setImage:[UIImage imageNamed:@"move_forward"] forState:UIControlStateNormal];

    [backButton addTarget:self action:@selector(backToPage) forControlEvents:UIControlEventTouchDown];
    [backButtonRegion addSubview:backButton];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButtonRegion];

}

- (void)viewWillDisappear:(BOOL)animated
{
    NSString *selectedPosition = @"";
    for (NSInteger i = 0; i < 11; i ++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        if (cell.accessoryType == UITableViewCellAccessoryCheckmark) {
            if ([selectedPosition isEqual: @""]) {
                selectedPosition = cell.textLabel.text;
            }
            else {
                selectedPosition = [NSString stringWithFormat:@"%@,%@", selectedPosition, cell.textLabel.text];
            }
        }
    }
    [[NSUserDefaults standardUserDefaults] setObject:selectedPosition forKey:@"PLAYERDETAIL_POSITION"];
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
    return 11;
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
        NSString *storedPosition = [[NSUserDefaults standardUserDefaults] objectForKey:@"PLAYERDETAIL_POSITION"];
        if (![storedPosition isEqual: @""]) {
            NSArray *pos = [storedPosition componentsSeparatedByString:@","];
            
            cell.accessoryType = UITableViewCellAccessoryNone;
            
            for (NSString *posItem in pos) {
                if ([posItem compare:[titles objectAtIndex:indexPath.row]] == NSOrderedSame) {
                    cell.accessoryType = UITableViewCellAccessoryCheckmark;
                    break;
                }
            }
            
            
//            if ([pos indexOfObject:[titles objectAtIndex:indexPath.row]] == -1)
//                cell.accessoryType = UITableViewCellAccessoryNone;
//            else
//                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            
//            if ([storedPosition rangeOfString:[titles objectAtIndex:indexPath.row]].location == NSNotFound) {
//                cell.accessoryType = UITableViewCellAccessoryNone;
//            }
//            else {
//                cell.accessoryType = UITableViewCellAccessoryCheckmark;
//            }
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

- (void)backToPage
{
    [Common BackToPage];
}
@end
