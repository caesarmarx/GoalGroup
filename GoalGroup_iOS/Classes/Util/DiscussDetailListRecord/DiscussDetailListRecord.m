//
//  DiscussDetailListRecord.m
//  GoalGroup
//
//  Created by MacMini on 3/19/15.
//  Copyright (c) 2015 KCHN. All rights reserved.
//

#import "DiscussDetailListRecord.h"


@implementation DiscussDetailListRecord

@synthesize discussDeep = _discussDeep;
@synthesize discussDetailID = _discussDetailID;
@synthesize userID = _userID;
@synthesize contentStr = _contentStr;
@synthesize dateStr = _dateStr;
@synthesize replyID = _replyID;
@synthesize nameStr = _nameStr;
@synthesize imageUrl = _imageUrl;


- (id)initWithImageUrl:(NSString *)imageurl content:(NSString *)content
{
    self.imageUrl = imageurl;
    self.contentStr = content;
    self.discussDeep = -1;
    return [self init];
}

- (id)initWithDiscussID:(int)discussID userID:(int)u_id userName:(NSString *)name content:(NSString *)content replyID:(int)replay_id replyDate:(NSString *)date deep:(int)deep
{
    self.discussDetailID = discussID;
    self.discussDeep = deep;
    self.userID = u_id;
    self.nameStr = name;
    self.contentStr = content;
    self.replyID = replay_id;
    self.dateStr = date;
    return [self init];
}
@end
