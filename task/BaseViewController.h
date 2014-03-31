//
//  BaseViewController.h
//  task
//
//  Created by Tomasz Baranowicz on 12/27/13.
//  Copyright (c) 2013. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Location.h"

@interface BaseViewController : UIViewController
{
    
}

-(void)addCloseIconForModalVC;
-(void)closeModalViewController;
-(void)pushModalViewController:(UIViewController *)modalViewController;



@end
