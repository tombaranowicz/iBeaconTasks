//
//  AppDelegate.m
//  task
//
//  Created by Tomasz Baranowicz on 12/27/13.
//  Copyright (c) 2013 Tivix. All rights reserved.
//

#import "AppDelegate.h"
#import "LocationsListViewController.h"
#import <Parse/Parse.h>
#import <FacebookSDK/FacebookSDK.h>

#import "CustomSignupViewController.h"
#import "CustomLoginViewController.h"
#import "BeaconMonitoringService.h"
#import "TaskCreateAlertView.h"
#import "TaskCell.h"

#define LOCATIONS_ARRAY_DEFAULTS_KEY @"locationsArrayDefaultsKey"
#define DELETED_LOCATIONS_ARRAY_DEFAULTS_KEY @"deletedLocationsArrayDefaultsKey"

@interface AppDelegate() <PFLogInViewControllerDelegate, PFSignUpViewControllerDelegate, CLLocationManagerDelegate, UITableViewDataSource, UITableViewDelegate>
{
    NSMutableArray *recentBeaconsInRange;
    NSMutableArray *deletedLocations;
    NSArray *parseLocations;
    
    BOOL rangeForEntry;
    BOOL rangeForExit;
    
    int synchronizedLocationsCounter;
    BOOL syncInProgress;
    
    BOOL taskAlertPresented;
    Location *taskAlertLocation;
    NSMutableArray *taskAlertSelectedTasks;
    NSMutableArray *taskAlertTasksToShow;
    UITableView *taskAlertTasksTableView;
}

- (void) saveDataInLocalStorage;
- (void) loadLocationsFromLocalStorage;
- (void) updateLocations:(NSArray *)newLocationsArray;
- (void) prepareScanRegions;
- (void) continueSync;
- (void) showTasksAlert;

@property (strong, nonatomic) NSMutableArray *enteredLocations;
@property (strong, nonatomic) NSMutableArray *leftLocations;
@property (nonatomic, readonly) BOOL needsSync;

@end

@implementation AppDelegate

#pragma mark App lifecycle methods
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [Parse setApplicationId:@"#############################" clientKey:@"#############################"];
    [PFFacebookUtils initializeFacebook];
    
    self.enteredLocations = [[NSMutableArray alloc] init];
    self.leftLocations = [[NSMutableArray alloc] init];
    
    [self prepareScanRegions];
    [self loadLocationsFromLocalStorage];

    _locationManager = [[CLLocationManager alloc] init];
    _locationManager.delegate = self;
    for (CLBeaconRegion *region in self.regionsToScan) {
        [_locationManager startMonitoringForRegion:region];
    }
    
    PFACL *defaultACL = [PFACL ACL];
    [defaultACL setPublicReadAccess:YES];
    [PFACL setDefaultACL:defaultACL withAccessForCurrentUser:YES];
    
    UINavigationController *rootController = [[UINavigationController alloc] initWithRootViewController:[[LocationsListViewController alloc] init]];
    rootController.navigationBar.hidden = NO;
    self.window.rootViewController = rootController;
    [self.window makeKeyAndVisible];
    
    [[UINavigationBar appearance] setBarTintColor:[Utils themeColor]];
    
    UIColor *navigationTextColor = [UIColor whiteColor];
    self.window.tintColor = navigationTextColor;
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName : navigationTextColor}];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:NO];
    
    PFUser *currentUser = [PFUser currentUser];
    
    if (!currentUser) {
        [self performSelector:@selector(showLogin) withObject:nil afterDelay:.5f];
    } else if ([PFFacebookUtils isLinkedWithUser:[PFUser currentUser]]) {
        FBRequest *request = [FBRequest requestForMe];
        [request startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
            if (!error) {
                NSString *displayName = result[@"name"];
                if (displayName) {
                    DLOG(@"name: %@", displayName);
                }
            } else {
                DLOG(@"error: %@", error.description);
            }
        }];
    }

    [NSTimer scheduledTimerWithTimeInterval:30.0 target:self selector:@selector(syncWithParse) userInfo:nil repeats:YES];
    return YES;
}

