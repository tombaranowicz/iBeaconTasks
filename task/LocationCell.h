//
//  LocationCell.h
//  task
//
//  Created by Tomasz Baranowicz on 12/27/13.
//  Copyright (c) 2013. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Location.h"

#define LOCATION_CELL_HEIGHT 60

@interface LocationCell : UITableViewCell
{
    UILabel *nameLabel;
    UILabel *entryTasksLabel;
    UILabel *exitTasksLabel;
}

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier;
- (void)setLocation:(Location *)location position:(int)position;
@end
