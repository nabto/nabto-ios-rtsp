//
//  FrontViewController.m
//  Nabto
//
//  Created by Martin Rodalgaard on 18/05/15.
//  Copyright (c) 2015 MRodalgaard. All rights reserved.
//

#import "FrontViewController.h"
#import "Reachability.h"
#import "WebVideoViewController.h"
#import "VideoPageViewController.h"
#import "kxmovie/KxMovieViewController.h"
#import "InfoTableViewController.h"
#import "NabtoAppCommon.h"
#import "NabtoClient/NabtoClient.h"


@interface FrontViewController ()

@end

@implementation FrontViewController

@synthesize activeDevice = _activeDevice, videoViewController;

- (ActivityViewWithLabel *)activityView {
    if (!_activityView) {
        _activityView = [[ActivityViewWithLabel alloc] init];
    }
    return _activityView;
}

- (void)updateStatus:(NSString *)status {
    [self.activityView text:status];
    [self.activityView start];
}

- (NSString *)getUrl {
    int port = [[NabtoClient instance] nabtoTunnelPort:self.activeDevice.tunnel];
    
    NSString *auth = @"";
    if ([self.activeDevice.user length] != 0) {
        auth = [NSString stringWithFormat:@"%@:%@@", self.activeDevice.user, self.activeDevice.pass];
    }
    
    NSString *baseUrl = [NSString stringWithFormat:@"://%@localhost:%i", auth, port];
    if (![[self.activeDevice.url substringFromIndex:0] isEqualToString:@"/"]) {
        baseUrl = [NSString stringWithFormat:@"%@/", baseUrl];
    }
    return [baseUrl stringByAppendingString:self.activeDevice.url];
}

- (void)startKxMovie {
    if (!isVisible) {
        return;
    }

    if (!self.videoViewController || !self.videoViewController.hasValidDecoder) {
        NSString *path = [@"rtsp" stringByAppendingString:[self getUrl]];
        self.videoViewController = [KxMovieViewController movieViewControllerWithContentPath:path parameters:nil];
        self.videoViewController.videoDelegate = self;
        self.videoViewController.view.contentMode = UIViewContentModeScaleAspectFit;
        self.videoViewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleBottomMargin;
        
        [self.videoViewController willMoveToParentViewController:self];
        [self.view addSubview:self.videoViewController.view];
        [self addChildViewController:self.videoViewController];
        [self.videoViewController didMoveToParentViewController:self];
    }
    
    [self.videoViewController playFromNow];
    
    self.videoViewController.view.bounds = self.videoButton.bounds;
    self.videoViewController.view.center = self.videoButton.center;
}

- (void)startWeb {
    self.videoButton.hidden = NO;
    [self.videoButton setTitle:@"Open Web View" forState:UIControlStateNormal];
}

- (void)handleTunnelError:(NabtoTunnelState)state {
    NSString *stateString = [NabtoClient nabtoTunnelInfoString:state];
    int status = [[NabtoClient instance] nabtoTunnelError:self.activeDevice.tunnel];
    
    // If no apparent error, try again
    if (status == 0) {
        return [self openVideo:self.activeDevice];
    }
    // If stream error, give nicer error message
#if 0
    // NABTO-1576
    else if (status - 1000000 == NABTO_INVALID_STREAM || status - 1000000 == NABTO_INVALID_SESSION) {
        [self.activityView failed:[NSString stringWithFormat:@"device not available"]];
    }
    // Else report error to user
#endif
    else {
        [self.activityView failed:[NSString stringWithFormat:@"%@: %i", stateString, status]];
    }
    
    [tunnelTimer invalidate];
    
    // Try to reconnect if port is in use
    if (status == 2000045) {
        [self openVideo:self.activeDevice];
    }
}

- (void)statusTimer {
    NabtoTunnelState state = [[NabtoClient instance] nabtoTunnelInfo:self.activeDevice.tunnel];
    
    NSLog(@"statusTimer");
    
    if (state > NTS_UNKNOWN) {
        [self.activityView persistentSuccess:[NabtoClient nabtoTunnelInfoString:state]];
        [self startVideo:self.activeDevice];
    }
    else if (state == NTS_CLOSED) {
        [self handleTunnelError:state];
    }
    else {
        [self updateStatus:[NabtoClient nabtoTunnelInfoString:state]];
    }
}