#pragma mark private methods
- (void) continueSync
{
    if (deletedLocations.count>0) {
        // 1. Sync removed locations
        Location *location = [deletedLocations objectAtIndex:0];
        DLOG(@"SYNC DELETED LOCATION: %@", location.name);
        PFObject *object = [PFObject objectWithoutDataWithClassName:LOCATION_CLASS_NAME objectId:location.objectId];
        [object deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                DLOG(@"DELETED LOCATION: %@", location.name);
                [deletedLocations removeObjectAtIndex:0];
                [self continueSync];
            } else {
                DLOG(@"ERROR: %@", error.description);
                [self setNeedsSync]; //sync wasn't finished, try again after established time
                syncInProgress = NO;
            }
        }];
    } else if(synchronizedLocationsCounter<_locationsArray.count){
        // 2. Go throught all locations and sync their tasks or add them, if they are not synced yet
        Location *location = [_locationsArray objectAtIndex:synchronizedLocationsCounter];
        if (location.objectId) {
            //existing object, sync tasks only
            for (PFObject *object in parseLocations) {
                
                if ([object.objectId isEqualToString:location.objectId]) {
                    
                    //prepare array of tasks assigned to location on server
                    NSMutableArray *parseObjectTasksArray = [[NSMutableArray alloc] init];
                    for (NSDictionary *taskDictionary in object[LOCATION_CLASS_TASKS_KEY]) {
                        Task *task = [[Task alloc] initWithDictionary:taskDictionary];
                        [parseObjectTasksArray addObject:task];
                    }

                    //delete
                    NSMutableArray *tasksToRemove = [[NSMutableArray alloc] init];
                    for (Task *task in location.removedTasks) {
                        DLOG(@"try to remove: %@", task.description);
                        for (Task *parseTask in parseObjectTasksArray) {
                            DLOG(@"check to remove: %@", parseTask.description);
                            if (task.taskId == parseTask.taskId) {
                                [tasksToRemove addObject:parseTask];
                                DLOG(@"add to remove: %@", parseTask.description);
                            }
                        }
                    }
                    DLOG(@"tasks to remove: %@", tasksToRemove);
                    [parseObjectTasksArray removeObjectsInArray:tasksToRemove];
                    
                    //add
                    for (Task *task in location.addedTasks) {
                        BOOL contains = NO;
                        for (Task *parseTask in parseObjectTasksArray) {
                            if (task.taskId == parseTask.taskId) {
                                contains = YES;
                                break;
                            }
                        }

                        if (!contains) {
                            [parseObjectTasksArray addObject:task];
                        }
                    }
                    
                    //change into dictionaries array
                    NSMutableArray *array = [[NSMutableArray alloc] init];
                    for (Task *parseTask in parseObjectTasksArray) {
                        [array addObject:[parseTask toDictionary]];
                    }
                    object[LOCATION_CLASS_TASKS_KEY] = array;
                    [object saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                        if (succeeded) {
                            DLOG(@"location synchronized with parse");
                            
                            NSMutableArray *array = [[NSMutableArray alloc] initWithArray:_locationsArray];
                            [array replaceObjectAtIndex:synchronizedLocationsCounter withObject:[[Location alloc] initWithPFObject:object]];
                            _locationsArray = [NSArray arrayWithArray:array];
                            
                            synchronizedLocationsCounter++;
                            [self continueSync];
                        } else {
                            DLOG(@"location synchronization with parse failed: %@", error.description);
                            [self setNeedsSync];
                            syncInProgress = NO;
                        }
                    }];
                }
            }
        } else {
            //it is new object, add it to parse
            PFObject *newLocation = [PFObject objectWithClassName:LOCATION_CLASS_NAME];
            [newLocation setObject:location.name forKey:LOCATION_CLASS_NAME_KEY];
            [newLocation setObject:[PFUser currentUser] forKey:LOCATION_CLASS_USER_KEY];
            [newLocation setObject:[location tasksToDictionariesArray] forKey:LOCATION_CLASS_TASKS_KEY]; //add tasks in a form of dictionary
            [newLocation setObject:location.uuid forKey:LOCATION_CLASS_BEACON_UUID_KEY];
            [newLocation setObject:[NSNumber numberWithInt:location.major] forKey:LOCATION_CLASS_BEACON_MAJOR_KEY];
            [newLocation setObject:[NSNumber numberWithInt:location.minor] forKey:LOCATION_CLASS_BEACON_MINOR_KEY];
            
            [newLocation saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (succeeded) {
                    DLOG(@"new location added to parse %@", newLocation.objectId);

                    NSMutableArray *array = [[NSMutableArray alloc] initWithArray:_locationsArray];
                    [array replaceObjectAtIndex:synchronizedLocationsCounter withObject:[[Location alloc] initWithPFObject:newLocation]];
                    _locationsArray = [NSArray arrayWithArray:array];
                    
                    synchronizedLocationsCounter++;
                    [self continueSync];
                } else {
                    DLOG(@"new location synchronization failed: %@", error.description);
                    [self setNeedsSync];
                    syncInProgress = NO;
                }
            }];
        }
    } else {
        // FINISHED SYNC SEND NOTIFICATION
        DLOG(@"SYNCHRONIZATION SUCCEEDED");
        [[NSNotificationCenter defaultCenter] postNotificationName:SYNC_FINISHED_NOTIFICATION object:self];
        [self saveDataInLocalStorage];
        syncInProgress=NO;
    }
}

