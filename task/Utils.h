//
//  Utils.h
//  task
//
//  Created by Tomasz Baranowicz on 12/27/13.
//  Copyright (c) 2013. All rights reserved.
//

#import <Foundation/Foundation.h>

#define LOCATION_CLASS_NAME @"Location"
#define LOCATION_CLASS_OBJECT_ID_KEY @"objectId"
#define LOCATION_CLASS_NAME_KEY @"name"
#define LOCATION_CLASS_BEACON_UUID_KEY @"uuid"
#define LOCATION_CLASS_BEACON_MAJOR_KEY @"major"
#define LOCATION_CLASS_BEACON_MINOR_KEY @"minor"
#define LOCATION_CLASS_USER_KEY @"user"
#define LOCATION_CLASS_TASKS_KEY @"tasks"
#define LOCATION_CLASS_ADDED_TASKS_KEY @"addedTasks"
#define LOCATION_CLASS_REMOVED_TASKS_KEY @"removedTasks"

#define LOCAL_SYNC_DATE_KEY @"local_sync_date"
#define PARSE_SYNC_DATE_KEY @"parse_sync_date"

@interface Utils : NSObject
{
    
}
+(UIColor *)themeColor;
@end
