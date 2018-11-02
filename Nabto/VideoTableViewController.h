//
//  VideoTableViewController.h
//  Nabto
//
//  Created by Martin Rodalgaard on 03/06/14.
//  Copyright (c) 2014 MRodalgaard. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AddVideoViewController.h"
#import "VideoPageViewController.h"
#import "Storage.h"
#import "ActivityViewWithLabel.h"

@interface VideoTableViewController : UITableViewController <UIActionSheetDelegate, AddVideoViewDelegate> {
    NSTimer *tunnelTimer;
    BOOL started;
    CGFloat titlePosition;
}

@property (nonatomic, retain)NSArray *localDevices;
@property (nonatomic, retain)NSArray *savedDevices;
@property (nonatomic, retain)VideoDevice *activeDevice;
@property (nonatomic, retain)NSString *activeState;
@property (nonatomic, retain)Storage *storage;

@property (nonatomic, retain)ActivityViewWithLabel *activityView;

@property (nonatomic, retain)UIView *helpView;
@property (nonatomic, retain)UIView *helpOverlay;

@end
