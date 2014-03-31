//
//  AddLocationViewController.m
//  task
//
//  Created by Tomasz Baranowicz on 12/27/13.
//  Copyright (c) 2013. All rights reserved.
//

#import "AddLocationViewController.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import "Location.h"
#import "AppDelegate.h"
#import <Parse/Parse.h>
#import "UIColor+iOS7Colors.h"

#define CELL_IDENTIFIER @"beaconCellIdentifier"
#define ADD_ALERT_TAG 1001

@interface AddLocationViewController () <CLLocationManagerDelegate, UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate>
{
    CLLocationManager *_locationManager;
    NSMutableDictionary *_beacons; // array of beacons in range
    
    CLBeacon *_selectedBeacon;
    
    UITableView *beaconsTableView;
    AppDelegate *appDelegate;
}

@end

@implementation AddLocationViewController

- (id)init
{
	self = [super init];
	if(self)
	{
        _beacons = [[NSMutableDictionary alloc] init];
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
	}
	
	return self;
}

- (void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region
{
    [_beacons removeAllObjects];
    
    NSArray *unknownBeacons = [beacons filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"proximity = %d", CLProximityUnknown]];
    if([unknownBeacons count])
        [_beacons setObject:unknownBeacons forKey:[NSNumber numberWithInt:CLProximityUnknown]];
    
    NSArray *immediateBeacons = [beacons filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"proximity = %d", CLProximityImmediate]];
    if([immediateBeacons count])
        [_beacons setObject:immediateBeacons forKey:[NSNumber numberWithInt:CLProximityImmediate]];
    
    NSArray *nearBeacons = [beacons filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"proximity = %d", CLProximityNear]];
    if([nearBeacons count])
        [_beacons setObject:nearBeacons forKey:[NSNumber numberWithInt:CLProximityNear]];
    
    NSArray *farBeacons = [beacons filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"proximity = %d", CLProximityFar]];
    if([farBeacons count])
        [_beacons setObject:farBeacons forKey:[NSNumber numberWithInt:CLProximityFar]];
    
    [beaconsTableView reloadData];
}

- (void)viewDidAppear:(BOOL)animated
{
    // Start ranging when the view appears.
    [appDelegate.regionsToScan enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        CLBeaconRegion *region = obj;
        [_locationManager startRangingBeaconsInRegion:region];
    }];
}

- (void)viewDidDisappear:(BOOL)animated
{
    // Stop ranging when the view goes away.
    [appDelegate.regionsToScan enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        CLBeaconRegion *region = obj;
        [_locationManager stopRangingBeaconsInRegion:region];
    }];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"Add Location";
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [self addCloseIconForModalVC];
    
    beaconsTableView = [[UITableView alloc] initWithFrame:self.view.bounds];
    beaconsTableView.delegate = self;
    beaconsTableView.dataSource = self;
    beaconsTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    beaconsTableView.separatorColor = [UIColor whiteColor];
    [self.view addSubview:beaconsTableView];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _beacons.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *sectionValues = [_beacons allValues];
    return [[sectionValues objectAtIndex:section] count];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    NSString *title = nil;
    NSArray *sectionKeys = [_beacons allKeys];
    
    // The table view will display beacons by proximity.
    NSNumber *sectionKey = [sectionKeys objectAtIndex:section];
    switch([sectionKey integerValue])
    {
        case CLProximityImmediate:
            title = @"Immediate";
            break;
            
        case CLProximityNear:
            title = @"Near";
            break;
            
        case CLProximityFar:
            title = @"Far";
            break;
            
        default:
            title = @"Unknown";
            break;
    }
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 30)];
    label.backgroundColor = [UIColor colorWithRed:234.0f/255.0f green:234.0f/255.0f blue:234.0f/255.0f alpha:1.0f];
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor darkGrayColor];
    label.text = title;
    
    return label;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 30;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *identifier = @"Cell";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
	if (cell == nil)
	{
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        UIView *backgroundView = [[UIView alloc] initWithFrame:CGRectMake(5, 5, 315, 45)];
        backgroundView.backgroundColor = [Utils themeColor];
        [cell addSubview:backgroundView];
        
        cell.textLabel.textColor = [UIColor whiteColor];
        [backgroundView addSubview:cell.textLabel];
	}
    
    // Display the UUID, major, minor and accuracy for each beacon.
    NSNumber *sectionKey = [[_beacons allKeys] objectAtIndex:indexPath.section];
    CLBeacon *beacon = [[_beacons objectForKey:sectionKey] objectAtIndex:indexPath.row];
    
    BOOL added = NO;
    for (Location *addedBeacon in appDelegate.locationsArray) {
        if ([addedBeacon.uuid isEqualToString:[beacon.proximityUUID UUIDString]] && addedBeacon.major == [beacon.major intValue] && addedBeacon.minor == [beacon.minor intValue]) {
            added = YES;
            cell.textLabel.text = addedBeacon.name;
            break;
        }
    }
    
    if (!added) {
        cell.textLabel.text = @"Unknown location, tap to define";
    }
	
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSNumber *sectionKey = [[_beacons allKeys] objectAtIndex:indexPath.section];
    _selectedBeacon = [[_beacons objectForKey:sectionKey] objectAtIndex:indexPath.row];
    
    BOOL added = NO;
    for (Location *addedBeacon in appDelegate.locationsArray) {
        if ([addedBeacon.uuid isEqualToString:[_selectedBeacon.proximityUUID UUIDString]] && addedBeacon.major == [_selectedBeacon.major intValue] && addedBeacon.minor == [_selectedBeacon.minor intValue]) {
            added = YES;
            break;
        }
    }
    
    if (!added) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"New place" message:@"Please assign a name to this location" delegate:self cancelButtonTitle:@"cancel" otherButtonTitles:@"add location", nil];
        alert.tag = ADD_ALERT_TAG;
        alert.alertViewStyle = UIAlertViewStylePlainTextInput;
        [alert show];
    }
}

#pragma mark UIAlertViewDelegate methods
- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag==ADD_ALERT_TAG && buttonIndex==1) {
        UITextField *textField = [alertView textFieldAtIndex:0];
        if (textField.text.length>0) {
            Location *location = [[Location alloc] initWithCLBeacon:_selectedBeacon name:textField.text];
            [appDelegate addLocation:location];
            [beaconsTableView reloadData];
        } else {
            //TODO prevent dismiss if text is equal to zero
        }
    }
}

@end
