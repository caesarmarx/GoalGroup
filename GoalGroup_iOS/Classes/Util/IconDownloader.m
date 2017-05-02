//
//  IconDownloader.m
//  VisibleGains
//
//  Created by System Administrator on 1/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "IconDownloader.h"

#define kAppIconHeight 60

@implementation IconDownloader

@synthesize chatmessage;
//@synthesize indexPathInTableView;
@synthesize delegate;
@synthesize activeDownload;
@synthesize imageConnection, image;



- (void)startDownload
{
    self.activeDownload = [NSMutableData data];
    // alloc+init and start an NSURLConnection; release on completion/failure
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:
                             [NSURLRequest requestWithURL:
                              [NSURL URLWithString:chatmessage.thumbImageUrl]] delegate:self];
    self.imageConnection = conn;
    NSLog(@"%@: %@", @"thumbImageUrl",chatmessage.thumbImageUrl);

//    [conn release];
}

- (void)cancelDownload
{
    [self.imageConnection cancel];
    self.imageConnection = nil;
    self.activeDownload = nil;
}

#pragma mark -
#pragma mark Download support (NSURLConnectionDelegate)

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [self.activeDownload appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	// Clear the activeDownload property to allow later attempts
    self.activeDownload = nil;
    
    // Release the connection now that it's finished
    self.imageConnection = nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    // Set appIcon and clear temporary data/image
    UIImage *image = [[UIImage alloc] initWithData:self.activeDownload];
    
//    if (image.size.width != kAppIconHeight && image.size.height != kAppIconHeight)
//	{
//        CGSize itemSize = CGSizeMake(kAppIconHeight, kAppIconHeight);
//		UIGraphicsBeginImageContext(itemSize);
//		CGRect imageRect = CGRectMake(0.0, 0.0, itemSize.width, itemSize.height);
//		[image drawInRect:imageRect];
//		self.chatmessage.contentIcon = UIGraphicsGetImageFromCurrentImageContext();
//		UIGraphicsEndImageContext();
//    }
//    else
//    {
        self.chatmessage.contentIcon = image;
//    }
    
    self.activeDownload = nil;
    //[image release];
    
    // Release the connection now that it's finished
    self.imageConnection = nil;
    
    // call our delegate and tell it that our icon is ready for display
    [delegate iconImageDidLoad:self.chatmessage.contentIcon];
}

@end
