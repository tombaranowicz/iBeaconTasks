//
//  Task.h
//  task
//
//  Created by Tomasz Baranowicz on 1/24/14.
//  Copyright (c) 2014. All rights reserved.
//

#import <Foundation/Foundation.h>
#define ENTRY_TASK 0
#define EXIT_TASK 1

#define TASK_CLASS_ID_KEY @"id"
#define TASK_CLASS_TYPE_KEY @"type"
#define TASK_CLASS_DESCRIPTION_KEY @"description"

@interface Task : NSObject
{
    
}

@property(nonatomic) int taskId;
@property(nonatomic) int type; // ENTRY_TASK or EXIT_TASK
@property(nonatomic, strong) NSString *description;

- (NSDictionary *) toDictionary;
- (id) initWithDictionary:(NSDictionary *)dictionary;

@end
