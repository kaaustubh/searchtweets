//
//  TweetManager.m
//  TweetHashTag
//
//  Created by Kaustubh on 22/01/16.
//  Copyright © 2016 Self. All rights reserved.
//

#import "TweetManager.h"
#import "Tweet.h"

#define kTweetAuthURL    @"https://api.twitter.com/oauth2/token"
#define kConsumerKey     @"jwmJw2hB5eizDKllg6OUK9kEd"
#define kConsumerSecret  @"k6j42q8sw07ykHDkbupDVmR8voCtMUyKGDx1zKCsbS7HPjxhM0"
#define kAccessToken     @"32783207-dHFTu0ndDzO0doiXZzjZ3yi50UvzDvMIzC7EhjSPo"

#define kSearchQuery     @"https://api.twitter.com/1.1/search/tweets.json?q=#%@@&result_type=recent"
#define kStatuses        @"statuses"

@interface TweetManager()
{
    
}

@property (nonatomic, strong) NSString *bearerToken;

@end

@implementation NSString (RFC3986)
- (NSString *)st_stringByAddingRFC3986PercentEscapesUsingEncoding:(NSStringEncoding)encoding {
    
    NSString *s = (__bridge_transfer NSString *)(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                                         (CFStringRef)self,
                                                                                         NULL,
                                                                                         CFSTR("!*'();:@&=+$,/?%#[]"),
                                                                                         kCFStringEncodingUTF8));
    return s;
}
@end

@implementation TweetManager

+ (id)sharedInstance {
    static TweetManager *sharedMyManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[self alloc] init];
    });
    return sharedMyManager;
}

-(void)getTweetsForHashTags:(NSString*)ht Completion:(void(^)(NSMutableArray *array, NSError *error))completionBlock
{
    if (!_bearerToken)
    {
        [self fetchBearerTokenWithCompletionBlock:^(BOOL success)
        {
            [self getTweets:ht Completion:^(NSMutableArray *tweets, NSError  *err)
            {
                if (completionBlock)
                {
                    if (err)
                    {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            completionBlock(nil, err);
                        });
                        
                    }
                    else
                    {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            completionBlock(tweets, nil);
                        });
                        
                    }
                }
                
            }];
        }];
    }
    else
    {
        [self getTweets:ht Completion:^(NSMutableArray *tweets, NSError  *err)
         {
             if (completionBlock)
             {
                 if (err)
                 {
                     dispatch_async(dispatch_get_main_queue(), ^{
                         completionBlock(nil, err);
                     });
                     
                 }
                 else
                 {
                     dispatch_async(dispatch_get_main_queue(), ^{
                         completionBlock(tweets, nil);
                     });
                     
                     
                 }
             }
         }];
    }
    
    
    
}

-(void)getTweets:(NSString*)ht Completion:(void(^)(NSMutableArray* data, NSError *error))completionBlock
{
    NSString *accessToken=[NSString stringWithFormat:@"Bearer %@", _bearerToken];
    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    sessionConfiguration.HTTPAdditionalHeaders = @{
                                                   @"Authorization"       : accessToken,
                                                   @"Content-Type"  : @"application/x-www-form-urlencoded;charset=UTF-8",
                                                   @"Accept-Encoding": @"gzip"
                                                   };
    NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfiguration];
    NSString *urlStr=[NSString stringWithFormat:kSearchQuery,ht];
    
    //[urlStr stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]];
    urlStr= [urlStr stringByReplacingOccurrencesOfString:@"#" withString:@"%23"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlStr]];
    request.HTTPMethod = @"GET";
    NSURLSessionDataTask *postDataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
    {
        NSError* jerror;
        if (error)
        {
            if (completionBlock)
            {
                completionBlock(nil, error);
            }
        }
        else
        {
            NSDictionary* json = [NSJSONSerialization JSONObjectWithData:data
                                                                 options:kNilOptions
                                                                   error:&error];
            NSArray *arrOfTweets=json[kStatuses];
            NSMutableArray *arr;
            Tweet *newTweet;
            for (NSDictionary *dict in arrOfTweets)
            {
                if (!arr)
                {
                    arr=[NSMutableArray array];
                }
                
                newTweet=[[Tweet alloc] initWithDictionary:dict];
                [arr addObject:newTweet];
            }
            if (arrOfTweets.count && completionBlock)
            {
                completionBlock(arr, nil);
            }
        }
        

        
    }];
    
    [postDataTask resume];
}



- (NSString *)encodeString:(NSString*)strToEncode st_stringByAddingRFC3986PercentEscapesUsingEncoding:(NSStringEncoding)encoding {
    
    NSString *s = (__bridge_transfer NSString *)(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                                         (CFStringRef)strToEncode,
                                                                                         NULL,
                                                                                         CFSTR("!*'();:@&=+$,/?%#[]"),
                                                                                         kCFStringEncodingUTF8));
    return s;
}

+ (NSString *)base64EncodedBearerTokenCredentialsWithConsumerKey:(NSString *)consumerKey consumerSecret:(NSString *)consumerSecret {
    NSString *encodedConsumerToken = [consumerKey st_stringByAddingRFC3986PercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *encodedConsumerSecret = [consumerSecret st_stringByAddingRFC3986PercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *bearerTokenCredentials = [NSString stringWithFormat:@"%@:%@", encodedConsumerToken, encodedConsumerSecret];
    NSData *data = [bearerTokenCredentials dataUsingEncoding:NSUTF8StringEncoding];
    return [data base64Encoding];
}


-(void)fetchBearerTokenWithCompletionBlock:(void(^)(BOOL success))completionBlock
{
    NSString *urlEncodedKey= [kConsumerKey stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]];
    NSString *urlEncodedSecret=[kConsumerSecret stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]];
    
    NSData *basicData=[[NSString stringWithFormat:@"%@:%@", urlEncodedKey, urlEncodedSecret] dataUsingEncoding:NSUTF8StringEncoding];
    
    NSMutableString *base64EncodedStr=[[basicData base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength] mutableCopy];
    base64EncodedStr=[[base64EncodedStr stringByReplacingOccurrencesOfString:@"\n" withString:@""] mutableCopy];
    base64EncodedStr=[[base64EncodedStr stringByReplacingOccurrencesOfString:@"\r" withString:@""] mutableCopy];
    NSString *authType=[[self class] base64EncodedBearerTokenCredentialsWithConsumerKey:kConsumerKey consumerSecret:kConsumerSecret];
    //[NSString stringWithFormat:@"Basic: %@", base64EncodedStr];
    authType=[NSString stringWithFormat:@"Basic %@", authType];
    
    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    sessionConfiguration.HTTPAdditionalHeaders = @{
                                                   @"Authorization"       : authType,
                                                   @"Content-Type"  : @"application/x-www-form-urlencoded;charset=UTF-8",
                                                   @"Accept-Encoding": @"gzip"
                                                   };
    NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfiguration];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:kTweetAuthURL]];
    request.HTTPBody = [@"grant_type=client_credentials" dataUsingEncoding:NSUTF8StringEncoding];
    request.HTTPMethod = @"POST";
    NSURLSessionDataTask *postDataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
    {
        if (error)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                if(completionBlock)
                    completionBlock(false);
            });
        }
        else
        {
            
            NSError* error;
            NSDictionary* json = [NSJSONSerialization JSONObjectWithData:data
                                                                 options:kNilOptions
                                                                   error:&error];
            //TODO: Check error
            _bearerToken=[json objectForKey:@"access_token"];
                if(completionBlock)
                    completionBlock(true);
        
        }
        
    }];
    [postDataTask resume];
}

@end
