//
//  LocationsListViewController.m
//  task
//
//  Created by Tomasz Baranowicz on 12/27/13.
//  Copyright (c) 2013. All rights reserved.
//

#import "LocationsListViewController.h"
#import "LocationCell.h"
#import "AddLocationViewController.h"
#import "AppDelegate.h"
#import "Location.h"
#import "LocationDetailsViewController.h"
#import "TaskCreateAlertView.h"
#import "UIColor+iOS7Colors.h"
#import "TaskCell.h"

#define CELL_IDENTIFIER @"locationCellIdentifier"
#define ADD_TASK_ALERT_TAG 1001

@interface LocationsListViewController () <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, UIAlertViewDelegate>
{
    UITableView *locationsTableView;
    
    UITextField *taskTextField;
    UISegmentedControl *taskSegment;
    
    AppDelegate *appDelegate;
    UIAlertView *deleteAlertView;
}

- (void) refreshLocations;
- (void) addLocationHandler;
- (void) accessoryButtonHandler:(UIButton *)button;
- (void) receivedSyncNotification;

@end

@implementation LocationsListViewController

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if ([PFUser currentUser]) {
        [self refreshLocations];
    } else {
        [appDelegate showLogin];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    self.title = @"My Locations";
    
    locationsTableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    locationsTableView.delegate = self;
    locationsTableView.dataSource = self;
    locationsTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    locationsTableView.separatorInset = UIEdgeInsetsMake(15, 0, 0, 0);
    locationsTableView.separatorColor = [UIColor whiteColor];
    locationsTableView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:locationsTableView];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addLocationHandler)];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receivedSyncNotification)
                                                 name:SYNC_FINISHED_NOTIFICATION
                                               object:nil];
}

#pragma mark private methods
- (void) receivedSyncNotification
{
    [locationsTableView reloadData];
}

- (void) accessoryButtonHandler:(UIButton *)button
{
    TaskCreateAlertView *alertView = [[TaskCreateAlertView alloc] init];
    UIView *containerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 290, 150)];

    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 280, 25)];
    label.text = @"New task";
    label.font = [UIFont boldSystemFontOfSize:20.0f];
    label.textColor = [Utils themeColor];
    label.textAlignment = NSTextAlignmentCenter;
    [containerView addSubview:label];
    
    taskSegment = [[UISegmentedControl alloc] initWithItems:@[@"on entry",@"on exit"]];
    taskSegment.frame = CGRectMake(70, 45, 150, 30);
    taskSegment.selectedSegmentIndex=0;
    taskSegment.tintColor = [Utils themeColor];
    [containerView addSubview:taskSegment];
    
    taskTextField = [[UITextField alloc] initWithFrame:CGRectMake(10, 100, 270, 30)];
    taskTextField.layer.borderWidth = 1.0f;
    taskTextField.layer.borderColor = [[Utils themeColor] CGColor];
    taskTextField.layer.cornerRadius = 5.0f;
    taskTextField.placeholder = @"Task description";
    taskTextField.delegate = self;
    [containerView addSubview:taskTextField];
    
    [alertView setContainerView:containerView];
    [alertView setButtonTitles:[NSMutableArray arrayWithObjects:@"Cancel", @"Add task", nil]];
    
    [alertView setOnButtonTouchUpInside:^(TaskCreateAlertView *alertView, int buttonIndex) {
        if (buttonIndex==0) { //cancel
            [alertView close];
        } else if(taskTextField.text.length==0) {
            taskTextField.layer.borderColor = [[UIColor redColor] CGColor];
            taskTextField.placeholder = @"Task description cannot be empty!";
        } else {
            Location *location = [appDelegate.locationsArray objectAtIndex:button.tag];
            
            Task *task = [[Task alloc] init];
            task.description = taskTextField.text;
            task.taskId = [[NSDate date] timeIntervalSince1970];
            
            if (taskSegment.selectedSegmentIndex==0) {
                task.type = ENTRY_TASK;
            } else {
                task.type = EXIT_TASK;
            }
            
            [location addTask:task];
            [locationsTableView reloadData];
            [alertView close];
        }
    }];
    
    [alertView setUseMotionEffects:true];
    [alertView show];
    [taskTextField becomeFirstResponder];
}

