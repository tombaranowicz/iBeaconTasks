//
//  LocationCell.m
//  task
//
//  Created by Tomasz Baranowicz on 12/27/13.
//  Copyright (c) 2013. All rights reserved.
//

#import "LocationCell.h"
#import "UIColor+iOS7Colors.h"

@implementation LocationCell

-(id)initWithReuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    if (self) {
        
        self.backgroundColor = [UIColor clearColor];
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, LOCATION_CELL_HEIGHT-4)];
        view.backgroundColor = [UIColor colorWithRed:234.0f/255.0f green:234.0f/255.0f blue:234.0f/255.0f alpha:1.0f];
        
        CALayer *layer = view.layer;
        layer.shadowOffset = CGSizeMake(2, 2);
        layer.shadowColor = [[UIColor blackColor] CGColor];
        layer.shadowRadius = 1.0f;
        layer.shadowOpacity = 0.50f;
        layer.shadowPath = [[UIBezierPath bezierPathWithRect:layer.bounds] CGPath];
        
        [self addSubview:view];
        
        nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(60, 20, self.frame.size.width-100, 20)];
        nameLabel.font = [UIFont boldSystemFontOfSize:18];
        nameLabel.textColor = [UIColor darkGrayColor];//[UIColor colorWithRed:31.0f/255.0f green:187.0f/255.0f blue:166.0f/255.0f alpha:1.0f];//[Utils themeColor];//[UIColor whiteColor];
        [self addSubview:nameLabel];
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 21, 16)];
        imageView.image = [UIImage imageNamed:@"703-download.png"];
        [self addSubview:imageView];
        entryTasksLabel = [[UILabel alloc] initWithFrame:CGRectMake(35, 10, 30, 16)];
        entryTasksLabel.font = [UIFont systemFontOfSize:14.0f];
        entryTasksLabel.textColor = [UIColor darkGrayColor];
        [self addSubview:entryTasksLabel];
        
        imageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 35, 21, 16)];
        imageView.image = [UIImage imageNamed:@"702-share.png"];
        [self addSubview:imageView];
        exitTasksLabel = [[UILabel alloc] initWithFrame:CGRectMake(35, 35, 30, 16)];
        exitTasksLabel.font = [UIFont systemFontOfSize:14.0f];
        exitTasksLabel.textColor = [UIColor darkGrayColor];
        [self addSubview:exitTasksLabel];
    }
    return self;
}

- (void)setLocation:(Location *)location position:(int)position
{
    nameLabel.text = location.name;
    int entryTasks = 0;
    int exitTasks = 0;
    
    for (Task *task in location.tasks) {
        if (task.type==ENTRY_TASK) {
            entryTasks++;
        } else {
            exitTasks++;
        }
    }
    entryTasksLabel.text = [NSString stringWithFormat:@"%d", entryTasks];
    exitTasksLabel.text = [NSString stringWithFormat:@"%d", exitTasks];
}

@end
