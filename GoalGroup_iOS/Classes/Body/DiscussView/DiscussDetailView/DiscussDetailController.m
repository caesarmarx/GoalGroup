//
//  DiscussDetailController.m
//  GoalGroup
//
//  Created by KCHN on 2/13/15.
//  Copyright (c) 2015 KCHN. All rights reserved.
//

#import "DiscussDetailController.h"
#import "DiscussDetailItemCell.h"
#import "DiscussDetailItemData.h"
#import "DiscussDetailHeaderView.h"
#import "DiscussDetailListRecord.h"
#import "Common.h"
#import "MyPhoto.h"
#import "MyPhotoSource.h"
#import "EGOPhotoViewController.h"

@interface DiscussDetailController ()
{
    //평가전 원본기사
    int reply_src;
    
    /*
     0-기본기사에 대한 평가
     1-평가기사에 대한 평가
     */
    int reply_type;
}
@end

@implementation DiscussDetailController

- (id)initWithMainID:(int)mainID
{
    nMainID = mainID;
    return [self init];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    currPageNo = 0;
    moreAvailable = NO;
    keyboardVisible = false;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardDidHideNotification object:nil];
    
    [articles removeAllObjects];
    [self.tableView reloadData];
}

- (void)viewDidAppear:(BOOL)animated
{
    [self loadMore];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
#ifdef IOS_VERSION_7
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)])
        self.edgesForExtendedLayout = UIRectEdgeNone;
#endif
    
    [self layoutComponents];
    
    articles = [[NSMutableArray alloc] init];
}


- (void)viewWillDisappear:(BOOL)animated
{
    loading = NO;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)layoutComponents
{
    self.title = LANGUAGE(@"read_bbs");
    int screenHeight = self.view.bounds.size.height - self.navigationController.navigationBar.bounds.size.height - 20;
    
    self.view.backgroundColor = [UIColor ggaUserGrayBackgroundColor];
    
    UIView *backButtonRegion = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 48, 24)];
    UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(8, -4, 30, 30)]; //Modified By Boss.2015/05/02
    [backButton setImage:[UIImage imageNamed:@"move_forward"] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(backToPage) forControlEvents:UIControlEventTouchDown];
    [backButtonRegion addSubview:backButton];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButtonRegion];
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 80, SCREEN_WIDTH, screenHeight - 30 - 95) style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.backgroundColor = [UIColor ggaUserGrayBackgroundColor];
    [self.view addSubview:_tableView];
    
    _sendButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _sendButton.frame = CGRectMake(SCREEN_WIDTH - 60, 6, 54, 28);
    _sendButton.layer.cornerRadius = 14.f;
    _sendButton.titleLabel.font = [UIFont boldSystemFontOfSize:15.f];
    [_sendButton addTarget:self action:@selector(addReplyClick) forControlEvents:UIControlEventTouchDown];
    [_sendButton setTitle:LANGUAGE(@"answer") forState:UIControlStateNormal];
    [_sendButton setBackgroundColor:[UIColor ggaThemeColor]];
    [_sendButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];

    _inputField = [[UITextField alloc] initWithFrame:CGRectMake(10, 5, SCREEN_WIDTH - 76, 30)];
    _inputField.borderStyle = UITextBorderStyleRoundedRect;
    _inputField.keyboardType = UIKeyboardTypeDefault;
    _inputField.returnKeyType = UIReturnKeyDone;
    _inputField.clearButtonMode = UITextFieldViewModeWhileEditing;
    _inputField.placeholder = LANGUAGE(@"restore");
    _inputField.font = FONT(13.f);
    _inputField.autocorrectionType = UITextAutocorrectionTypeNo;
    _inputField.delegate = self;
    
    _inputView = [[UIView alloc] initWithFrame:CGRectMake(0, screenHeight - 40, SCREEN_WIDTH, 40)];
    _inputView.backgroundColor = [UIColor whiteColor];
    [_inputView addSubview:_inputField];
    [_inputView addSubview:_sendButton];

    _headerView = [[DiscussDetailHeaderView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 90)];
    _headerView.backgroundColor = [UIColor ggaUserGrayBackgroundColor];
    
    [self.view addSubview:_inputView];
    [self.view addSubview:_headerView];
    
    UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(headerClick:)];
    [_headerView addGestureRecognizer:recognizer];
    
    moreView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [moreView setCenter:CGPointMake(SCREEN_WIDTH / 2, 50)];
    [moreView startAnimating];
    
    reply_src = nMainID;
    reply_type = 0;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (articles.count > 0)
        return moreAvailable? articles.count + 1: articles.count;
    else
        return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (articles.count == indexPath.row)
        return 0.f;
    
    DiscussDetailItemData *data = [articles objectAtIndex:indexPath.row];
    return data.view.frame.size.height + 30; //5 Modified
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row >= articles.count)
    {
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"More"];
        [cell.contentView addSubview:moreView];
        
        if (!loading)
            [self performSelector:@selector(loadMore) withObject:nil afterDelay:2.f];
        
        return cell;
    }
    NSString *cellIndentifier = [NSString stringWithFormat:@"cellIdentifier"];
    DiscussDetailItemCell *cell = [[DiscussDetailItemCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIndentifier];
    DiscussDetailItemData *data = [articles objectAtIndex:indexPath.row];
    data.delegate = self;
    cell.data = data;
    cell.selectionStyle = UITableViewCellSelectionStyleBlue;

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    DiscussDetailItemCell *cell = (DiscussDetailItemCell *)[_tableView cellForRowAtIndexPath:indexPath];
    DiscussDetailItemData *data = cell.data;
    
    if (data.record.discussDeep == -1) //기본기사에 대한 투고
    {
        reply_type = 0;
        reply_src = nMainID;
    }
    else //응답기사에 대한 투고
    {
        reply_type = 1;
        reply_src = data.record.discussDetailID;
    }
    
    // 원천기사투고자얻기
    NSString *toUser = data.record.nameStr? [NSString stringWithFormat:@"%@", data.record.nameStr]: @"";
    _inputField.placeholder = [NSString stringWithFormat:@"%@%@:",LANGUAGE(@"restore"), toUser];
    
    [_inputField endEditing:YES];
}

