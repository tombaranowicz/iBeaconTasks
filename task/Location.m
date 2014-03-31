//
//  Location.m
//  task
//
//  Created by Tomasz Baranowicz on 12/27/13.
//  Copyright (c) 2013. All rights reserved.
//

#import "Location.h"
#import "AppDelegate.h"

@implementation Location

- (id) initWithCLBeacon:(CLBeacon *)beacon name:(NSString *)name_
{
    self = [super init];
    if (self) {
        _uuid = [beacon.proximityUUID UUIDString];
        _major = [beacon.major intValue];
        _minor = [beacon.minor intValue];
        
        _name = name_;
        
        _tasks = [[NSMutableArray alloc] init];
        _addedTasks = [[NSMutableArray alloc] init];
        _removedTasks = [[NSMutableArray alloc] init];
    }
    return self;
}

- (id) initWithPFObject:(PFObject *)object
{
    self = [super init];
    if (self) {
        _uuid = object[LOCATION_CLASS_BEACON_UUID_KEY];
        _major = [object[LOCATION_CLASS_BEACON_MAJOR_KEY] intValue];
        _minor = [object[LOCATION_CLASS_BEACON_MINOR_KEY] intValue];
        
        _name = object[LOCATION_CLASS_NAME_KEY];
        _objectId = object.objectId;
        
        _tasks = [[NSMutableArray alloc] init];
        for (NSDictionary *taskDictionary in object[LOCATION_CLASS_TASKS_KEY]) {
            [_tasks addObject:[[Task alloc] initWithDictionary:taskDictionary]];
        }
        
        _addedTasks = [[NSMutableArray alloc] init];
        _removedTasks = [[NSMutableArray alloc] init];
    }
    return self;
}

- (id) initWithDictionary:(NSDictionary *)object
{
    self = [super init];
    if (self) {
        _uuid = object[LOCATION_CLASS_BEACON_UUID_KEY];
        _major = [object[LOCATION_CLASS_BEACON_MAJOR_KEY] intValue];
        _minor = [object[LOCATION_CLASS_BEACON_MINOR_KEY] intValue];
        
        _name = object[LOCATION_CLASS_NAME_KEY];
        _objectId = object[LOCATION_CLASS_OBJECT_ID_KEY];
        
        _tasks = [[NSMutableArray alloc] init];
        for (NSDictionary *dictionary in object[LOCATION_CLASS_TASKS_KEY]) {
            [_tasks addObject:[[Task alloc] initWithDictionary:dictionary]];
        }
        
        _addedTasks = [[NSMutableArray alloc] init];
        for (NSDictionary *dictionary in object[LOCATION_CLASS_ADDED_TASKS_KEY]) {
            [_addedTasks addObject:[[Task alloc] initWithDictionary:dictionary]];
        }
        
        _removedTasks = [[NSMutableArray alloc] init];
        for (NSDictionary *dictionary in object[LOCATION_CLASS_REMOVED_TASKS_KEY]) {
            [_removedTasks addObject:[[Task alloc] initWithDictionary:dictionary]];
        }
    }
    return self;
}

- (NSDictionary *) toDictionary
{
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    
    dictionary[LOCATION_CLASS_BEACON_UUID_KEY] = _uuid;
    dictionary[LOCATION_CLASS_BEACON_MAJOR_KEY] = [NSNumber numberWithInt:_major];
    dictionary[LOCATION_CLASS_BEACON_MINOR_KEY] = [NSNumber numberWithInt:_minor];
    
    dictionary[LOCATION_CLASS_NAME_KEY] = _name;
    
    if (_objectId) {
        dictionary[LOCATION_CLASS_OBJECT_ID_KEY] = _objectId;
    }
    
    NSMutableArray *dictArray = [[NSMutableArray alloc] init];
    for (Task *task in _tasks) {
        [dictArray addObject:[task toDictionary]];
    }
    dictionary[LOCATION_CLASS_TASKS_KEY] = dictArray;

    dictArray = [[NSMutableArray alloc] init];
    for (Task *task in _addedTasks) {
        [dictArray addObject:[task toDictionary]];
    }
    dictionary[LOCATION_CLASS_ADDED_TASKS_KEY] = dictArray;
    
    dictArray = [[NSMutableArray alloc] init];
    for (Task *task in _removedTasks) {
        [dictArray addObject:[task toDictionary]];
    }
    dictionary[LOCATION_CLASS_REMOVED_TASKS_KEY] = dictArray;
    
    return dictionary;
}

- (void) addTask:(Task *)task
{
    [_addedTasks addObject:task];
    [_tasks addObject:task];
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate setNeedsSync];
}

- (void) removeTask:(Task *)task
{
    [_removedTasks addObject:task];
    [_addedTasks removeObject:task];
    [_tasks removeObject:task];
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate setNeedsSync];
}

- (NSArray *) tasksToDictionariesArray
{
    NSMutableArray *dictArray = [[NSMutableArray alloc] init];
    for (Task *task in _tasks) {
        [dictArray addObject:[task toDictionary]];
    }
    return dictArray;
}

@end
