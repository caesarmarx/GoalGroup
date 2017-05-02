//
//  MakingDiscussController.m
//  GoalGroup
//
//  Created by KCHN on 2/25/15.
//  Copyright (c) 2015 KCHN. All rights reserved.
//

#import "MakingDiscussController.h"
#import <MobileCoreServices/UTCoreTypes.h>
#import "Common.h"
#import "Utils.h"
#import "Constants.h"
#import "HttpRequest.h"
#import "JSON.h"

@interface MakingDiscussController ()
{
    UIImagePickerController *imagePicker;
    UIScrollView *contentView;
    int itemCount;
    int httpImgCount;
}
@end

@implementation MakingDiscussController

- (id)initWithDelegate:(id<MakingDiscussControllerDelegate>)delegate
{
    self.delegate = delegate;
    return [self init];
}
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = LANGUAGE(@"MakingDiscussController Title");
        self.view.backgroundColor = [UIColor ggaGrayBackColor];
        
        UIView *backButtonRegion = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 48, 24)];
        UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(8, -4, 30, 30)]; //Modified By Boss.2015/05/02
        [backButton setImage:[UIImage imageNamed:@"move_forward"] forState:UIControlStateNormal];

        [backButton addTarget:self action:@selector(backToPage) forControlEvents:UIControlEventTouchDown];
        [backButtonRegion addSubview:backButton];
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButtonRegion];
        
        UIView *makingButtonRegion = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 48, 24)];
        UIButton *makingButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 48, 24)];
        [makingButton setTitle:LANGUAGE(@"ANNOUNCE") forState:UIControlStateNormal];
        makingButton.titleLabel.font = FONT(14.f);
        [makingButton addTarget:self action:@selector(makingDiscuss) forControlEvents:UIControlEventTouchDown];
        [makingButtonRegion addSubview:makingButton];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:makingButtonRegion];
        
        contentView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - 70)];
        contentView.contentSize= CGSizeMake(SCREEN_WIDTH, 500);
        contentView.backgroundColor = [UIColor ggaGrayBackColor];
        [self.view addSubview:contentView];
        
        MakingDiscussItemView *itemView1 = [[MakingDiscussItemView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 100) WithItemID:0 withDelegate:self];
        itemView1.tag = DISCUSSITEM_TAG;
        itemView1.backgroundColor = [UIColor ggaGrayBackColor];
        [contentView addSubview:itemView1];
        
        imagePicker = [[UIImagePickerController alloc] init];
        itemCount = 0;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
#ifdef IOS_VERSION_7
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)]) //iOS7
        self.edgesForExtendedLayout = UIRectEdgeNone;
#endif

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma Users
- (void)backToPage
{
    ggaAppDelegate *appDelegate = APP_DELEGATE;
    [appDelegate.ggaNav popViewControllerAnimated:YES];
}

#pragma MakingDiscussItemViewDelegate
- (void)nonEmptyItemView:(int)itemID
{
    MakingDiscussItemView *itemView = (MakingDiscussItemView *)[self.view viewWithTag:DISCUSSITEM_TAG + itemID + 1];
    
    if (itemView == nil)
    {
        itemView = [[MakingDiscussItemView alloc] initWithFrame:CGRectMake(0, (itemID + 1) * 100 , SCREEN_WIDTH, 100) WithItemID:itemID + 1 withDelegate:self];
        
        itemView.tag = DISCUSSITEM_TAG + itemID + 1;
        itemView.backgroundColor = [UIColor ggaGrayBackColor];
        [contentView addSubview:itemView];
        
        itemCount ++;
        return;
    }
    
    if (itemView.isHidden)
        itemView.hidden = NO;
}

#pragma MakingDiscussItemViewDelegate
- (void)emptyItemView:(int)itemID
{
    for (int i = itemID; i < itemCount; i ++)
    {
        MakingDiscussItemView *itemView = (MakingDiscussItemView *)[self.view viewWithTag:DISCUSSITEM_TAG +i + 1];
        
        if (itemView != nil) {
            itemView.hidden = YES;
        }
    }
}

#pragma MakingDiscussItemViewDelegate
- (void)beginEditingItemView:(int)itemID
{
//    [UIView beginAnimations:nil context:NULL];
//    [UIView setAnimationDelegate:self];
//    [UIView setAnimationDuration:0.5];
//    [UIView setAnimationBeginsFromCurrentState:YES];
//    self.view.frame = CGRectMake(self.view.frame.origin.x, (self.view.frame.origin.y - 70), self.view.frame.size.width, self.view.frame.size.height);
//    [UIView commitAnimations];
}

#pragma MakingDiscussItemViewDelegate
- (void)takePhotoClickItemView:(int)itemID
{
    selectedItem = itemID;
    UIActionSheet *mNewActionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:nil
                                                        cancelButtonTitle:LANGUAGE(@"cancel")
                                                   destructiveButtonTitle:nil
                                                        otherButtonTitles:LANGUAGE(@"Take Photo or Video"),
                                      LANGUAGE(@"Choose From Library"), nil];
    
    mNewActionSheet.actionSheetStyle = UIActionSheetStyleDefault;
    mNewActionSheet.delegate = self;
    [mNewActionSheet showInView:self.view];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}
- (void)makingDiscuss
{
    for (int i = 0; i < itemCount; i ++) {
        MakingDiscussItemView *itemView = (MakingDiscussItemView *)[self.view viewWithTag:DISCUSSITEM_TAG + i];
        
        if (itemView == nil || itemView.isHidden)
        {
            continue;
        }
        else
        {
            if ([itemView discussImage] == nil)
            {
                itemView.serverName = @"";
                return;
            }
            
            NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
            [param setObject:[itemView discussImage] forKey:@"image"];
            [param setObject:[NSNumber numberWithInt:i] forKey:@"server_idx"];
            
            [self loadImage:param];
            
            httpImgCount ++;
        }
    }
    
    if (httpImgCount == 0)
        [self createClubHttp];
}