#pragma textField delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return NO;
}

bool keyboardVisible = false;
- (void) keyboardDidShow: (NSNotification *)aNotification {
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSizeBefore = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    int keyboardHeight = kbSizeBefore.height;
    
    CGSize kbSizeAfter = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    int keyHeightAfter = kbSizeAfter.height;
    
    if (keyboardVisible && (keyHeightAfter > keyboardHeight))
    {
        keyboardHeight = keyHeightAfter - keyboardHeight;
        [UIView animateWithDuration:0.2f animations:^
         {
             CGRect frame = _inputView.frame;
             frame.origin.y -= keyboardHeight;
             _inputView.frame = frame;
             
             frame = self.tableView.frame;
             frame.size.height -= keyboardHeight;
             self.tableView.frame = frame;
         }];
        keyboardVisible = YES;
        return;
    };
    
    
    if (keyboardVisible == YES) {
        return;
    }
    
    [UIView animateWithDuration:0.2f animations:^
     {
         CGRect frame = _inputView.frame;
         frame.origin.y -= kbSizeBefore.height;
         _inputView.frame = frame;
         
         frame = self.tableView.frame;
         frame.size.height -= kbSizeBefore.height;
         self.tableView.frame = frame;
     }];
    keyboardVisible = YES;

}

- (void) keyboardDidHide: (NSNotification *)aNotification {
    
    if (keyboardVisible == NO) {
        return;
    }
    
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    [UIView animateWithDuration:0.2f animations:^
     {
         CGRect frame = _inputView.frame;
         frame.origin.y += kbSize.height;
         _inputView.frame = frame;
         
         frame = self.tableView.frame;
         frame.size.height += kbSize.height;
         self.tableView.frame = frame;
     }];
    keyboardVisible = NO;

}

#pragma Event
-(void)backToPage
{
    ggaAppDelegate *appDelegate = APP_DELEGATE;
    [appDelegate.ggaNav popViewControllerAnimated:YES];
}

#pragma Events
- (void)refresh
{
    currPageNo = 0;
    moreAvailable = NO;
    [articles removeAllObjects];
    [self loadMore];
}

#pragma UserDefinded
- (void)loadMore
{
    loading = YES;
    currPageNo ++;
    
    NSArray *array = [NSArray arrayWithObjects:[NSNumber numberWithInt:nMainID], [NSNumber numberWithInt:currPageNo], nil];
    [[HttpManager sharedInstance] getDiscussDetailWithDelegate:self data:array];
}

#pragma Events
- (void)addReplyClick
{
    if ([_inputField.text compare:@""] == NSOrderedSame) { //Added By Boss.2015/05/13
        return;
    }
    
    NSArray *data = [NSArray arrayWithObjects:_inputField.text,
                     [NSString stringWithFormat:@"%d", reply_src],
                     [NSString stringWithFormat:@"%d", reply_type], nil];
    
    [[HttpManager sharedInstance] evalDiscussWithDelegate:self data:data];
    [_inputField resignFirstResponder];
}

#pragma HttpManagerDelegate
- (void)getDiscussDetailResultWithErrorCode:(int)errorcode more:(int)more header:(NSArray *)headerData article:(NSArray *)articlesData
{
    if (errorcode > 0)
        [AlertManager AlertWithMessage:LANGUAGE([Language stringWithInteger:errorcode])];
    else
    {
        if (loading == NO)
            return;
        
        loading = NO;
        moreAvailable = more == 1;
        
        NSMutableArray *temp = [[NSMutableArray alloc] init];
        [temp addObjectsFromArray:articlesData];
        
        //첫 페지에서 상의머리부정보얻기
        if (currPageNo == 1){
            [_headerView drawHeaderWithData:[NSArray arrayWithObjects:[headerData objectAtIndex:3],
                                             [headerData objectAtIndex:1],
                                             [headerData objectAtIndex:2], nil]];
        }

        for (DiscussDetailListRecord *record in temp)
        {
            DiscussDetailItemData *data;

            //주제기사는 첫페지에서만 넣는다
            if (record.discussDeep == -1)
            {
                if (currPageNo == 1){
                    data = [[DiscussDetailItemData alloc] initWithRecord:record after:@""];
                    [articles addObject:data];
                }
                continue;
            }
            
            int n = [temp indexOfObject:record];
            NSString *majorName = [self stringMajorName:articles currentDeep:record.discussDeep toIndex:n];
            data = [[DiscussDetailItemData alloc] initWithRecord:record after:majorName];

            [articles addObject:data];
            
        }
        
        [self.tableView reloadData];
    }
}

