//
//  ZFHourlyWeather.m
//  ZFOpenWeatherMap
//
//  Created by apollo on 6/16/13.
//  Copyright (c) 2013 ZFOpenWeatherMap. All rights reserved.
//

#import "ZFHourlyWeather.h"
#import "AFNetworking.h"
#import "ZFClientAPI.h"

@interface ZFHourlyWeather ()
@property (nonatomic, strong) id delegate;
@property (nonatomic, copy) NSArray *paths;
@end


@implementation ZFHourlyWeather

#pragma mark - Properties

- (NSArray *)paths
{
    if (!_paths) {
        _paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory , NSUserDomainMask, YES);
    }
    return _paths;
}

- (id)initWithDelegate:(id<ZFHourlyWeatherDelegate>)delegate
{
    self = [super init];
    if (self) {
        self.delegate = delegate;
    }
    return self;
}

- (void)getHourlyWeatherWithURL:(NSURL *)url
{

    NSLog(@"current %@", url);
    
    NSURLRequest *requestOWM = [NSURLRequest requestWithURL:url];
    
    [AFJSONRequestOperation addAcceptableContentTypes:[NSSet setWithObjects:@"text/html", nil]];
    AFJSONRequestOperation *operationCurrent = [AFJSONRequestOperation JSONRequestOperationWithRequest:requestOWM
                                                                                               success:^(NSURLRequest *requestOWM, NSHTTPURLResponse *response2, id responseJSONOWM) {
                                                                                                   //NSLog(@"houly %@", [NSDictionary dictionaryWithDictionary:responseJSONOWM]);
                                                                                                   
                                                                                                   // write to disk
                                                                                NSString *documentsDir = [self.paths objectAtIndex:0];
                                                                                NSString *fullPath = [documentsDir stringByAppendingPathComponent:@"hourlyJSON.plist"];
                                                                                [responseJSONOWM writeToFile:fullPath  atomically:YES];
                                                                                                   
                                                                                                   
                                                                                                   
                                                        if ([_delegate respondsToSelector:@selector(ZFHourlyWeather:)]) {
                                                            [_delegate ZFHourlyWeather:[NSDictionary dictionaryWithDictionary:responseJSONOWM]];
                                                                                                   }
                                                                                                   
                                                                                               }
                                                                                               failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                                                                                                   NSLog(@"%@", [error userInfo]);
                                                                                               }];
    [operationCurrent start];
    
}

@end
