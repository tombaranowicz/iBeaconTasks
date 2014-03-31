//
//  CustomSignupViewController.m
//  task
//
//  Created by Tomasz Baranowicz on 12/27/13.
//  Copyright (c) 2013. All rights reserved.
//

#import "CustomSignupViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "Utils.h"

@interface CustomSignupViewController ()
@property (nonatomic, strong) UIImageView *fieldsBackground;
@end

@implementation CustomSignupViewController

@synthesize fieldsBackground;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.signUpView setBackgroundColor:[UIColor whiteColor]];
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo.png"]];
    imageView.frame = CGRectMake(0, 40, 320, 121);
    [self.signUpView addSubview:imageView];
    
    self.signUpView.usernameField.layer.borderWidth = 0.5f;
    self.signUpView.usernameField.layer.borderColor = [[Utils themeColor] CGColor];
    
    self.signUpView.passwordField.layer.borderWidth = 0.5f;
    self.signUpView.passwordField.layer.borderColor = [[Utils themeColor] CGColor];
    
    self.signUpView.emailField.layer.borderWidth = 0.5f;
    self.signUpView.emailField.layer.borderColor = [[Utils themeColor] CGColor];
    
    [self.signUpView.signUpButton setTitle:@"Sign Up" forState:UIControlStateNormal];
    
    [self.signUpView.dismissButton setImage:[UIImage imageNamed:@"icon_182_selected.png"] forState:UIControlStateNormal];
    
    // Add background for fields
    [self setFieldsBackground:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"SignUpFieldBG.png"]]];
    [self.signUpView insertSubview:fieldsBackground atIndex:1];
    
    // Remove text shadow
    CALayer *layer = self.signUpView.usernameField.layer;
    layer.shadowOpacity = 0.0f;
    layer = self.signUpView.passwordField.layer;
    layer.shadowOpacity = 0.0f;
    layer = self.signUpView.emailField.layer;
    layer.shadowOpacity = 0.0f;
    layer = self.signUpView.additionalField.layer;
    layer.shadowOpacity = 0.0f;
    
    // Set text color
    [self.signUpView.usernameField setTextColor:[UIColor colorWithRed:135.0f/255.0f green:118.0f/255.0f blue:92.0f/255.0f alpha:1.0]];
    [self.signUpView.passwordField setTextColor:[UIColor colorWithRed:135.0f/255.0f green:118.0f/255.0f blue:92.0f/255.0f alpha:1.0]];
    [self.signUpView.emailField setTextColor:[UIColor colorWithRed:135.0f/255.0f green:118.0f/255.0f blue:92.0f/255.0f alpha:1.0]];
    [self.signUpView.additionalField setTextColor:[UIColor colorWithRed:135.0f/255.0f green:118.0f/255.0f blue:92.0f/255.0f alpha:1.0]];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    self.signUpView.logo.frame = CGRectMake(0, 20, 320, 121);
    self.signUpView.signUpButton.frame = CGRectMake(35, 300, 250, 40);
    [self.signUpView.dismissButton setFrame:CGRectMake(10.0f, 10.0f, 30, 30)];
    
    
    float yOffset = 0.f;//[UIScreen mainScreen].bounds.size.height <= 480.0f ? 30.0f : 0.0f;
    CGRect fieldFrame = CGRectMake(35, 170, 250, 40);
    
    [self.fieldsBackground setFrame:CGRectMake(35.0f, fieldFrame.origin.y + yOffset, 250.0f, 174.0f)];
    
    [self.signUpView.usernameField setFrame:CGRectMake(fieldFrame.origin.x + 5.0f,
                                                       fieldFrame.origin.y + yOffset,
                                                       fieldFrame.size.width - 10.0f,
                                                       fieldFrame.size.height)];
    yOffset += fieldFrame.size.height;
    
    [self.signUpView.passwordField setFrame:CGRectMake(fieldFrame.origin.x + 5.0f,
                                                       fieldFrame.origin.y + yOffset,
                                                       fieldFrame.size.width - 10.0f,
                                                       fieldFrame.size.height)];
    yOffset += fieldFrame.size.height;
    
    [self.signUpView.emailField setFrame:CGRectMake(fieldFrame.origin.x + 5.0f,
                                                    fieldFrame.origin.y + yOffset,
                                                    fieldFrame.size.width - 10.0f,
                                                    fieldFrame.size.height)];
    yOffset += fieldFrame.size.height;
    
    [self.signUpView.additionalField setFrame:CGRectMake(fieldFrame.origin.x + 5.0f,
                                                         fieldFrame.origin.y + yOffset,
                                                         fieldFrame.size.width - 10.0f,
                                                         fieldFrame.size.height)];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end