//
//  VideoPageViewController.h
//  Nabto
//
//  Created by Martin Rodalgaard on 22/05/15.
//  Copyright (c) 2015 MRodalgaard. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FrontViewController.h"
#import "Storage.h"

@interface VideoPageViewController : UIViewController <UIPageViewControllerDataSource, UIPageViewControllerDelegate> {
    NSInteger currentIndex;
    CGRect previousBounds;
}

@property (nonatomic, strong) UIPageViewController *pageViewController;
@property (nonatomic, retain)IBOutlet UIPageControl *pageControl;

@property (nonatomic, strong) NSArray *devices;
@property (nonatomic, retain) NSArray *tunnels;
@property (nonatomic, retain) VideoDevice *goToDevice;

@property (nonatomic, strong)IBOutlet UIImageView *titleView;

- (IBAction)listButtonClicked:(id)sender;
- (IBAction)addButtonClicked:(id)sender;
- (IBAction)pageButtonClicked:(id)sender;

@end
