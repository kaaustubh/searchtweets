//
//  Tweet.m
//  TweetHashTag
//
//  Created by Kaustubh on 22/01/16.
//  Copyright © 2016 Self. All rights reserved.
//

#import "Tweet.h"

#define kText       @"text"
#define kUser       @"user"
#define kScreenName @"screen_name"

@implementation Tweet


-(id)initWithDictionary:(NSDictionary*)dict
{
    self=[super init];
    if (self)
    {
        _tweetText=dict[kText];
        _tweetUserName=[dict[kUser] objectForKey:kScreenName];
    }
    return self;
}

@end
