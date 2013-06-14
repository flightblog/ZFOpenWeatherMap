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
@property (nonatomic, copy) NSArray *paths;
@property (nonatomic, strong) CLLocation *location;
@property (nonatomic, copy) NSString *APIKey;

@property (nonatomic, copy) NSString *urlForCurrentWXwithAPIKey;
@property (nonatomic, copy) NSString *urlForCurrentWXwithoutAPIKey;
@property (nonatomic, copy) NSString *urlForForecastWXwithAPIKey;
@property (nonatomic, copy) NSString *urlForForecastWXwithoutAPIKey;
@end

@implementation ZFInterface

#pragma mark - Properties

- (NSArray *)paths
{
    if (!_paths) {
        _paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory , NSUserDomainMask, YES);
    }
    return _paths;
}

#pragma mark - URLs

- (NSString *)urlForCurrentWXwithAPIKey
{
    if (!_urlForCurrentWXwithAPIKey) {
        _urlForCurrentWXwithAPIKey = [NSString stringWithFormat:@"http://api.openweathermap.org/data/2.5/weather?lat=%f&lon=%f&APPID=%@",
                                      _location.coordinate.latitude,
                                      _location.coordinate.longitude,
                                      _APIKey];
    }
    return _urlForCurrentWXwithAPIKey;
}

- (NSString *)urlForCurrentWXwithoutAPIKey
{
    if (!_urlForCurrentWXwithoutAPIKey) {
        _urlForCurrentWXwithoutAPIKey = [NSString stringWithFormat:@"http://api.openweathermap.org/data/2.5/weather?lat=%f&lon=%f",
                                         _location.coordinate.latitude,
                                         _location.coordinate.longitude];
    }
    return _urlForCurrentWXwithoutAPIKey;
}

- (NSString *)urlForForecastWXwithAPIKey
{

    if (!_urlForForecastWXwithAPIKey) {
        _urlForForecastWXwithAPIKey = [NSString stringWithFormat:@"http://api.openweathermap.org/data/2.5/forecast/daily?lat=%f&lon=%f&cnt=10&mode=json&APPID=%@",
                                       _location.coordinate.latitude,
                                       _location.coordinate.longitude,
                                       _APIKey];
    }
    return _urlForForecastWXwithAPIKey;
}

- (NSString *)urlForForecastWXwithoutAPIKey
{
    if (!_urlForForecastWXwithoutAPIKey) {
        _urlForForecastWXwithoutAPIKey = [NSString stringWithFormat:@"http://api.openweathermap.org/data/2.5/forecast/daily?lat=%f&lon=%f&cnt=10&mode=json",
                                          _location.coordinate.latitude,
                                          _location.coordinate.longitude];
    }
    return _urlForForecastWXwithoutAPIKey;
}

#pragma mark - NSObject

- (id)initWithDelegate:(id<ZFInterfaceDelegate>)delegate
              location:(CLLocation *)location
                APIKey:(NSString *)APIKey
{
    self = [super init];
    if (self) {
        self.delegate = delegate;
        self.location = location;
        self.APIKey = APIKey;
        self.weatherCacheInSeconds = 100;
    }
    return self;
}


#pragma mark - Retrieve Weather Methods

- (void)retreiveCurrentWeather
{
    // Retrieve currentWX JSON from disk
    NSString *cachedWX = [[self.paths objectAtIndex:0] stringByAppendingPathComponent:@"currentJSON.plist"];
    
    if (![NSDictionary dictionaryWithContentsOfFile:cachedWX]) {
        NSLog(@"no current cache");
        
        if (!_APIKey) {
            [self getCurrentWithURL:self.urlForCurrentWXwithoutAPIKey];
        } else {
            [self getCurrentWithURL:self.urlForCurrentWXwithAPIKey];
        }
        
    } else {
        int cacheUnixTimestamp = [[[NSDictionary dictionaryWithContentsOfFile:cachedWX] objectForKey:@"dt"] intValue];
        NSTimeInterval timeInterval = (NSTimeInterval)cacheUnixTimestamp;
        NSDate *reportTimeStamp = [NSDate dateWithTimeIntervalSince1970:timeInterval];
        NSDate *now = [NSDate new];
        NSTimeInterval diff = [now timeIntervalSinceDate:reportTimeStamp];
        
        NSLog(@"current cache:%@ now:%@ diff:%f", reportTimeStamp, now, diff);
        
        if (diff > 1800) {
            NSLog(@"greater then 1800");
            
            if (!_APIKey) {
                [self getCurrentWithURL:self.urlForCurrentWXwithoutAPIKey];
            } else {
                [self getCurrentWithURL:self.urlForCurrentWXwithAPIKey];
            }
        } else {
            NSLog(@"less than 1800");
            if ([_delegate respondsToSelector:@selector(ZFInterfaceCurrentWeather:)]) {
                [_delegate ZFInterfaceCurrentWeather:[NSDictionary dictionaryWithDictionary:[NSDictionary dictionaryWithContentsOfFile:cachedWX]]];
            }
        }
    }
}