- (void) addLocationHandler
{
    AddLocationViewController *vc = [[AddLocationViewController alloc] init];
    [self pushModalViewController:vc];
}

- (void) refreshLocations
{
    if (!appDelegate.locationsArray) {
        DLOG(@"USE LOCATIONS FROM PARSE");
        [appDelegate syncWithParse];
    } else {
        DLOG(@"USE LOCATIONS FROM APP DELEGATE");
        [locationsTableView reloadData];
    }
}

#pragma mark UITableView methods
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        Location *location = [appDelegate.locationsArray objectAtIndex:indexPath.section];
        [location removeTask:[location.tasks objectAtIndex:indexPath.row]];
        [locationsTableView reloadData];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return appDelegate.locationsArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[[appDelegate.locationsArray objectAtIndex:section] tasks] count];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    LocationCell *cell = [[LocationCell alloc] initWithReuseIdentifier:CELL_IDENTIFIER];
    [cell setLocation:[appDelegate.locationsArray objectAtIndex:section] position:section];
    cell.tag = section;
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(self.view.frame.size.width-50, 10, 40,40);
    [button setTitle:@"+" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont systemFontOfSize:30.f];
    button.tag = section;
    [button addTarget:self action:@selector(accessoryButtonHandler:) forControlEvents:UIControlEventTouchUpInside];
    [cell addSubview:button];
    
    CALayer *layer = cell.layer;
    layer.shadowOffset = CGSizeMake(1, 1);
    layer.shadowColor = [[UIColor blackColor] CGColor];
    layer.shadowRadius = 4.0f;
    layer.shadowOpacity = 0.80f;
    layer.shadowPath = [[UIBezierPath bezierPathWithRect:layer.bounds] CGPath];
    
    UILongPressGestureRecognizer *tapGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(headerLongPressHandler:)];
    [cell addGestureRecognizer:tapGestureRecognizer];
    
    return cell;
}

- (void) headerLongPressHandler: (UILongPressGestureRecognizer *)recognizer
{
    if (!deleteAlertView) {
        Location *location = [appDelegate.locationsArray objectAtIndex:recognizer.view.tag];
        deleteAlertView = [[UIAlertView alloc] initWithTitle:@"Delete confirm" message:[NSString stringWithFormat:@"Are you sure you want to delete %@", location.name] delegate:self cancelButtonTitle:@"no" otherButtonTitles:@"yes", nil];
        deleteAlertView.tag = recognizer.view.tag;
        [deleteAlertView show];
    }
}

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView==deleteAlertView) {
        if (buttonIndex==1) {
            Location *location = [appDelegate.locationsArray objectAtIndex:alertView.tag];
            [appDelegate deleteLocation:location];
            [locationsTableView reloadData];
        }
        deleteAlertView = nil;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return LOCATION_CELL_HEIGHT;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Task *task = [[[appDelegate.locationsArray objectAtIndex:indexPath.section] tasks] objectAtIndex:indexPath.row];
    UIFont *cellFont = [UIFont systemFontOfSize:16.0f];
    CGSize constraintSize = CGSizeMake(self.view.frame.size.width-60, MAXFLOAT);
    CGSize labelSize = [task.description sizeWithFont:cellFont constrainedToSize:constraintSize lineBreakMode:NSLineBreakByWordWrapping];
    return labelSize.height+20;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TaskCell *cell = [tableView dequeueReusableCellWithIdentifier:CELL_IDENTIFIER];
    if (!cell) {
        cell = [[TaskCell alloc] initWithReuseIdentifier:CELL_IDENTIFIER];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    [cell setTask:[[[appDelegate.locationsArray objectAtIndex:indexPath.section] tasks] objectAtIndex:indexPath.row]];
    return cell;
}

#pragma mark UITextFieldDelegate method

- (BOOL)textField:(UITextField *) textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    NSUInteger oldLength = [textField.text length];
    NSUInteger replacementLength = [string length];
    NSUInteger rangeLength = range.length;
    
    NSUInteger newLength = oldLength - rangeLength + replacementLength;
    
    BOOL returnKey = [string rangeOfString: @"\n"].location != NSNotFound;
    
    return newLength <= TASK_MAXLENGTH || returnKey;
}

@end
