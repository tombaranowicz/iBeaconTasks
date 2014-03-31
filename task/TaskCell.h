//
//  TaskCell.h
//  task
//
//  Created by Tomasz Baranowicz on 1/28/14.
//  Copyright (c) 2014. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Task.h"

@interface TaskCell : UITableViewCell
{
    Task *task;
    UIView *backgroundView;
}

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier;
- (void)setTask:(Task *)task;

@property (nonatomic, strong, readonly) UILabel *descriptionLabel;

@end
