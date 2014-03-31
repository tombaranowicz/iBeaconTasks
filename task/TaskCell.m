//
//  TaskCell.m
//  task
//
//  Created by Tomasz Baranowicz on 1/28/14.
//  Copyright (c) 2014. All rights reserved.
//

#import "TaskCell.h"
#import "UIColor+iOS7Colors.h"

@implementation TaskCell

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    if (self) {
        
        backgroundView = [[UIView alloc] initWithFrame:CGRectMake(5, 5, 315, 40)];
        backgroundView.backgroundColor = [Utils themeColor];
        [self addSubview:backgroundView];
        
        _descriptionLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, self.frame.size.width-60, 20)];
        _descriptionLabel.textAlignment = NSTextAlignmentJustified;
        _descriptionLabel.font = [UIFont systemFontOfSize:16.0f];
        _descriptionLabel.numberOfLines = 0;
        _descriptionLabel.textColor = [UIColor whiteColor];
        [self addSubview:_descriptionLabel];
    }
    return self;
}

- (void)setTask:(Task *)task_
{
    task = task_;
    CGRect frame = _descriptionLabel.frame;
    
    UIFont *cellFont = [UIFont systemFontOfSize:16.0f];
    CGSize constraintSize = CGSizeMake(frame.size.width, MAXFLOAT);
    CGSize labelSize = [task.description sizeWithFont:cellFont constrainedToSize:constraintSize lineBreakMode:NSLineBreakByWordWrapping];
    
    frame.size.height = labelSize.height;
    _descriptionLabel.frame = frame;
    _descriptionLabel.text = task.description;
    
    
    backgroundView.frame = CGRectMake(5, 5, 315, labelSize.height+10);
    
    DLOG(@"TASK LABEL: %@", NSStringFromCGRect(frame));
    
    if (task.type==ENTRY_TASK) {
        self.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"703-download_white.png"]];
    } else {
        self.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"702-share_white.png"]];
    }
}

@end