- (void) prepareScanRegions
{
    self.regionsToScan = [[NSMutableArray alloc] init];
    
    NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:@"e2c56db5-dffb-48d2-b060-d0f5a71096e0"];
    CLBeaconRegion *region = [[CLBeaconRegion alloc] initWithProximityUUID:uuid identifier:@"com.nsscreencast.beaconfun.region"];
    region.notifyOnEntry = YES;
    region.notifyOnExit = YES;
    region.notifyEntryStateOnDisplay = YES;
    [self.regionsToScan addObject:region];
}

- (void) saveDataInLocalStorage
{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    //SAVE CURRENTLY EXISTING LOCATIONS
    NSMutableArray *locations = [[NSMutableArray alloc] init];
    for (Location *location in self.locationsArray) {
        [locations addObject:[location toDictionary]];
    }
    [prefs setObject:locations forKey:LOCATIONS_ARRAY_DEFAULTS_KEY];
    
    //SAVE DELETED AND NOT SYNCHRONIZED YET
    locations = [[NSMutableArray alloc] init];
    for (Location *location in deletedLocations) {
        [locations addObject:[location toDictionary]];
    }
    [prefs setObject:locations forKey:DELETED_LOCATIONS_ARRAY_DEFAULTS_KEY];
    
    [prefs synchronize];
}

- (void) loadLocationsFromLocalStorage
{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    NSMutableArray *array = [[NSMutableArray alloc] init];
    NSArray *locationDictionariesArray = [prefs objectForKey:LOCATIONS_ARRAY_DEFAULTS_KEY];
    
    if (locationDictionariesArray) {
        for (NSDictionary *dictionary in locationDictionariesArray) {
            [array addObject:[[Location alloc] initWithDictionary:dictionary]];
        }
        _locationsArray = [NSArray arrayWithArray:array];
        
        array = [[NSMutableArray alloc] init];
        locationDictionariesArray = [prefs objectForKey:DELETED_LOCATIONS_ARRAY_DEFAULTS_KEY];
        if (locationDictionariesArray) {
            for (NSDictionary *dictionary in locationDictionariesArray) {
                [array addObject:[[Location alloc] initWithDictionary:dictionary]];
            }
            deletedLocations = [NSMutableArray arrayWithArray:array];
        }
    } else { // nothing in local user defaults means that this is first run so app has to take data from Parse
        [self setNeedsSync];
        [self syncWithParse];
    }

    [[NSNotificationCenter defaultCenter] postNotificationName:SYNC_FINISHED_NOTIFICATION object:self];
}

