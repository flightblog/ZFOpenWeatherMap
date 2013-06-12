//
//  ZFInterface.h
//  ZFOpenWeatherMap
//
//  Created by apollo on 5/31/13.
//  Copyright (c) 2013 ZFOpenWeatherMap. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@protocol ZFInterfaceDelegate <NSObject>
@required
- (void)ZFInterfaceCurrentWeather:(NSDictionary *)currentWeather;
- (void)ZFInterfaceForecastWeather:(NSDictionary *)forecastWeather;
@end

@interface ZFInterface : NSObject
- (id)initWithDelegate:(id<ZFInterfaceDelegate>)delegate;
- (void)retreiveCurrentWeatherWithLocation:(CLLocation *)location APIKey:(NSString *)APIKey;
- (void)retreiveForecastWeatherWithLocation:(CLLocation *)location APIKey:(NSString *)APIKey;

@end