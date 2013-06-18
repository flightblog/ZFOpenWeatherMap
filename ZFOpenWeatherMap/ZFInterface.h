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
- (void)ZFInterfaceHourlyWeather:(NSDictionary *)hourlyWeather;
@end

@interface ZFInterface : NSObject
@property int cacheInSeconds;


/**
 * Request the daily forecast for the give location and time
 *
 * @param lat The latitude of the location.
 * @param long The longitude of the location.
 * @param time The desired time of the forecast
 * @param success A block object to be executed when the operation finishes successfully.
 * @param failure A block object to be executed when the operation finishes unsuccessfully.
 *
 * @discussion for many locations, it can be 60 years in the past to 10 years in the future.
 */
- (id)initWithDelegate:(id<ZFInterfaceDelegate>)delegate
              location:(CLLocation *)location
                APIKey:(NSString *)APIKey;

- (void)retreiveCurrentWeather;
- (void)retreiveForecastWeather;
- (void)retreiveHourlyWeather;

@end