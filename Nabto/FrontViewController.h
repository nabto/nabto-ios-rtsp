//
//  FrontViewController.h
//  Nabto
//
//  Created by Martin Rodalgaard on 18/05/15.
//  Copyright (c) 2015 MRodalgaard. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AddVideoViewController.h"
#import "KxMovieViewController.h"
#import "Storage.h"
#import "ActivityViewWithLabel.h"

@interface FrontViewController : UIViewController <VideoDelegate, UIAlertViewDelegate> {
    NSTimer *tunnelTimer;
    bool isVisible;
}

@property (assign, nonatomic)NSInteger index;

@property (nonatomic, retain)VideoDevice *activeDevice;
@property (nonatomic, retain)ActivityViewWithLabel *activityView;
@property (nonatomic, retain)KxMovieViewController *videoViewController;

@property (nonatomic, strong)IBOutlet UIButton *videoButton;
@property (nonatomic, strong)IBOutlet UIImageView *videoImage;
@property (nonatomic, strong)IBOutlet UILabel *nameLabel;
@property (nonatomic, strong)IBOutlet UILabel *infoLabel;

- (IBAction)videoButtonClicked:(id)sender;

@end
