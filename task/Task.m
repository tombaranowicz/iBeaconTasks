//
//  Task.m
//  task
//
//  Created by Tomasz Baranowicz on 1/24/14.
//  Copyright (c) 2014. All rights reserved.
//

#import "Task.h"

@implementation Task

- (NSDictionary *) toDictionary
{
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    dictionary[TASK_CLASS_ID_KEY] = [NSNumber numberWithDouble:self.taskId];
    dictionary[TASK_CLASS_TYPE_KEY] = [NSNumber numberWithInt:self.type];
    dictionary[TASK_CLASS_DESCRIPTION_KEY] = self.description;
    
    return dictionary;
}

- (id) initWithDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    if (self) {
        self.taskId = [dictionary[TASK_CLASS_ID_KEY] doubleValue];
        self.type = [dictionary[TASK_CLASS_TYPE_KEY] intValue];
        self.description = dictionary[TASK_CLASS_DESCRIPTION_KEY];
    }
    return self;
}

@end
