//
//  BaseViewController.m
//  task
//
//  Created by Tomasz Baranowicz on 12/27/13.
//  Copyright (c) 2013. All rights reserved.
//

#import "BaseViewController.h"

@interface BaseViewController ()

@end

@implementation BaseViewController

- (id)init
{
    self = [super init];
    if (self) {

    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"back" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.navigationItem.backBarButtonItem = backButton;
}

-(void)addCloseIconForModalVC
{
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(closeModalViewController)];
}

-(void)closeModalViewController
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

-(void)pushModalViewController:(UIViewController *)modalViewController
{
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:modalViewController];
    navController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    [self.navigationController presentViewController:navController animated:YES completion:nil];
}

@end