- (void)startVideo:(VideoDevice *)device {
    [tunnelTimer invalidate];

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        // Make sure view is still active
        if (!isVisible) {
            return;
        }
        
        if (device.type == MPEG) {
            [self startKxMovie];
        }
        else if (device.type == WEB) {
            [self startWeb];
        }
    });
}

- (void)openVideo:(VideoDevice *)device {
    if (self.activeDevice.tunnel) {
        NabtoTunnelState state = [[NabtoClient instance] nabtoTunnelInfo:self.activeDevice.tunnel];
        if (state == NTS_CONNECTING) {
            return;
        }
        else if (state > NTS_UNKNOWN) {
            [self.activityView persistentSuccess:[NabtoClient nabtoTunnelInfoString:state]];
            [self startVideo:self.activeDevice];
            return;
        }
    }

    [tunnelTimer invalidate];
    [[NabtoClient instance] nabtoTunnelClose:self.activeDevice.tunnel];
    
    if (![self getNetworkStatus]) {
        [self.activityView failed:@"no internet connection"];
        return;
    }
    
    NabtoTunnelHandle tunnel;
    NabtoClientStatus status = [[NabtoClient instance] nabtoTunnelOpenTcp:&tunnel toHost:device.name remoteHost:device.host onPort:device.port];
    self.activeDevice.tunnel = tunnel;
    
    if (status != NCS_OK) {
        [self updateStatus:[NabtoClient nabtoStatusString:status]];
    }
    else {
        tunnelTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(statusTimer) userInfo:nil repeats:YES];
        [self updateStatus:[NabtoClient nabtoTunnelInfoString:NTS_CONNECTING]];
    }
}

- (void)closeVideo {
    [tunnelTimer invalidate];
    [self.activityView stop];
    if (self.activeDevice.tunnel) {
        [[NabtoClient instance] nabtoTunnelClose:self.activeDevice.tunnel];
        self.activeDevice.tunnel = nil;
    }
}

- (BOOL)getNetworkStatus {
    //NSString *remoteHostName = @"www.nabto.com";
    //Reachability *reach = [Reachability reachabilityWithHostName:remoteHostName];
    //[reach startNotifier];
    
    Reachability *reach = [Reachability reachabilityForInternetConnection];
    return [reach currentReachabilityStatus] != NotReachable;
}

- (void)resetSession {
    [self.videoViewController removeFromParentViewController];
    self.videoViewController = nil;
    [[NabtoClient instance] nabtoTunnelClose:self.activeDevice.tunnel];
    self.activeDevice.tunnel = nil;
    [[NabtoClient instance] nabtoCloseSession];
    [[NabtoClient instance] nabtoOpenSessionGuest];
}

- (NSDictionary *)createInfoDictionary {
    NSMutableDictionary *info = [[NSMutableDictionary alloc] init];
    [info setObject:self.activeDevice.name forKey:@"Name"];
    [info setObject:self.activeDevice.title forKey:@"Title"];
    [info setObject:[VideoDevice typeToString:self.activeDevice.type] forKey:@"Type"];
    [info setObject:[NSString stringWithFormat:@"%i", self.activeDevice.port] forKey:@"Port"];
    [info setObject:self.activeDevice.url forKey:@"URL"];
    [info setObject:[[NabtoClient instance] nabtoVersion] forKey:@"Nabto Version"];
    
    NabtoTunnelState state = [[NabtoClient instance] nabtoTunnelInfo:self.activeDevice.tunnel];
    [info setObject:[NabtoClient nabtoTunnelInfoString:state] forKey:@"Connection"];
    
    return [info copy];
}

