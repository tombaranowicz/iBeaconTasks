//
//  CustomLoginViewController.m
//  task
//
//  Created by Tomasz Baranowicz on 12/27/13.
//  Copyright (c) 2013. All rights reserved.
//
#import "CustomLoginViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "Utils.h"

@interface CustomLoginViewController ()
@property (nonatomic, strong) UIImageView *fieldsBackground;
@end

@implementation CustomLoginViewController

@synthesize fieldsBackground;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.logInView setBackgroundColor:[UIColor whiteColor]];
    self.logInView.logo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo.png"]];
    
    self.logInView.usernameField.layer.borderWidth = 0.5f;
    self.logInView.usernameField.layer.borderColor = [[Utils themeColor] CGColor];
    
    self.logInView.passwordField.layer.borderWidth = 0.5f;
    self.logInView.passwordField.layer.borderColor = [[Utils themeColor] CGColor];
    
    [self.logInView.signUpButton setTitle:@"Sign Up" forState:UIControlStateNormal];
    
    [self.logInView.passwordForgottenButton setTitle:@"Forgot password?" forState:UIControlStateNormal];
    [self.logInView.passwordForgottenButton setBackgroundImage:nil forState:UIControlStateNormal];
    [self.logInView.passwordForgottenButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    self.logInView.passwordForgottenButton.titleLabel.font = [UIFont systemFontOfSize:13.0f];
    
    // Add login field background
    fieldsBackground = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"LoginFieldBG.png"]];
    [self.logInView addSubview:self.fieldsBackground];
    [self.logInView sendSubviewToBack:self.fieldsBackground];
    
    // Remove text shadow
    CALayer *layer = self.logInView.usernameField.layer;
    layer.shadowOpacity = 0.0f;
    layer = self.logInView.passwordField.layer;
    layer.shadowOpacity = 0.0f;
    
    // Set field text color
    [self.logInView.usernameField setTextColor:[UIColor colorWithRed:135.0f/255.0f green:118.0f/255.0f blue:92.0f/255.0f alpha:1.0]];
    [self.logInView.passwordField setTextColor:[UIColor colorWithRed:135.0f/255.0f green:118.0f/255.0f blue:92.0f/255.0f alpha:1.0]];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    self.logInView.logo.frame = CGRectMake(0, 20, 320, 121);
    [self.logInView.logInButton setFrame:CGRectMake(35, 260, 250, 40)];
    
    self.logInView.passwordForgottenButton.frame = CGRectMake(35, 305, 250, 20);
    
    self.logInView.externalLogInLabel.frame = CGRectMake(10, 320+20, 300, 20);
    self.logInView.facebookButton.frame = CGRectMake(35, 340+20, 250, 40);
    
    self.logInView.signUpLabel.frame = CGRectMake(10, 400+20, 300, 20);
    [self.logInView.signUpButton setFrame:CGRectMake(35.0f, 420+20, 250.0f, 40.0f)];
    
    // Set frame for elements
    [self.logInView.dismissButton setFrame:CGRectMake(-10.0f, -10.0f, 87.5f, 45.5f)];
    self.logInView.dismissButton.userInteractionEnabled=NO;
    self.logInView.dismissButton.alpha=0.0f;
    
    [self.logInView.usernameField setFrame:CGRectMake(35.0f, 145.0f, 250.0f, 50.0f)];
    [self.logInView.passwordField setFrame:CGRectMake(35.0f, 195.0f, 250.0f, 50.0f)];
    [self.fieldsBackground setFrame:CGRectMake(35.0f, 145.0f, 250.0f, 100.0f)];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end