#pragma HttpManagerDelegate
- (void)evalDiscussResultWithErrorCode:(int)errorcode data:(NSArray *)data
{
    if (errorcode > 0)
    {
        [AlertManager AlertWithMessage:LANGUAGE([Language stringWithInteger:errorcode])];
        _inputField.text = @"";
        return;
    }
    else
        [AlertManager AlertWithMessage:LANGUAGE(@"success")];
    
    NSInteger d = NSNotFound;
    NSInteger index = NSNotFound;
    
    for (DiscussDetailItemData *item in articles) {
        
        //상의주제기사사이에는 응답기사를 넣지 않는다
        if (item.record.discussDeep == -1) continue;
        
        //기본주제에 대한 응답기사는 깊이0을 가진다
        if (reply_type == 0 && d == NSNotFound){
            d = 0;
            continue;
        }
        else{
            if (item.record.discussDetailID == reply_src){ //선택된 기사
                d = item.record.discussDeep + 1;
                index = [articles indexOfObject:item];
                continue;
            }
        }
        
        if (d != NSNotFound && item.record.discussDeep < d)
        {
            index = [articles indexOfObject:item] - 1;
            break;
        }
    }
    
    DiscussDetailListRecord *record = [[DiscussDetailListRecord alloc] initWithDiscussID:[[data objectAtIndex:0] intValue]
                                                                                      userID:[[data objectAtIndex:1] intValue]
                                                                                    userName:[data objectAtIndex:2]
                                                                                     content:_inputField.text
                                                                                     replyID:[[data objectAtIndex:3] intValue]
                                                                                   replyDate:[data objectAtIndex:4]
                                                                                        deep:[[data objectAtIndex:5] intValue]];
    NSString *majorName = @"";
    
    BOOL doMarjoName = YES;
    if (index == NSNotFound)
    {
        doMarjoName = NO;
        index = [articles count] - 1;
    }
    
    DiscussDetailItemData *ddiData = [articles objectAtIndex:index];
    if (doMarjoName)
    majorName = ddiData.record.nameStr;

    DiscussDetailItemData *insertItem = [[DiscussDetailItemData alloc] initWithRecord:record after:majorName];
  
    if (d != NSNotFound && index != NSNotFound)
        [articles insertObject:insertItem atIndex:index + 1];
    else
        [articles addObject:insertItem];

    [self.tableView reloadData];
    
    _inputField.text = @"";
}

#pragma DiscussDetailItemDataDelegate
- (void)discussDetailImageClicked:(NSString *)imageUrl
{
    if (keyboardVisible)
    {
        [_inputField resignFirstResponder];
        return;
    }
    
    
    if (imageUrl == nil || [imageUrl isEqualToString:@""])
        return;
    imageForImage = [CacheManager GetCacheImageWithURL:imageUrl];
    if (!imageForImage)
    {
        [UIImage loadFromURL:[[NSURL alloc] initWithString:imageUrl] callback:^(UIImage *image)
         {
             if (image)
             {
                 [CacheManager CacheWithImage:image filename:imageUrl];
                 imageForImage = image;
             }
         }
         ];
    }
    
    MyPhoto *mp = [[MyPhoto alloc] initWithImage:imageForImage];
    MyPhotoSource *mps = [[MyPhotoSource alloc] initWithPhotos:[NSArray arrayWithObject:mp]];
    EGOPhotoViewController *epc = [[EGOPhotoViewController alloc] initWithPhotoSource:mps];
    [self.navigationController pushViewController:epc animated:YES];
}

/*
 기능: 기사가 응답하려고 하는 기본기사의 기자이르얻는 함수
 파람: array - 기사배렬, deep - 응답한 기사의 깊이, toIndex - 탐색하려는 기사의 끝인덱스
 리턴: 기자이름
 */
- (NSString *)stringMajorName:(NSArray *)array currentDeep:(int)deep toIndex:(int)toIndex
{
    NSString *ret = @"";
    for (int i = toIndex - 1; i >= 0; i --) {
        DiscussDetailItemData *data = [array objectAtIndex:i];
        DiscussDetailListRecord *record = data.record;
        
        if (record.discussDeep < deep)
        {
            ret = record.nameStr;
            break;
        }
    }
    return ret;
}

- (UIView *)overlayView:(DAOverlayView *)view didHitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
    return nil;
}

- (void)headerClick:(UITapGestureRecognizer *)recognizer
{
    [self.view endEditing:YES];
}
@end