#pragma mark - View Segue, Delegates and Actions

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"WebSegue"]) {
        WebVideoViewController *wvvc = [segue destinationViewController];
        wvvc.url = [@"http" stringByAppendingString:[self getUrl]];
    }
    else if ([[segue identifier] isEqualToString:@"InfoSegue"]) {
        InfoTableViewController *itvc = [segue destinationViewController];
        if (self.activeDevice) {
            itvc.info = [self createInfoDictionary];
        }
    }
}

- (void)videoMessage:(BOOL)start withMessage:(NSString *)message {
    if (start) {
        [self.activityView text:message];
        [self.activityView start];
    }
    else {
        [self.activityView stop];
    }
}

- (void)videoFailed:(NSString *)message {
    [self.activityView failed:message];
}

- (void)videoReconnect {
    [self.videoViewController removeFromParentViewController];
    [self resetSession];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [self.activityView text:@"reconnecting..."];
        [self.activityView start];
    });
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [self openVideo:self.activeDevice];
    });
}

- (IBAction)videoButtonClicked:(id)sender {
    if (self.activeDevice && self.activeDevice.type == WEB) {
        [self performSegueWithIdentifier:@"WebSegue" sender:nil];
    }
    else {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ApplicationHandleAddDevice" object:self.activeDevice];
    }
}

- (void)authenticationError:(NSNotification *)notification {
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self isViewLoaded] && self.view.window) {
            [self closeVideo];
            
            dispatch_after(0, dispatch_get_main_queue(), ^{
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Login" message:@"Authentication needed" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Login", nil];
                alert.alertViewStyle = UIAlertViewStyleLoginAndPasswordInput;
                [alert show];
            });
        }
    });
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    [alertView removeFromSuperview];

    [self.videoViewController removeFromParentViewController];
    self.videoViewController = nil;

    NSString *user = [alertView textFieldAtIndex:0].text;
    NSString *pass = [alertView textFieldAtIndex:1].text;
    [self.activeDevice setAuth:user withPass:pass];
    Storage *storage = [[Storage alloc] init];
    [storage saveDevice:self.activeDevice];

    if ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"Login"]) {
        [self openVideo:self.activeDevice];
    }
}

#pragma mark - View lifecycle

- (void)applicationWillResignActive:(NSNotification *)notification {
//    [self closeVideo];
    [self resetSession];
}

- (void)applicationDidBecomeActive:(NSNotification *)notification {
    // Reopen video again after multitask, notification center and control center menu
    if (self.activeDevice) {
        [self openVideo:self.activeDevice];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.navigationController.navigationBar.barTintColor = NABTO_ORANGE;
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    UIImage *logo = [UIImage imageNamed:@"NabtoVideoTitle"];
    UIImageView *titleView = [[UIImageView alloc] initWithImage:logo];
    self.navigationItem.titleView = titleView;
    
    [self.videoButton.layer setCornerRadius:10.0f];
    
    [self.view addSubview:self.activityView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationWillResignActive:)
                                                 name:UIApplicationWillResignActiveNotification
                                               object:[UIApplication sharedApplication]];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationDidBecomeActive:)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:[UIApplication sharedApplication]];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(authenticationError:)
                                                 name:@"decoderAuthenticationError"
                                               object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (self.activeDevice) {
        self.videoImage.hidden = YES;
        self.videoButton.hidden = YES;

        self.nameLabel.text = self.activeDevice.title;
        self.infoLabel.text = [VideoDevice typeToString:self.activeDevice.type];
    }
    else {
        self.nameLabel.text = @"No Device";
        self.infoLabel.text = @"Unknown";
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    isVisible = YES;
    
    NSLog(@"viewDidAppear: %@ [tunnel: %lu]", self.activeDevice.title, (unsigned long)self.activeDevice.tunnel);
    
    if (self.activeDevice) {
        [self openVideo:self.activeDevice];
    }
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    self.activityView.center = self.view.center;
    [self.view bringSubviewToFront:self.activityView];

    self.videoViewController.view.bounds = self.videoButton.bounds;
    self.videoViewController.view.center = self.videoButton.center;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self.activityView stop];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    isVisible = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)dealloc {
    NSLog(@"Video view dealloc");
    self.videoViewController.videoDelegate = nil;
    self.videoViewController = nil;
}

@end
