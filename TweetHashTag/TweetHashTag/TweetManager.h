//
//  TweetManager.h
//  TweetHashTag
//
//  Created by Kaustubh on 22/01/16.
//  Copyright © 2016 Self. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TweetManager : NSObject
+ (id)sharedInstance;
-(void)getTweetsForHashTags:(NSString*)ht Completion:(void(^)(NSMutableArray *array, NSError *error))completionBlock;
-(void)unusedFun;
//-(void)getTweetsForHashTags:(NSString*)ht Completion:(void(^)(NSMutableArray *array, NSError *error))completionBlock;
@end
