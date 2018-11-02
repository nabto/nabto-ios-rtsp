//
//  VideoPageViewController.m
//  Nabto
//
//  Created by Martin Rodalgaard on 22/05/15.
//  Copyright (c) 2015 MRodalgaard. All rights reserved.
//

#import "VideoPageViewController.h"
#import "NabtoAppCommon.h"
#import <NabtoClient.h>


@interface VideoPageViewController ()

@end

@implementation VideoPageViewController

@synthesize pageControl, devices = _devices, tunnels = _tunnels, titleView, goToDevice;

- (NSArray *)devices {
    if (!_devices) {
        Storage *storage = [[Storage alloc] init];
        _devices = [storage getStarredDevices];
    }
    return _devices;
}

- (void)closeAllTunnels {
    for (VideoDevice *device in self.devices) {
        if (device.tunnel) {
            [[NabtoClient instance] nabtoTunnelClose:device.tunnel];
        }
    }
}

- (IBAction)listButtonClicked:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)addButtonClicked:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ApplicationHandleAddDevice" object:nil];
}

- (IBAction)pageButtonClicked:(id)sender {
    NSInteger page = ((UIPageControl *)sender).currentPage;
    FrontViewController *fvc = [self viewControllerAtIndex:page];
    [self.pageViewController setViewControllers:@[fvc] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
}

- (void)videoViewFullscreen:(NSNotification *)notification {
    BOOL fullscreen = [notification.object intValue];
    [self.navigationController setNavigationBarHidden:fullscreen animated:YES];
    
    if (fullscreen) {
        previousBounds = self.pageViewController.view.frame;
        
        // Jumpy animation when changing frame immediately
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0), dispatch_get_main_queue(), ^{
            CGRect newFrame = [[UIApplication sharedApplication].windows.lastObject frame];
            self.pageViewController.view.frame = CGRectMake(0, 0, newFrame.size.width, newFrame.size.height);
        });
    }
    else {
        self.pageViewController.view.frame = previousBounds;
    }
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // APP ENTRYPOINT (?)
    
    titleView.image = [UIImage imageNamed:@"NabtoVideoTitle"];
    
    self.navigationController.navigationBar.barTintColor = NABTO_ORANGE;
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    self.pageViewController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];

    self.pageViewController.view.contentMode = UIViewContentModeScaleAspectFit;
    self.pageViewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleBottomMargin;
    
    self.pageViewController.dataSource = self;
    self.pageViewController.delegate = self;
    
    [[self.pageViewController view] setFrame:CGRectMake(0, 0, [[self view] bounds].size.width, [[self view] bounds].size.height - self.pageControl.frame.size.height)];

    [self.pageControl setNumberOfPages:[self.devices count]];
    
    if (self.goToDevice) {
        currentIndex = [self getDeviceIndex:self.goToDevice];
        [self.pageControl setCurrentPage:currentIndex];
    }
    
    FrontViewController *fvc = [self viewControllerAtIndex:currentIndex];
    
    [self.pageViewController setViewControllers:@[fvc] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    
    [self addChildViewController:self.pageViewController];
    [[self view] addSubview:self.pageViewController.view];
    [self.pageViewController didMoveToParentViewController:self];
    [self.view bringSubviewToFront:self.pageViewController.view];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(videoViewFullscreen:)
                                                 name:@"videoViewFullscreen"
                                               object:nil];
}

- (NSInteger)getDeviceIndex:(VideoDevice *)device {
    NSInteger index = 0;
    for (VideoDevice *device in self.devices) {
        if ([device.uid isEqualToNumber:self.goToDevice.uid]) {
            break;
        }
        index++;
    }
    return index;
}

- (UIViewController *) pageViewController: (UIPageViewController *) pageViewController viewControllerBeforeViewController:(UIViewController *) viewController {
    NSUInteger index = [(FrontViewController *)viewController index];
    
    if (index == 0) {
        return nil;
    }
    index--;
    
    return [self viewControllerAtIndex:index];
}

- (UIViewController *) pageViewController: (UIPageViewController *) pageViewController viewControllerAfterViewController:(UIViewController *) viewController {
    NSUInteger index = [(FrontViewController *)viewController index];
    
    index++;
    if (index == [self.devices count]) {
        return nil;
    }
    
    return [self viewControllerAtIndex:index];
}

- (FrontViewController *)viewControllerAtIndex:(NSUInteger)index {
    FrontViewController *fvc = [self.storyboard instantiateViewControllerWithIdentifier: @"FrontViewID"];
    
    NSInteger count = [self.devices count];
    if (count > 0 && count > index) {
        fvc.activeDevice = [self.devices objectAtIndex:index];
    }
    
    fvc.index = index;
    return fvc;
}

- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed {
    FrontViewController *fvc = (FrontViewController *)[pageViewController.viewControllers lastObject];
    [self.pageControl setCurrentPage:fvc.index];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)dealloc {
    NSLog(@"Page view dealloc");
    [self closeAllTunnels];
}

@end