- (void) showTasksAlert
{
    DLOG(@"show alert: %d %d", self.enteredLocations.count, self.leftLocations.count);
    if (!taskAlertPresented && (self.enteredLocations.count>0 || self.leftLocations.count>0)) {
        taskAlertPresented=YES;
        
        taskAlertLocation = nil;
        taskAlertSelectedTasks = [[NSMutableArray alloc] init];
        taskAlertTasksToShow = [[NSMutableArray alloc] init];
        
        if (self.enteredLocations.count>0) {
            taskAlertLocation = [self.enteredLocations objectAtIndex:0];
            [self.enteredLocations removeObjectAtIndex:0];
            for (Task *task in taskAlertLocation.tasks) {
                if (task.type==ENTRY_TASK) {
                    [taskAlertSelectedTasks addObject:task];
                    [taskAlertTasksToShow addObject:task];
                }
            }
        } else if (self.leftLocations.count>0) {
            taskAlertLocation = [self.leftLocations objectAtIndex:0];
            [self.leftLocations removeObjectAtIndex:0];
            for (Task *task in taskAlertLocation.tasks) {
                if (task.type==EXIT_TASK) {
                    [taskAlertSelectedTasks addObject:task];
                    [taskAlertTasksToShow addObject:task];
                }
            }
        }
        
        if (taskAlertLocation) {
            TaskCreateAlertView *alertView = [[TaskCreateAlertView alloc] init];
            UIView *containerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 290, 200)];
            
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 270, 25)];
            label.text = @"Tasks";
            label.textColor = [Utils themeColor];
            label.font = [UIFont boldSystemFontOfSize:20.0f];
            label.textAlignment = NSTextAlignmentCenter;
            [containerView addSubview:label];
            
            taskAlertTasksTableView = [[UITableView alloc] initWithFrame:CGRectMake(10, 40, 270, 155) style:UITableViewStylePlain];
            taskAlertTasksTableView.delegate=self;
            taskAlertTasksTableView.dataSource=self;
            taskAlertTasksTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
            taskAlertTasksTableView.backgroundColor = [UIColor clearColor];
            [containerView addSubview:taskAlertTasksTableView];
            
            [alertView setContainerView:containerView];
            [alertView setButtonTitles:[NSMutableArray arrayWithObjects:@"Postpone All", @"Remove Selected", nil]];
            
            [alertView setOnButtonTouchUpInside:^(TaskCreateAlertView *alertView, int buttonIndex) {
                if (buttonIndex==1) { //remove selected
                    for (Task *task in taskAlertSelectedTasks) {
                        [taskAlertLocation removeTask:task];
                    }
                }
                
                [alertView close];
                taskAlertPresented=NO;
                [[NSNotificationCenter defaultCenter] postNotificationName:SYNC_FINISHED_NOTIFICATION object:self];
                [self showTasksAlert];
            }];
            
            [alertView setUseMotionEffects:true];
            [alertView show];
        }
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return taskAlertTasksToShow.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Task *task = [taskAlertTasksToShow objectAtIndex:indexPath.row];
    UIFont *cellFont = [UIFont systemFontOfSize:16.0f];
    CGSize constraintSize = CGSizeMake(270-60, MAXFLOAT);
    CGSize labelSize = [task.description sizeWithFont:cellFont constrainedToSize:constraintSize lineBreakMode:NSLineBreakByWordWrapping];
    return labelSize.height+20;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TaskCell *cell = [tableView dequeueReusableCellWithIdentifier:@"taskCell"];
    if (!cell) {
        cell = [[TaskCell alloc] initWithReuseIdentifier:@"taskCell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    [cell setTask:[taskAlertTasksToShow objectAtIndex:indexPath.row]];
    cell.accessoryView = nil;
    if ([taskAlertSelectedTasks containsObject:[taskAlertTasksToShow objectAtIndex:indexPath.row]]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if ([taskAlertSelectedTasks containsObject:[taskAlertTasksToShow objectAtIndex:indexPath.row]]) {
        [taskAlertSelectedTasks removeObject:[taskAlertTasksToShow objectAtIndex:indexPath.row]];
    } else {
        [taskAlertSelectedTasks addObject:[taskAlertTasksToShow objectAtIndex:indexPath.row]];
    }
    [tableView reloadData];
}

#pragma mark public methods
- (void) setNeedsSync
{
    DLOG(@"SET NEEDS SYNC");
    _needsSync = YES;
    [self saveDataInLocalStorage];
}

- (void) syncWithParse
{
    if (_needsSync && !syncInProgress && [PFUser currentUser]) {
        DLOG(@"WILL SYNCHRONIZE");
        syncInProgress = YES;
        _needsSync = NO;
        
        PFQuery *query = [PFQuery queryWithClassName:LOCATION_CLASS_NAME];
        [query whereKey:LOCATION_CLASS_USER_KEY equalTo:[PFUser currentUser]];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (!error) {
                DLOG(@"Successfully retrieved %d locations.", objects.count);
                parseLocations = [NSArray arrayWithArray:objects];
                synchronizedLocationsCounter = 0;
                [self continueSync];
            } else {
                DLOG(@"Error: %@ %@", error, [error userInfo]);
                [self setNeedsSync];
                syncInProgress = NO;
            }
        }];
    } else {
        DLOG(@"WILL NOT SYNCHRONIZE");
    }
}

