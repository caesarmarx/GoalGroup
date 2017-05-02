//
//  StadiumSelectController.m
//  GoalGroup
//
//  Created by MacMini on 3/9/15.
//  Copyright (c) 2015 KCHN. All rights reserved.
//

#import "StadiumSelectController.h"
#import "Common.h"

@interface StadiumSelectController ()

@end

@implementation StadiumSelectController

+ (StadiumSelectController *)sharedInstance
{
    @synchronized(self)
    {
        if (gStadiumSelectController == nil)
            gStadiumSelectController = [[StadiumSelectController alloc] init];
    }
    return gStadiumSelectController;
}

-(id)initWithDelegate:(id<StadiumSelectControllerDelegate>)delegate
{
    self.delegate = delegate;
    titles = [[NSMutableArray alloc] init];
    return [self init];
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        self.title = LANGUAGE(@"MAIN_YARD");
        
        for (NSDictionary *item in STADIUMS) {
            [titles addObject:[item valueForKey:@"stadium_name"]];
        }
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [titles count];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40.f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    cell.textLabel.text = [titles objectAtIndex:indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self.delegate selectedStadiumWithIndex:indexPath.row];
}

- (void)backToPage
{
    ggaAppDelegate *appDelegate = APP_DELEGATE;
    [appDelegate.ggaNav popViewControllerAnimated:YES];
}
@end
