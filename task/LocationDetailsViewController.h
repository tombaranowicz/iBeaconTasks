//
//  LocationDetailsViewController.h
//  task
//
//  Created by Tomasz Baranowicz on 12/28/13.
//  Copyright (c) 2013. All rights reserved.
//

#import "BaseViewController.h"
#import "Location.h"

@interface LocationDetailsViewController : BaseViewController
{
    Location *location;
}

- (id) initWithLocation:(Location *)location;
@end
