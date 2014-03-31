//
//  BeaconMonitoringService.m
//  task
//
//  Created by Tomasz Baranowicz on 12/29/13.
//  Copyright (c) 2013. All rights reserved.
//

#import "BeaconMonitoringService.h"

@implementation BeaconMonitoringService {
    CLLocationManager *_locationManager;
}

+ (BeaconMonitoringService *)sharedInstance {
    static dispatch_once_t onceToken;
    static BeaconMonitoringService *_sharedInstance;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[self alloc] init];
    });
    
    return _sharedInstance;
}

- (instancetype)init {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    _locationManager = [[CLLocationManager alloc] init];
    return self;
}

- (void)startMonitoringBeaconWithUUID:(NSUUID *)uuid
                                major:(CLBeaconMajorValue)major
                                minor:(CLBeaconMinorValue)minor
                           identifier:(NSString *)identifier
                              onEntry:(BOOL)entry
                               onExit:(BOOL)exit
{
    CLBeaconRegion *region = [[CLBeaconRegion alloc] initWithProximityUUID:uuid identifier:identifier];
    region.notifyOnEntry = entry;
    region.notifyOnExit = exit;
    region.notifyEntryStateOnDisplay = YES;
    [_locationManager startMonitoringForRegion:region];
}

- (void)stopMonitoringAllRegions {
    for (CLRegion *region in _locationManager.monitoredRegions) {
        [_locationManager stopMonitoringForRegion:region];
    }
}

@end
