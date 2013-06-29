//
//  ZFAppDelegate.h
//  ZFOpenWeatherMap
//
//  Created by apollo on 5/31/13.
//  Copyright (c) 2013 ZFOpenWeatherMap. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ZFRootViewController;

@interface ZFAppDelegate : UIResponder <UIApplicationDelegate>
@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) ZFRootViewController *viewController;
@end
