//
//  Tweet.h
//  TweetHashTag
//
//  Created by Kaustubh on 22/01/16.
//  Copyright © 2016 Self. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Tweet : NSObject

-(id)initWithDictionary:(NSDictionary*)dict;

@property (nonatomic, strong, readonly) NSString *tweetText;
@property (nonatomic, strong, readonly) NSString *tweetUserName;

@end