#pragma HttpManagerDelegate
- (void)createDiscussResultWithErrorCode:(int)errorcode
{
    if (errorcode > 0)
        [AlertManager AlertWithMessage:LANGUAGE([Language stringWithInteger:errorcode])];
    else
        [AlertManager AlertWithMessage:LANGUAGE(@"DISCUSS MAKE SUCCESS") tag:1001 delegate:self];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 1001)
        [self.delegate makingDiscussSuccess];
}
#pragma UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0:
            [self takeFromCamera];
            break;
        case 1:
            [self chooseFromLibrary];
            break;
        default:
            break;
    }
}

#pragma mark Select Photo Functions
- (void) takeFromCamera
{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] == NO)
    {
        [AlertManager AlertWithMessage:LANGUAGE(@"cannot use camera")];
        return;
    }
    
    UIImagePickerController *cameraController = [[UIImagePickerController alloc] init];
    cameraController.delegate = self;
    cameraController.allowsEditing = NO;
    cameraController.sourceType = UIImagePickerControllerSourceTypeCamera;
    cameraController.mediaTypes = [NSArray arrayWithObjects:
                                   (NSString *) kUTTypeImage,
                                   nil];
    
    [self.navigationController presentViewController:cameraController animated:YES completion:nil];
    
}

- (void) chooseFromLibrary
{
    
    UIImagePickerController *libraryController = [[UIImagePickerController alloc] init];
    libraryController.delegate = self;
    libraryController.allowsEditing = NO;
    libraryController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    libraryController.mediaTypes = [NSArray arrayWithObjects:
                                    (NSString *) kUTTypeImage,
                                    nil];
    
    [self presentViewController:libraryController animated:YES completion:nil];
    
}

- (void)dismissImagePickerView:(UIImagePickerController *)picker
{
    //[photoFrameImageView setHidden:NO];
    [picker dismissViewControllerAnimated:NO completion:nil];
}

- (void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSString *type = [info objectForKey:UIImagePickerControllerMediaType];
    [picker dismissViewControllerAnimated:YES completion:nil];
    if ([type isEqualToString:(NSString *)kUTTypeImage])
    {
        
        UIImage *photoImage = picker.allowsEditing? [info objectForKey:UIImagePickerControllerEditedImage]:[info objectForKey:UIImagePickerControllerOriginalImage];
        if(photoImage == nil)
            return;
        
        MakingDiscussItemView *itemView = (MakingDiscussItemView *)[self.view viewWithTag:DISCUSSITEM_TAG + selectedItem];
        [itemView setImage:photoImage];
        
    }
}

- (void) loadImage:(NSMutableDictionary *)param
{
    
    if(param == nil)
    {
        return;
    }
    
    UIImage *image = [param objectForKey:@"image"];
    
    if(image == nil)
    {
        return;
    }
    
    image = [Utils rotateImage:image];
    
    NSString *savedFilePath = [self stringSavedPhoto:image];
    if(savedFilePath == nil)
    {
        return;
    }
    
    NSString *strUrl = [NSString stringWithFormat:FILE_UPLOAD_URL,SERVER_IP_ADDRESS, _PORT];
    
    NSURL *url = [NSURL URLWithString:strUrl];
    
    ggaAppDelegate *appDelegate = (ggaAppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.httpClientForUpload.delegate = self;
    HttpRequest *httpRequest = [[HttpRequest alloc] init];
    httpRequest.type = 1;
    httpRequest.addImg = savedFilePath;
    [httpRequest requestUploadContent : 0];
}

#pragma mark UIImagePickerControllerDelegate
- (NSString *) stringSavedPhoto:(UIImage *)image
{
    NSString *fileName = [Utils uuid];
    fileName = [fileName stringByReplacingOccurrencesOfString:@"-" withString:@""];
    
    NSString *filePath = [FileManager GetImageFilePath:fileName];
    NSData *imageData = UIImageJPEGRepresentation(image, 0.1);
    
    if([imageData writeToFile:filePath atomically:YES] == NO)
        return nil;
    
    return filePath;
}

- (void)requestSucceeded:(NSString *)data {
    
    NSDictionary *jsonValues = [data JSONValue];
    NSInteger success = [[jsonValues objectForKey:PARAM_KEY_SUCCESS] integerValue];
    NSString *img_name = [jsonValues objectForKey:PARAM_KEY_SERVER_FILE_PATH];
    int serverIndex = [[jsonValues objectForKey:PARAM_KEY_SERVER_IDX] intValue];
    
    if(success == 0)
        return;
    
     MakingDiscussItemView *itemView = (MakingDiscussItemView *)[self.view viewWithTag:DISCUSSITEM_TAG + serverIndex];
    itemView.serverName = img_name;
    
    httpImgCount --;
    
    if (httpImgCount == 0)
        [self createClubHttp];
}

- (void)createClubHttp
{
    NSMutableArray *array = [[NSMutableArray alloc] init];
    for (int i = 0; i < itemCount; i ++) {
        MakingDiscussItemView *itemView = (MakingDiscussItemView *)[self.view viewWithTag:DISCUSSITEM_TAG + i];
        
        if (itemView == nil || itemView.isHidden)
            continue;
        else
        {
            [array addObject:itemView.serverName];
            [array addObject:[itemView discussContent]];
        }
    }
    
    [[HttpManager sharedInstance] createDiscussWithDelegate:self data:array];
    
}

@end