- (void) updateLocations:(NSArray *)newLocationsArray
{
    DLOG(@"update locations");
    _locationsArray = [NSArray arrayWithArray:newLocationsArray];
    [self saveDataInLocalStorage];
    [self setNeedsSync];
}

- (void) addLocation:(Location *)location
{
    NSMutableArray *array = [[NSMutableArray alloc] initWithArray:self.locationsArray];
    [array addObject:location];
    [self updateLocations:array];
}

- (void) deleteLocation:(Location *)location
{
    NSMutableArray *array = [[NSMutableArray alloc] initWithArray:self.locationsArray];
    [array removeObject:location];
    
    if (location.objectId) { // if location doesn't have objectId, it wasn'e synchronized yet, so no need to request delete on server, will fail!
        [deletedLocations addObject:location];
    }
    [self updateLocations:array];
}

- (void) showLogin
{
    CustomLoginViewController *logInViewController = [[CustomLoginViewController alloc] init];
    [logInViewController setDelegate:self];
    logInViewController.fields = PFLogInFieldsFacebook | PFLogInFieldsDefault;
    logInViewController.facebookPermissions = @[@"friends_about_me"];
    
    CustomSignupViewController *signUpViewController = [[CustomSignupViewController alloc] init];
    signUpViewController.signUpView.logo=nil;
    [signUpViewController setDelegate:self];
    [logInViewController setSignUpController:signUpViewController];
    
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:logInViewController];
    [navController setNavigationBarHidden:YES];
    navController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    [self.window.rootViewController presentViewController:navController animated:YES completion:nil];
}

#pragma mark ibeacon methods
- (NSString *)stringForProximity:(CLProximity)proximity {
    switch (proximity) {
        case CLProximityUnknown:    return @"Unknown";
        case CLProximityFar:        return @"Far";
        case CLProximityNear:       return @"Near";
        case CLProximityImmediate:  return @"Immediate";
        default:
            return nil;
    }
}

