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
@optional
- (void)ZFInterfaceCurrentWeather:(NSDictionary *)currentWeather;
- (void)ZFInterfaceForecastWeather:(NSDictionary *)forecastWeather;
@end

@interface ZFInterface : NSObject
@property int cacheInSeconds;

- (instancetype)initWithDelegate:(id<ZFInterfaceDelegate>)delegate
              location:(CLLocation *)location
                APIKey:(NSString *)APIKey;

- (void)retreiveCurrentWeather;
- (void)retreiveForecastWeather;

@end