- (void)retreiveForecastWeather
{
    // Retrieve forecastWX JSON from disk
    NSString *cachedWX = [[self.paths objectAtIndex:0] stringByAppendingPathComponent:@"forecastJSON.plist"];
    
    if (![NSDictionary dictionaryWithContentsOfFile:cachedWX]) {
        NSLog(@"no forecast cache");
        
        if (!_APIKey) {
            [self getCurrentWithURL:self.urlForCurrentWXwithoutAPIKey];
        } else {
            [self getCurrentWithURL:self.urlForCurrentWXwithAPIKey];
        }
        
    } else {
        int cacheUnixTimestamp = [[[NSDictionary dictionaryWithContentsOfFile:cachedWX] objectForKey:@"dt"] intValue];
        NSTimeInterval timeInterval = (NSTimeInterval)cacheUnixTimestamp;
        NSDate *reportTimeStamp = [NSDate dateWithTimeIntervalSince1970:timeInterval];
        NSDate *now = [NSDate new];
        NSTimeInterval diff = [now timeIntervalSinceDate:reportTimeStamp];
        
        NSLog(@"forecast cache:%@ now:%@ diff:%f", reportTimeStamp, now, diff);
        
        if (diff > 1800) {
            NSLog(@"greater then 1800");
            
            if (!_APIKey) {
                [self getForecastWithURL:self.urlForCurrentWXwithoutAPIKey];
            } else {
                [self getForecastWithURL:self.urlForCurrentWXwithAPIKey];
            }
        } else {
            NSLog(@"less than 1800");
            if ([_delegate respondsToSelector:@selector(ZFInterfaceCurrentWeather:)]) {
                [_delegate ZFInterfaceCurrentWeather:[NSDictionary dictionaryWithDictionary:[NSDictionary dictionaryWithContentsOfFile:cachedWX]]];
            }
        }
    }
}

#pragma mark - Network Connections

- (void)getCurrentWithURL:(NSString *)currentURL
{
//    NSLog(@"current %@", currentURL);

    NSURLRequest *requestOWM = [NSURLRequest requestWithURL:[NSURL URLWithString:currentURL]];
    
    [AFJSONRequestOperation addAcceptableContentTypes:[NSSet setWithObjects:@"text/html", nil]];
    AFJSONRequestOperation *operationCurrent = [AFJSONRequestOperation JSONRequestOperationWithRequest:requestOWM
                                                                                               success:^(NSURLRequest *requestOWM, NSHTTPURLResponse *response2, id responseJSONOWM) {
                                                                                                   //NSLog(@"current %@", [NSDictionary dictionaryWithDictionary:responseJSONOWM]);
                                                                                                   
                                                                                                   // write to disk
                                                                                                   NSString *documentsDir = [self.paths objectAtIndex:0];
                                                                                                   NSString *fullPath = [documentsDir stringByAppendingPathComponent:@"currentJSON.plist"];
                                                                                                   [responseJSONOWM writeToFile:fullPath  atomically:YES];
                                                                                                   
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
   
//    NSLog(@"forecast %@", forecast);
    
    
    NSURLRequest *requestForecast = [NSURLRequest requestWithURL:[NSURL URLWithString:forecast]];
    [AFJSONRequestOperation addAcceptableContentTypes:[NSSet setWithObjects:@"text/html", nil]];
    AFJSONRequestOperation *operationForecast = [AFJSONRequestOperation JSONRequestOperationWithRequest:requestForecast
                                                                                                success:^(NSURLRequest *requestOWM, NSHTTPURLResponse *response2, id responseJSONOWM) {
                                                                                                    //NSLog(@"forecast %@", responseJSONOWM);
                                                                                                   
                                                                                                    // write to disk
                                                                                                    NSString *documentsDir = [self.paths objectAtIndex:0];
                                                                                                    NSString *fullPath = [documentsDir stringByAppendingPathComponent:@"forecastJSON.plist"];
                                                                                                    [responseJSONOWM writeToFile:fullPath  atomically:YES];
                                                                                                    
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