- (void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region {
    
    if(rangeForExit) {
        rangeForExit = NO;
        
        DLOG(@"range for exit");
        //diff from recent and current, only those left have left
        [recentBeaconsInRange removeObjectsInArray:beacons];
        
        for (CLBeacon *beacon in recentBeaconsInRange) {
            
            DLOG(@"CHECK LEFT LOCATION: %@ %@ %@", [self stringForProximity:beacon.proximity], beacon.major, beacon.minor);
            for (Location *location in self.locationsArray) {
                
                if ([location.uuid isEqualToString:[beacon.proximityUUID UUIDString]] && location.major == [beacon.major intValue] && location.minor == [beacon.minor intValue]) {
                    
                    if (location.tasks.count>0 && ![self.leftLocations containsObject:location])
                    {
                        [self.leftLocations addObject:location];
                        DLOG(@"Left beacon: %@ %@ - %@", beacon.proximityUUID, beacon.major, beacon.minor);
                        
                        if ([[UIApplication sharedApplication] applicationState] != UIApplicationStateActive) { // if is active we will just show proper alert by sending proper notification!
                            NSString *notificationString = [NSString stringWithFormat:@"You have left %@!", location.name];
                            BOOL hadExitTasks = NO;
                            for (Task *task in location.tasks) {
                                if (task.type==EXIT_TASK) {
                                    notificationString = [NSString stringWithFormat:@"%@\n- %@", notificationString, task.description];
                                    hadExitTasks=YES;
                                }
                            }
                            
                            if (hadExitTasks) {
                                UILocalNotification *notification = [[UILocalNotification alloc] init];
                                notification.userInfo = @{@"uuid": [beacon.proximityUUID UUIDString], @"major":beacon.major, @"minor":beacon.minor, @"type":[NSNumber numberWithInt:EXIT_TASK]};
                                notification.alertBody = notificationString;
                                notification.soundName = @"Default";
                                [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
                            }
                        } else {
                            [self showTasksAlert];
                        }
                    }
                }
            }
        }
    } else if(rangeForEntry) {
        rangeForEntry=NO;
        for (CLBeacon *beacon in beacons) {
            DLOG(@"Ranged beacon: %@ %@ - %@", beacon.proximityUUID, beacon.major, beacon.minor);
            DLOG(@"Range: %@", [self stringForProximity:beacon.proximity]);
        
            for (Location *location in self.locationsArray) {
                
                if ([location.uuid isEqualToString:[beacon.proximityUUID UUIDString]] && location.major == [beacon.major intValue] && location.minor == [beacon.minor intValue]) {
                    
                    if (location.tasks.count>0 && ![self.enteredLocations containsObject:location])
                    {
                        [self.enteredLocations addObject:location];
                        
                        if ([[UIApplication sharedApplication] applicationState] != UIApplicationStateActive) { // if is active we will just show proper alert by sending proper notification!
                            NSString *notificationString = [NSString stringWithFormat:@"You have entered %@!", location.name];
                            BOOL hadEntryTasks = NO;
                            for (Task *task in location.tasks) {
                                if (task.type==ENTRY_TASK) {
                                    notificationString = [NSString stringWithFormat:@"%@\n- %@", notificationString, task.description];
                                    hadEntryTasks=YES;
                                }
                            }
                            
                            if (hadEntryTasks) {
                                UILocalNotification *notification = [[UILocalNotification alloc] init];
                                notification.userInfo = @{@"uuid": [beacon.proximityUUID UUIDString], @"major":beacon.major, @"minor":beacon.minor, @"type":[NSNumber numberWithInt:ENTRY_TASK]};
                                notification.alertBody = notificationString;
                                notification.soundName = @"Default";
                                [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
                            }
                        } else {
                            [self showTasksAlert];
                        }
                    }
                }
            }
        }
    }
    
    recentBeaconsInRange = [NSMutableArray arrayWithArray:beacons];
    [_locationManager stopRangingBeaconsInRegion:region];
}

- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region {
    if ([region isKindOfClass:[CLBeaconRegion class]]) {
        CLBeaconRegion *beaconRegion = (CLBeaconRegion *)region;
        rangeForEntry=YES;
        [_locationManager startRangingBeaconsInRegion:beaconRegion];
        DLOG(@"Did enter %@ major:%@ minor:%@", [beaconRegion.proximityUUID UUIDString], beaconRegion.major, beaconRegion.minor);
    }
}

- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region {
    if ([region isKindOfClass:[CLBeaconRegion class]]) {
        CLBeaconRegion *beaconRegion = (CLBeaconRegion *)region;
        rangeForExit=YES;
        [_locationManager startRangingBeaconsInRegion:beaconRegion];
        DLOG(@"Did exit %@ major:%d minor:%d", [beaconRegion.proximityUUID UUIDString], [beaconRegion.major intValue], [beaconRegion.minor intValue]);
    }
}


- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
    // Play a sound and show an alert only if the application is active, to avoid doubly notifiying the user.
    if ([application applicationState] == UIApplicationStateActive) {
        DLOG(@"RECEIVED NOTIFICATION WHILE ACTIVE %@", notification.userInfo);
    } else {
        DLOG(@"RECEIVED NOTIFICATION WHILE NOT ACTIVE %@", notification.userInfo);
    }
}

//###########################PARSE##################################

#pragma mark - PFLogInViewControllerDelegate

- (BOOL)logInViewController:(PFLogInViewController *)logInController shouldBeginLogInWithUsername:(NSString *)username password:(NSString *)password {
    // Check if both fields are completed
    if (username && password && username.length && password.length) {
        return YES; // Begin login process
    }
    
    [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Missing Information", nil) message:NSLocalizedString(@"Make sure you fill out all of the information!", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil] show];
    return NO; // Interrupt login process
}

// Sent to the delegate when a PFUser is logged in.
- (void)logInViewController:(PFLogInViewController *)logInController didLogInUser:(PFUser *)user {
    [self.window.rootViewController dismissViewControllerAnimated:YES completion:NULL];
}

// Sent to the delegate when the log in attempt fails.
- (void)logInViewController:(PFLogInViewController *)logInController didFailToLogInWithError:(NSError *)error {
    NSLog(@"Failed to log in... %@", error.description);
}

// Sent to the delegate when the log in screen is dismissed.
- (void)logInViewControllerDidCancelLogIn:(PFLogInViewController *)logInController {
    [self.window.rootViewController dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark - PFSignUpViewControllerDelegate

// Sent to the delegate to determine whether the sign up request should be submitted to the server.
- (BOOL)signUpViewController:(PFSignUpViewController *)signUpController shouldBeginSignUp:(NSDictionary *)info {
    BOOL informationComplete = YES;
    
    // loop through all of the submitted data
    for (id key in info) {
        NSString *field = [info objectForKey:key];
        if (!field || !field.length) { // check completion
            informationComplete = NO;
            break;
        }
    }
    
    // Display an alert if a field wasn't completed
    if (!informationComplete) {
        [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Missing Information", nil) message:NSLocalizedString(@"Make sure you fill out all of the information!", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil] show];
    }
    
    return informationComplete;
}

// Sent to the delegate when a PFUser is signed up.
- (void)signUpViewController:(PFSignUpViewController *)signUpController didSignUpUser:(PFUser *)user {
    [self.window.rootViewController dismissViewControllerAnimated:YES completion:NULL];
}

// Sent to the delegate when the sign up attempt fails.
- (void)signUpViewController:(PFSignUpViewController *)signUpController didFailToSignUpWithError:(NSError *)error {
    NSLog(@"Failed to sign up...");
}

// Sent to the delegate when the sign up screen is dismissed.
- (void)signUpViewControllerDidCancelSignUp:(PFSignUpViewController *)signUpController {
    NSLog(@"User dismissed the signUpViewController");
}

// Facebook oauth callback
- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    NSLog(@"handle open url: %@", url);
    return [PFFacebookUtils handleOpenURL:url];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    NSLog(@"just open url: %@", url);
    return [PFFacebookUtils handleOpenURL:url];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    DLOG(@"DID BECOME ACTIVE");
    [self showTasksAlert];
}

@end
