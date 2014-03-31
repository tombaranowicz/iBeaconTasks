//
//  AppDelegate.h
//  task
//
//  Created by Tomasz Baranowicz on 12/27/13.
//  Copyright (c) 2013. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Location.h"
#import "Task.h"

@import CoreLocation;

@interface AppDelegate : UIResponder <UIApplicationDelegate>
{
}

@property (strong, nonatomic, readonly) CLLocationManager *locationManager;
@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic, readonly) NSArray *locationsArray;
@property (strong, nonatomic) NSMutableArray *regionsToScan; //array of CLBeaconRegion objects

- (void) showLogin;

- (void) addLocation:(Location *)location;
- (void) deleteLocation:(Location *)location;

- (void) setNeedsSync;
- (void) syncWithParse;


@end
