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

@interface ZFInterface ()
@property (nonatomic, strong) id delegate;
@property (nonatomic, strong) CLLocation *location;
@property (nonatomic, copy) NSString *APIKey;
@end

@implementation ZFInterface

#pragma mark - Properties

- (id)initWithDelegate:(id<ZFInterfaceDelegate>)delegate
              location:(CLLocation *)location
                APIKey:(NSString *)APIKey
{
    self = [super init];
    if (self) {
        self.delegate = delegate;
        self.location = location;
        self.APIKey = APIKey;
    }
    return self;
}


- (void)retreiveCurrentWeather
{
    NSString *urlForCurrentWX;
    
    if (!_APIKey) {
        NSLog(@"no api key current");
        
        urlForCurrentWX = [NSString stringWithFormat:@"http://api.openweathermap.org/data/2.5/weather?lat=%f&lon=%f",
                           _location.coordinate.latitude,
                           _location.coordinate.longitude];
        
        [self getCurrentWithURL:urlForCurrentWX];
        
    } else {
        urlForCurrentWX = [NSString stringWithFormat:@"http://api.openweathermap.org/data/2.5/weather?lat=%f&lon=%f&APPID=%@",
                           _location.coordinate.latitude,
                           _location.coordinate.longitude,
                           _APIKey];
        
        [self getCurrentWithURL:urlForCurrentWX];
    }
}

- (void)retreiveForecastWeather
{
    NSString *urlForForecastWX;
    
    if (!_APIKey) {
        NSLog(@"no api key forecast");
        urlForForecastWX = [NSString stringWithFormat:@"http://api.openweathermap.org/data/2.5/forecast/daily?lat=%f&lon=%f&cnt=10&mode=json",
                            _location.coordinate.latitude,
                            _location.coordinate.longitude];
        
        [self getForecastWithURL:urlForForecastWX];
        
    } else {
        urlForForecastWX = [NSString stringWithFormat:@"http://api.openweathermap.org/data/2.5/forecast/daily?lat=%f&lon=%f&cnt=10&mode=json&APPID=%@",
                            _location.coordinate.latitude,
                            _location.coordinate.longitude,
                            _APIKey];
        
        [self getForecastWithURL:urlForForecastWX];
    }
}


- (void)getCurrentWithURL:(NSString *)currentURL
{
    NSLog(@"current %@", currentURL);

    NSURLRequest *requestOWM = [NSURLRequest requestWithURL:[NSURL URLWithString:currentURL]];
    
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

- (void)getForecastWithURL:(NSString *)forecast
{
   
    NSLog(@"forecast %@", forecast);
    
    
    NSURLRequest *requestForecast = [NSURLRequest requestWithURL:[NSURL URLWithString:forecast]];
    [AFJSONRequestOperation addAcceptableContentTypes:[NSSet setWithObjects:@"text/html", nil]];
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
