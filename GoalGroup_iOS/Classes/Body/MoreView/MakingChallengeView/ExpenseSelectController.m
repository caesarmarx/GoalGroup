//
//  ExpenseSelectController.m
//  GoalGroup
//
//  Created by MacMini on 3/14/15.
//  Copyright (c) 2015 KCHN. All rights reserved.
//

#import "Common.h"
#import "ExpenseSelectController.h"

@interface ExpenseSelectController ()
{
    NSArray *titles;
}
@end

@implementation ExpenseSelectController

- (id)initWithDelegate:(id<ExpenseSelectControllerDelegate>)delegate
{
    self.delegate = delegate;
    return [self init];
}
- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        titles = [NSArray arrayWithObjects:LANGUAGE(@"MAIN TEAM GIVE"), LANGUAGE(@"OTHER TEAM GIVE"),[NSString stringWithFormat:@"AA%@",LANGUAGE(@"SYSTEM")] , nil];
        self.title =LANGUAGE(@"GROUND COST");
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
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
    return 3;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40.f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIndentifier = @"cellIndentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIndentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIndentifier];
    }

    cell.textLabel.text = [titles objectAtIndex:indexPath.row];
    return cell;

}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self.delegate expenseSelected:indexPath.row];
    [Common BackToPage];
}


#pragma UserDefined
- (void)backToPage
{
    [Common BackToPage];
}
@end
