//
//  ZFInterface.m
//  ZFOpenWeatherMap
//
//  Created by apollo on 5/31/13.
//  Copyright (c) 2013 ZFOpenWeatherMap. All rights reserved.
//

#import "ZFInterface.h"
#import "AFNetworking.h"
#import "ZFClientAPI.h"

NSString * const kAPIKey = @"d8b388ec6f9916315e29eb7f0ba64683";
NSString * const kCurrentWithAPI = @"http://api.openweathermap.org/data/2.3/find/city?lat=%f&lon=%f&APPID=%@";
NSString * const kCurrentWithoutAPI = @"http://api.openweathermap.org/data/2.3/find/city?lat=%f&lon=%f";

@interface ZFInterface ()
@property (nonatomic, strong) id delegate;
@end

@implementation ZFInterface

#pragma mark - Properties

- (id)initWithDelegate:(id<ZFInterfaceDelegate>)delegate
{
    self = [super init];
    if (self) {
        self.delegate = delegate;
    }
    return self;
}


- (void)retreiveCurrentWeatherWithLocation:(CLLocation *)location APIKey:(NSString *)APIKey
{
    NSString *urlForCurrentWX;
    
    if (!APIKey) {
        NSLog(@"no api key current");
        
        urlForCurrentWX = [NSString stringWithFormat:@"http://api.openweathermap.org/data/2.3/find/city?lat=%f&lon=%f",
                           location.coordinate.latitude,
                           location.coordinate.longitude];
    } else {
        urlForCurrentWX = [NSString stringWithFormat:@"http://api.openweathermap.org/data/2.3/find/city?lat=%f&lon=%f&APPID=%@",
                           location.coordinate.latitude,
                           location.coordinate.longitude,
                           kAPIKey];
    }
    
    
    NSURLRequest *requestOWM = [NSURLRequest requestWithURL:[NSURL URLWithString:urlForCurrentWX]];
    
    [AFJSONRequestOperation addAcceptableContentTypes:[NSSet setWithObjects:@"text/html", nil]];
    AFJSONRequestOperation *operationCurrent = [AFJSONRequestOperation JSONRequestOperationWithRequest:requestOWM
                                                                                               success:^(NSURLRequest *requestOWM, NSHTTPURLResponse *response2, id responseJSONOWM) {
                                                                                                   //NSLog(@"current %@", [NSDictionary dictionaryWithDictionary:responseJSONOWM]);
        if ([_delegate respondsToSelector:@selector(ZFInterfaceCurrentWeather:)]) {
            [_delegate ZFInterfaceCurrentWeather:[NSDictionary dictionaryWithDictionary:responseJSONOWM]];
        }
                                                                                                   
                                                                                               }
                                                                                               failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                                                                                                   NSLog(@"%@", [error userInfo]);
                                                                                               }];
    [operationCurrent start];
}

- (void)retreiveForecastWeatherWithLocation:(CLLocation *)location APIKey:(NSString *)APIKey
{
    NSString *urlForForecastWX;
    
    if (!APIKey) {
        NSLog(@"no api key forecast");
        
        urlForForecastWX = [NSString stringWithFormat:@"http://api.openweathermap.org/forecast/city?lat=%f&lon=%f?mode=daily_compact",
                            location.coordinate.latitude,
                            location.coordinate.longitude];
    } else {
        urlForForecastWX = [NSString stringWithFormat:@"http://api.openweathermap.org/forecast/city?lat=%f&lon=%f?mode=daily_compact&APPID=%@",
                            location.coordinate.latitude,
                            location.coordinate.longitude,
                            kAPIKey];
    }
    
    
    NSString *urlOWMForecast = [NSString stringWithFormat:@"http://api.openweathermap.org/data/2.3/find/city?lat=%f&lon=%f&APPID=%@",
                                location.coordinate.latitude,
                                location.coordinate.longitude,
                                kAPIKey];
    
    NSURLRequest *requestForecast = [NSURLRequest requestWithURL:[NSURL URLWithString:urlOWMForecast]];
    
    AFJSONRequestOperation *operationForecast = [AFJSONRequestOperation JSONRequestOperationWithRequest:requestForecast
                                                                                                success:^(NSURLRequest *requestOWM, NSHTTPURLResponse *response2, id responseJSONOWM) {
                                                                                                    //NSLog(@"forecast %@", responseJSONOWM);
                                                                                                    
                if ([self.delegate respondsToSelector:@selector(ZFInterfaceForecastWeather:)]) {
                    [self.delegate ZFInterfaceForecastWeather:responseJSONOWM];
                }
                                                                                                    
                                                                                                }
                                                                                                failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                                                                                                    NSLog(@"%@", [error userInfo]);
                                                                                                }];
    [operationForecast start];
}

@end
