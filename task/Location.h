//
//  Location.h
//  task
//
//  Created by Tomasz Baranowicz on 12/27/13.
//  Copyright (c) 2013. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>
#import "Task.h"

@import CoreLocation;

@interface Location : NSObject
{
}

- (id) initWithPFObject:(PFObject *)object;
- (id) initWithDictionary:(NSDictionary *)dictionary;
- (id) initWithCLBeacon:(CLBeacon *)beacon name:(NSString *)name_;

@property(nonatomic, readonly) int major;
@property(nonatomic, readonly) int minor;
@property(nonatomic, strong, readonly) NSString *uuid;

@property(nonatomic, strong, readonly) NSString *name;
@property(nonatomic, strong, readonly) NSString *objectId;
@property(nonatomic, strong, readonly) NSMutableArray *tasks;
@property(nonatomic, strong, readonly) NSMutableArray *addedTasks;
@property(nonatomic, strong, readonly) NSMutableArray *removedTasks;

- (void) addTask:(Task *)task;
- (void) removeTask:(Task *)task;
- (NSArray *) tasksToDictionariesArray;
- (NSDictionary *) toDictionary;

@end
