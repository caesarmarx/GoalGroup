//
//  DiscussDetailListRecord.h
//  GoalGroup
//
//  Created by MacMini on 3/19/15.
//  Copyright (c) 2015 KCHN. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DiscussDetailListRecord : NSObject

@property (nonatomic) int discussDeep;
@property (nonatomic) int discussDetailID;
@property (nonatomic) int userID;
@property (nonatomic) NSString *contentStr;
@property (nonatomic) NSString *dateStr;
@property (nonatomic) int replyID;
@property (nonatomic) NSString *nameStr;

@property (nonatomic) NSString *imageUrl;

- (id)initWithDiscussID:(int)discussID
                 userID:(int)u_id
               userName:(NSString *)name
                content:(NSString *)content
                replyID:(int)replay_id
              replyDate:(NSString *)date
                   deep:(int)deep;

- (id)initWithImageUrl:(NSString *)imageurl
               content:(NSString *)content;

@end
