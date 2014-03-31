//
//  ViewController.m
//  task
//
//  Created by Tomasz Baranowicz on 12/27/13.
//  Copyright (c) 2013. All rights reserved.
//

#import "ViewController.h"

@interface ViewController () <UITableViewDataSource, UITableViewDelegate>
{
    NSArray *locationsArray;
    UITableView *locationsTableView;
}

- (void) refreshLocations;
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    locationsTableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    locationsTableView.delegate = self;
    locationsTableView.dataSource = self;
    [self.view addSubview:locationsTableView];
    
}

#pragma mark private methods

- (void) refreshLocations
{
    
    [locationsTableView reloadData];
}

@end
