//
//  BeaconMonitoringService.h
//  task
//
//  Created by Tomasz Baranowicz on 12/29/13.
//  Copyright (c) 2013. All rights reserved.
//

#import <Foundation/Foundation.h>

@import CoreLocation;

@interface BeaconMonitoringService : NSObject

+ (BeaconMonitoringService *)sharedInstance;
- (void)startMonitoringBeaconWithUUID:(NSUUID *)uuid
                                major:(CLBeaconMajorValue)major
                                minor:(CLBeaconMinorValue)minor
                           identifier:(NSString *)identifier
                              onEntry:(BOOL)entry
                               onExit:(BOOL)exit;

- (void)stopMonitoringAllRegions;

@end