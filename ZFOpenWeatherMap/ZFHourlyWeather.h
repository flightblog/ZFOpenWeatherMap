//
//  ZFHourlyWeather.h
//  ZFOpenWeatherMap
//
//  Created by apollo on 6/16/13.
//  Copyright (c) 2013 ZFOpenWeatherMap. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ZFHourlyWeatherDelegate <NSObject>
@required
- (void)ZFHourlyWeather:(NSDictionary *)currentWeather;
@end

@interface ZFHourlyWeather : NSObject
@property (nonatomic, strong)NSDictionary *hourlyWeather;

- (id)initWithDelegate:(id<ZFHourlyWeatherDelegate>)delegate;
- (void)getHourlyWeatherWithURL:(NSURL *)url;


@end
