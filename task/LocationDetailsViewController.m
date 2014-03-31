//
//  LocationDetailsViewController.m
//  task
//
//  Created by Tomasz Baranowicz on 12/28/13.
//  Copyright (c) 2013. All rights reserved.
//

#import "LocationDetailsViewController.h"
#import "TaskCreateAlertView.h"
#import "AppDelegate.h"
#import "Task.h"
#import "TaskCell.h"

#define CELL_IDENTIFIER @"taskCellIdentifier"

@interface LocationDetailsViewController () <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>
{
    AppDelegate *appDelegate;
    
    UITableView *tasksTableView;
    UITextField *taskTextField;
    UISegmentedControl *taskSegment;
}
@end

@implementation LocationDetailsViewController

- (id) initWithLocation:(Location *)location_
{
    self = [super init];
    if (self) {
        location = location_;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = location.name;
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addTaskHandler)];
    
    tasksTableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    tasksTableView.delegate = self;
    tasksTableView.dataSource = self;
    tasksTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.view addSubview:tasksTableView];
}

#pragma mark private methods
- (void) addTaskHandler
{
    TaskCreateAlertView *alertView = [[TaskCreateAlertView alloc] init];
    UIView *containerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 290, 150)];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 280, 25)];
    label.text = @"New task";
    label.font = [UIFont boldSystemFontOfSize:20.0f];
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [Utils themeColor];
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
            Task *task = [[Task alloc] init];
            task.description = taskTextField.text;
            task.taskId = [[NSDate date] timeIntervalSince1970];
            
            if (taskSegment.selectedSegmentIndex==0) {
                task.type = ENTRY_TASK;
            } else {
                task.type = EXIT_TASK;
            }
            
            [location addTask:task];
            [tasksTableView reloadData];
            [alertView close];
        }
    }];
    
    [alertView setUseMotionEffects:true];
    [alertView show];
    
    [taskTextField becomeFirstResponder];
}

#pragma mark UITableView methods

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Task *task = [location.tasks objectAtIndex:indexPath.row];
    UIFont *cellFont = [UIFont systemFontOfSize:16.0f];
    CGSize constraintSize = CGSizeMake(self.view.frame.size.width-60, MAXFLOAT);
    CGSize labelSize = [task.description sizeWithFont:cellFont constrainedToSize:constraintSize lineBreakMode:NSLineBreakByWordWrapping];
    return labelSize.height+20;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [location removeTask:[location.tasks objectAtIndex:indexPath.row]];
        [tasksTableView reloadData];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return location.tasks.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TaskCell *cell = [tableView dequeueReusableCellWithIdentifier:CELL_IDENTIFIER];
    if (!cell) {
        cell = [[TaskCell alloc] initWithReuseIdentifier:CELL_IDENTIFIER];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    [cell setTask:[location.tasks objectAtIndex:indexPath.row]];
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 30)];
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [Utils themeColor];
    label.text = @"Tasks assigned to this location";
    
    return label;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 30;
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