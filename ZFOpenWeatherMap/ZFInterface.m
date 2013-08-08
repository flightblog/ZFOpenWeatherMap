//
//  ZFOpenWeatherMap
//
//  Copyright © 2012 Steve Foster <foster@flightblog.org>
//
//  Permission is hereby granted, free of charge, to any person obtaining
//  a copy of this software and associated documentation files (the “Software”),
//  to deal in the Software without restriction, including without limitation the
//  rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is furnished
//  to do so, subject to the following conditions:

//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.

//  THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
//  INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
//  PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
//  HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF
//  CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE
//  OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

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

- (instancetype)initWithDelegate:(id<ZFInterfaceDelegate>)delegate
              location:(CLLocation *)location
                APIKey:(NSString *)APIKey
{
    self = [super init];
    if (self) {
        self.delegate = delegate;
        self.location = location;
        self.APIKey = APIKey;
        _cacheInSeconds = 3600;
    }
    return self;
}

#pragma mark - Retrieve Weather Methods

- (void)retrieveCurrentWeather
{
    
    // Retrieve currentWX JSON from disk
    NSString *cachedWX = [[self.paths objectAtIndex:0] stringByAppendingPathComponent:@"currentJSON.plist"];
    
    if (![NSDictionary dictionaryWithContentsOfFile:cachedWX]) {
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
        
        NSLog(@"currentCACHE:%@ NOW:%@ DIFF:%f", reportTimeStamp, now, diff);
        
        if (diff > _cacheInSeconds) {
            //NSLog(@"current:accessing network");
            
            if (!_APIKey) {
                [self getCurrentWithURL:self.urlForCurrentWXwithoutAPIKey];
            } else {
                [self getCurrentWithURL:self.urlForCurrentWXwithAPIKey];
            }
        } else {
            NSLog(@"current:using cache");
            if ([_delegate respondsToSelector:@selector(ZFInterfaceCurrentWeather:)]) {
                [_delegate ZFInterfaceCurrentWeather:[NSDictionary dictionaryWithDictionary:[NSDictionary dictionaryWithContentsOfFile:cachedWX]]];
            }
        }
    }
}

- (void)retrieveForecastWeather
{
    // Retrieve forecastWX JSON from disk
    NSString *cachedWX = [[self.paths objectAtIndex:0] stringByAppendingPathComponent:@"forecastJSON.plist"];
    
    if (![NSDictionary dictionaryWithContentsOfFile:cachedWX]) {
        if (!_APIKey) {
            [self getForecastWithURL:self.urlForForecastWXwithoutAPIKey];
        } else {
            [self getForecastWithURL:self.urlForForecastWXwithAPIKey];
        }
        
    } else {
        
        int cacheUnixTimestamp = [[[NSUserDefaults standardUserDefaults] valueForKey:@"forecastTimestamp"] intValue];
        
        //int cacheUnixTimestamp = [[[NSDictionary dictionaryWithContentsOfFile:cachedWX] objectForKey:@"dt"] intValue];
        NSTimeInterval timeInterval = (NSTimeInterval)cacheUnixTimestamp;
        NSDate *reportTimeStamp = [NSDate dateWithTimeIntervalSince1970:timeInterval];
        NSDate *now = [NSDate new];
        NSTimeInterval diff = [now timeIntervalSinceDate:reportTimeStamp];
        
        NSLog(@"forecastCACHE:%@ NOW:%@ DIFF:%f", reportTimeStamp, now, diff);
        
        if (diff > _cacheInSeconds) {
            //NSLog(@"forecast:accessing network");
            
            if (!_APIKey) {
                [self getForecastWithURL:self.urlForForecastWXwithoutAPIKey];
            } else {
                [self getForecastWithURL:self.urlForForecastWXwithAPIKey];
            }
        } else {
            NSLog(@"forecast:using cache");
            if ([_delegate respondsToSelector:@selector(ZFInterfaceForecastWeather:)]) {
                [_delegate ZFInterfaceForecastWeather:[NSDictionary dictionaryWithDictionary:[NSDictionary dictionaryWithContentsOfFile:cachedWX]]];
            }
        }
    }
}

#pragma mark - Network Connections

- (void)getCurrentWithURL:(NSString *)currentURL
{
    NSLog(@"current url %@", currentURL);

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
    NSLog(@"forecast url %@", forecast);
    
    NSURLRequest *requestForecast = [NSURLRequest requestWithURL:[NSURL URLWithString:forecast]];
    [AFJSONRequestOperation addAcceptableContentTypes:[NSSet setWithObjects:@"text/html", nil]];
    AFJSONRequestOperation *operationForecast = [AFJSONRequestOperation JSONRequestOperationWithRequest:requestForecast
                                                                                                success:^(NSURLRequest *requestOWM, NSHTTPURLResponse *response2, id responseJSONOWM) {
                                                                                                    //NSLog(@"forecast %@", responseJSONOWM);
                                                                                                   
                                                                                                    // write to disk
                                                                                                    NSString *documentsDir = [self.paths objectAtIndex:0];
                                                                                                    NSString *fullPath = [documentsDir stringByAppendingPathComponent:@"forecastJSON.plist"];
                                                                                                    [responseJSONOWM writeToFile:fullPath  atomically:YES];
                                                                                                   
                                                                                                    NSTimeInterval timeInMiliseconds = [[NSDate date] timeIntervalSince1970];
                                                                                                
                                                                [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithFloat:timeInMiliseconds] forKey:@"forecastTimestamp"];
                                                                [[NSUserDefaults standardUserDefaults] synchronize];
                                                                                                    
                                                                                                    if ([self.delegate respondsToSelector:@selector(ZFInterfaceForecastWeather:)]) {
                                                                                                        [self.delegate ZFInterfaceForecastWeather:responseJSONOWM];
                                                                                                    }
                                                                                                    
                                                                                                }
                                                                                                failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                                                                                                    NSLog(@"%@", [error userInfo]);
                                                                                                }];
    [operationForecast start];
}

#pragma mark - ZFHourlyWeather Delegate Method

- (void)ZFHourlyWeather:(NSDictionary *)currentWeather
{
    NSLog(@"ZFHourlyWeather %@", currentWeather);


}

@end
