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

#import "ZFRootViewController.h"
#import "ZFInterface.h"

@interface ZFRootViewController () <CLLocationManagerDelegate>
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) CLLocation *location;
@property (nonatomic, retain) CLLocation *startingPoint;
@end

@implementation ZFRootViewController

#pragma mark - UIViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
        _locationManager.desiredAccuracy = kCLLocationAccuracyKilometer;
        _locationManager.distanceFilter = 5000.0f;
        [self.locationManager startUpdatingLocation];
    }
    return self;
}

#pragma mark - CLLocationManager Delegate

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation
{
    if (_startingPoint == nil)
        self.startingPoint = newLocation;

    
    ZFInterface *interface = [[ZFInterface alloc] initWithDelegate:self
                                                          location:newLocation
                                                            APIKey:nil];
    
    interface.cacheInSeconds = 1300;
    [interface retrieveCurrentWeather];
    [interface retrieveForecastWeather];
    
    [_locationManager stopUpdatingLocation];
}

- (void)viewDidLoad
{
    self.view.backgroundColor = [UIColor lightGrayColor];
    [super viewDidLoad];
}

- (void)ZFInterfaceCurrentWeather:(NSDictionary *)currentWeather
{
    NSLog(@"current %@", currentWeather);
    //NSLog(@"current %i", [currentWeather count]);
}

- (void)ZFInterfaceForecastWeather:(NSDictionary *)forecastWeather
{
    NSLog(@"forecast %@", forecastWeather);
    //NSLog(@"forecast %i", [forecastWeather count]);
}

@end