//
//  IconDownloader.h
//  VisibleGains
//
//  Created by System Administrator on 1/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ChatMessage.h"

@protocol IconDownloaderDelegate;

@interface IconDownloader : NSObject {
    ChatMessage                                             *chatmessage;
    NSIndexPath                                             *indexPathInTableView;
    id <IconDownloaderDelegate>                             delegate;
    
    NSMutableData                                           *activeDownload;
    NSURLConnection                                         *imageConnection;
}

@property (nonatomic, retain) ChatMessage                   *chatmessage;
//@property (nonatomic, retain) NSIndexPath                   *indexPathInTableView;
@property (nonatomic, retain) id <IconDownloaderDelegate>   delegate;

@property (nonatomic, retain) NSMutableData                 *activeDownload;
@property (nonatomic, retain) NSURLConnection               *imageConnection;
@property (nonatomic, retain) UIImage                       *image;

- (void)startDownload;
- (void)cancelDownload;

@end

@protocol IconDownloaderDelegate 

- (void)iconImageDidLoad:(UIImage *)image;

@end
