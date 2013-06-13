//
//  ZFViewController.m
//  ZFOpenWeatherMap
//
//  Created by apollo on 5/31/13.
//  Copyright (c) 2013 ZFOpenWeatherMap. All rights reserved.
//

#import "ZFViewController.h"
#import "ZFInterface.h"

@interface ZFViewController () <CLLocationManagerDelegate>
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) CLLocation *location;
@property (nonatomic, retain) CLLocation *startingPoint;
@end

@implementation ZFViewController

#pragma mark - UIViewController

- (id)init
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
    
    self.location = newLocation;
    ZFInterface *interface = [[ZFInterface alloc] initWithDelegate:self location:newLocation APIKey:nil];
    [interface retreiveCurrentWeather];
    [interface retreiveForecastWeather];
    
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
}

- (void)ZFInterfaceForecastWeather:(NSDictionary *)forecastWeather
{
    NSLog(@"forecast %@", forecastWeather);
}

@end