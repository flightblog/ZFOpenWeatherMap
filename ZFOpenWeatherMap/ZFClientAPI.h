//
//  ZHFOWMClientAPI.h
//  ZHFWeatherLib
//
//  Created by apollo on 5/22/13.
//  Copyright (c) 2013 ZHFWeatherLib. All rights reserved.
//

#import "AFHTTPClient.h"

@interface ZFClientAPI : AFHTTPClient

+ (id)sharedInstance;

@end
