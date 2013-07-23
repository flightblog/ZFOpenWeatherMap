//
//  ZHFOWMClientAPI.m
//  ZHFWeatherLib
//
//  Created by apollo on 5/22/13.
//  Copyright (c) 2013 ZHFWeatherLib. All rights reserved.
//

#import "ZFClientAPI.h"
#import "AFNetworking.h"

NSString * const kOpenWeatherMapBaseURL = @"http://api.openweathermap.org";

@implementation ZFClientAPI

+ (instancetype)sharedInstance {
    static ZFClientAPI *__sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __sharedInstance = [[ZFClientAPI alloc] initWithBaseURL:[NSURL URLWithString:kOpenWeatherMapBaseURL]];
    });
    return __sharedInstance;
}

- (instancetype)initWithBaseURL:(NSURL *)url {
    self = [super initWithBaseURL:url];
    if (self) {
        //custom settings
        [self registerHTTPOperationClass:[AFJSONRequestOperation class]];
        [self setDefaultHeader:@"Accept" value:@"application/json"];
        [self setParameterEncoding:AFJSONParameterEncoding];
        [AFJSONRequestOperation addAcceptableContentTypes:[NSSet setWithObjects:@"text/html", nil]];
    }
    return self;
}

@end
