//
//  DiscussImageDetailViewController.m
//  GoalGroup
//
//  Created by lion on 5/7/15.
//  Copyright (c) 2015 KCHN. All rights reserved.
//

#import "DiscussImageDetailViewController.h"
#import "CacheManager.h"
#import "UIImage+Mask.h"
#import "UIImage+Web.h"
#import "Common.h"

@interface DiscussImageDetailViewController ()

@end

@implementation DiscussImageDetailViewController

+ (id)sharedInstance
{
    @synchronized(self)
    {
        if (gDiscussImageDetailViewController == nil)
            gDiscussImageDetailViewController = [[DiscussImageDetailViewController alloc] init];
    }
    return gDiscussImageDetailViewController;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        [self layoutComponents];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor ggaGrayBackColor];
	// Do any additional setup after loading the view.
#ifdef IOS_VERSION_7
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)])
        self.edgesForExtendedLayout = UIRectEdgeNone;
#endif
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)layoutComponents
{
    imageView = [[UIImageView alloc] init];
    [self.view addSubview:imageView];
    
    UIView *backButtonRegion = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 48, 24)];
    UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(18, 1, 11, 19)]; //Modified By Boss.2015/05/02
    [backButton setImage:[UIImage imageNamed:@"move_forward"] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(backToPage) forControlEvents:UIControlEventTouchDown];
    [backButtonRegion addSubview:backButton];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButtonRegion];

}
- (void)drawDiscussImageWithUrl:(NSString *)imageUrl
{
    imageView.hidden = YES;
    
    imageView.image = [CacheManager GetCacheImageWithURL:imageUrl];
    if (!imageView.image)
    {
        [UIImage loadFromURL:[[NSURL alloc] initWithString:imageUrl] callback:^(UIImage *image)
        {
            if (image)
            {
                [CacheManager CacheWithImage:image filename:imageUrl];
                imageView.image = image;
            }
        }
        ];
    }
    
    int nImgHeight = [imageView.image size].height;
    int nImgWidth = [imageView.image size].width;
    int nScrHeight = SCREEN_HEIGHT - 40 - self.navigationController.navigationBar.bounds.size.height;
    
    if (nScrHeight < nImgHeight || SCREEN_WIDTH < nImgWidth )
    {
        nImgWidth = SCREEN_WIDTH;
        nImgHeight = nScrHeight;
        imageView.image = [imageView.image imageByScalingAndCroppingForSize:CGSizeMake(nImgWidth, nImgHeight)];
    }

    imageView.frame = CGRectMake((SCREEN_WIDTH - nImgWidth) / 2, 20+ self.navigationController.navigationBar.bounds.size.height, nImgWidth, nImgHeight);
    imageView.hidden = NO;

}

- (void)backToPage
{
    [Common BackToPage];
}
@end
