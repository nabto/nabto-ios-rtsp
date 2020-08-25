//
//  VideoTableViewController.m
//  Nabto
//
//  Created by Martin Rodalgaard on 03/06/14.
//  Copyright (c) 2014 MRodalgaard. All rights reserved.
//

#import "VideoTableViewController.h"
#import "Storage.h"
#import "NabtoAppCommon.h"
#import "NabtoClient/NabtoClient.h"



@interface VideoTableViewController ()

@end

@implementation VideoTableViewController

@synthesize storage = _storage, localDevices = _localDevices, savedDevices = _savedDevices, activeDevice = _activeDevice, activityView = _activityView;
@synthesize helpView, helpOverlay;

#define TAG_OFFSET 3000

//#define LOCALWHITELIST @"demo.nab.to", @"axis.nabto.net", @"video.nabto.net"

- (Storage *)storage {
    if (!_storage) {
        _storage = [[Storage alloc] init];
    }
    return _storage;
}

- (NSArray *)localDevices {
    if (!_localDevices) {
        NSMutableArray *mDevices = [[NSMutableArray alloc] init];
        
        for (NSString *name in [[NabtoClient instance] nabtoGetLocalDevices]) {
#ifdef LOCALWHITELIST
            NSArray *whiteList = [[NSArray alloc] initWithObjects:LOCALWHITELIST, nil];
            for (NSString *whiteName in whiteList) {
                if ([name hasSuffix:whiteName]) {
                    [mDevices addObject:name];
                }
            }
#else
            [mDevices addObject:name];
#endif
         }
        
        _localDevices = [mDevices copy];
    }
    return _localDevices;
}

- (NSArray *)savedDevices {
    if (!_savedDevices) {
        _savedDevices = [[NSArray alloc] initWithArray:[self.storage getSavedDevices]];
    }
    return _savedDevices;
}

- (ActivityViewWithLabel *)activityView {
    if (!_activityView) {
        _activityView = [[ActivityViewWithLabel alloc] init];
    }
    return _activityView;
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (buttonIndex) {
        case 0:
            [self performSegueWithIdentifier:@"AboutSegue" sender:self];
            break;
        case 1:
            [self showHelp];
            break;
        case 3:
            [self performSegueWithIdentifier:@"DebugSegue" sender:self];
            break;
    }
}

- (void)willPresentActionSheet:(UIActionSheet *)actionSheet {
    for (UIView *subview in actionSheet.subviews) {
        if ([subview isKindOfClass:[UIButton class]]) {
            UIButton *button = (UIButton *)subview;
            [button setTitleColor:NABTO_ORANGE forState:UIControlStateNormal];
        }
    }
}

- (void)addVideo:(BOOL)done withDevice:(VideoDevice *)device {
    [self dismissViewControllerAnimated:YES completion:nil];
    
    if (device) {
        [self.navigationController popToRootViewControllerAnimated:YES];
        [self.storage saveDevice:device];
        [self refreshTable];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"AddSegue"]) {
        AddVideoViewController *avvc = [[[segue destinationViewController] viewControllers] objectAtIndex:0];
        avvc.navigationController.modalPresentationStyle = UIModalPresentationPageSheet;
        avvc.addDelegate = self;
        avvc.activeDevice = self.activeDevice;
    }
    else if ([[segue identifier] isEqualToString:@"AddQRSegue"]) {
        AddVideoViewController *avvc = [[[segue destinationViewController] viewControllers] objectAtIndex:0];
        avvc.navigationController.modalPresentationStyle = UIModalPresentationPageSheet;
        avvc.addDelegate = self;
        avvc.goToQR = true;
    }
    else if ([[segue identifier] isEqualToString:@"FrontSegue"]) {
        VideoPageViewController *vpvc = [segue destinationViewController];
        vpvc.goToDevice = self.activeDevice;
    }
}

- (void)applicationHandleOpenURL:(NSNotification *)notification {
    // Make this is the active view
    if (self.navigationController) {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
    
    NSURL *url = [notification object];
    if (!url) {
        return;
    }
    
    VideoDevice *device = [VideoDevice parseURL:url];
    if (device != nil) {
        [self.storage saveDevice:device];
        [self.activityView success:[NSString stringWithFormat:@"added %@", device.title]];
        [self refreshTable];
    }
    else {
        [self.activityView failed:@"invalid device"];
    }
}

- (void)applicationHandleAddDevice:(NSNotification *)notification {
    VideoDevice *device = [notification object];
    self.activeDevice = device;
    
    [self performSegueWithIdentifier:@"AddSegue" sender:nil];
}

- (void)showHelp {
    self.helpOverlay = [[UIView alloc] initWithFrame:self.view.frame];
    self.helpOverlay.layer.backgroundColor = [[UIColor blackColor] CGColor];
    self.helpOverlay.layer.opacity = 0.5f;
    self.helpOverlay.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    self.helpView = [[UIView alloc] initWithFrame:self.view.frame];
    UIImageView *helpImageView = [[UIImageView alloc] init];
    helpImageView.contentMode = UIViewContentModeTopLeft;
    [helpImageView setImage:[UIImage imageNamed:@"HelpOverlay"]];
    [self.helpView addSubview:helpImageView];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    [self.helpView addGestureRecognizer:tap];

    [self.parentViewController.view addSubview:self.helpOverlay];
    [self.parentViewController.view addSubview:self.helpView];
}

- (void)handleTap:(UIGestureRecognizer *)gesture {
    CGRect rect = CGRectMake(0.0, 280.0, 2000.0, 80.0);
    CGPoint p = [gesture locationInView:self.helpView];
    
    if (CGRectContainsPoint(rect, p)) {
        [self dismissHelp];
        [self qrButtonPressed:self];
        
    } else {
        [self dismissHelp];
    }
}

- (void)dismissHelp {
    [self.helpView removeFromSuperview];
    [self.helpOverlay removeFromSuperview];
    self.helpOverlay = nil;
    self.helpOverlay = nil;
}

- (IBAction)addButtonPressed:(id)sender {
    [self performSegueWithIdentifier:@"AddSegue" sender:self];
}

- (IBAction)qrButtonPressed:(id)sender {
    self.activeDevice = nil;
    [self performSegueWithIdentifier:@"AddQRSegue" sender:self];
}

- (IBAction)editButtonPressed:(id)sender {
    if ([self.tableView isEditing]) {
        [self.tableView setEditing:NO animated:YES];
    }
    else {
        [self.tableView setEditing:YES animated:YES];
    }
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationHandleOpenURL:) name:@"ApplicationHandleOpenURL" object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationHandleAddDevice:) name:@"ApplicationHandleAddDevice" object:nil];
    
    self.navigationController.navigationBar.tintColor = NABTO_ORANGE;
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.backgroundColor = [UIColor whiteColor];
    self.refreshControl.tintColor = NABTO_ORANGE;
    [self.refreshControl addTarget:self action:@selector(refreshTable) forControlEvents:UIControlEventValueChanged];
    
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addButtonPressed:)];
    [addButton setTintColor:NABTO_ORANGE];
    UIImage *qrImage = [UIImage imageNamed:@"ScanQR"];
    UIBarButtonItem *qrButton = [[UIBarButtonItem alloc] initWithImage:qrImage style:UIBarButtonItemStylePlain target:self action:@selector(qrButtonPressed:)];
    [qrButton setTintColor:NABTO_ORANGE];
    
    self.navigationItem.leftBarButtonItems = [NSArray arrayWithObjects:addButton, qrButton, nil];
    
    [self.view addSubview:self.activityView];
    
    // Show help overlay first time app launches
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"firstLaunch"]) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"firstLaunch"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [self showHelp];
    }
    else {
        // Start with front view pushed
        VideoPageViewController *vpvc = [self.storyboard instantiateViewControllerWithIdentifier:@"PageViewID"];
        [self.navigationController pushViewController:vpvc animated:NO];
    }
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    self.activityView.center = self.view.center;
    [self.view bringSubviewToFront:self.activityView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBar.barTintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.tintColor = NABTO_ORANGE;
    
    self.activeDevice = nil;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self.activityView stop];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)dealloc {
    [[NabtoClient instance] nabtoCloseSession];
    [[NabtoClient instance] nabtoShutdown];
}

#pragma mark - Table view data source

- (void)refreshTable {
    self.localDevices = NULL;
    self.savedDevices = NULL;
    [self.tableView reloadData];
    [self.refreshControl endRefreshing];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    CGRect frame = tableView.frame;
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
    
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 200, 40)];
    title.font = [UIFont boldSystemFontOfSize:18.0f];
    title.textColor = [UIColor grayColor];
    
    [headerView setBackgroundColor:[UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:0.4]];

    if (section == 0) {
        title.text = @"Local Devices";
        
        if ([self.localDevices count] == 0) {
            headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, 0)];
        }
    }
    else {
        title.text = @"Saved Devices";

        UIButton *editButton = [[UIButton alloc] initWithFrame:CGRectMake(frame.size.width-60, 10, 50, 40)];
        [editButton setTitle:@"edit" forState:UIControlStateNormal];
        [editButton setTitleColor:NABTO_ORANGE forState:UIControlStateNormal];
        [editButton setTitleColor:NABTO_ORANGE_TRANSPARENT forState:UIControlStateHighlighted];
        [editButton addTarget:self action:@selector(editButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        editButton.backgroundColor = [UIColor redColor];
        [editButton setBackgroundColor:[UIColor clearColor]];
        [headerView addSubview:editButton];
    }

    [headerView addSubview:title];
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0 && [self.localDevices count] == 0) {
        return 0;
    }
    return 60;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return [self.localDevices count];
    }
    else if (section == 1) {
        return [self.savedDevices count];
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;
    
    if (indexPath.section == 0) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"LocalCell" forIndexPath:indexPath];
        cell.tintColor = NABTO_ORANGE;
        
        cell.textLabel.text = [self.localDevices objectAtIndex:indexPath.row];
        cell.detailTextLabel.text = @"Unknown";
    }
    else {
        cell = [tableView dequeueReusableCellWithIdentifier:@"DeviceCell" forIndexPath:indexPath];
        cell.tintColor = NABTO_ORANGE;

        VideoDevice *device = [self.savedDevices objectAtIndex:indexPath.row];
        
        UILabel *titleLabel = (UILabel *)[cell viewWithTag:1000];
        titleLabel.text = device.title;
        
        UILabel *detailsLabel = (UILabel *)[cell viewWithTag:1001];
        detailsLabel.text = [VideoDevice typeToString:device.type];
        
        // Use tag to identify button for row
        UIButton *starButton;
        for (int i = TAG_OFFSET; i < TAG_OFFSET + 50; i++) {
            if ([[cell viewWithTag:i] isMemberOfClass:[UIButton class]]) {
                starButton = (UIButton *)[cell viewWithTag:i];
            }
        }
        starButton.tag = indexPath.row + TAG_OFFSET;
        
        [starButton addTarget:self action:@selector(starButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        if (device.star) {
            [starButton setImage:[UIImage imageNamed:@"Star"] forState:UIControlStateNormal];
        }
        else {
            [starButton setImage:[UIImage imageNamed:@"Star-uncheck"] forState:UIControlStateNormal];
        }
        
        cell.accessoryType = UITableViewCellAccessoryDetailButton;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        NSString *name = cell.textLabel.text;
        VideoDevice *device = [[VideoDevice alloc] initWithName:name];
        self.activeDevice = device;
        [self performSegueWithIdentifier:@"AddSegue" sender:nil];
    }
    else {
        VideoDevice *device = [self.savedDevices objectAtIndex:indexPath.row];
        if (!device.star) {
            device.star = true;
            [self.storage saveDevice:device];
            [self.tableView reloadData];
        }
        self.activeDevice = device;
        [self performSegueWithIdentifier:@"FrontSegue" sender:self];
    }
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1) {
        self.activeDevice = [self.savedDevices objectAtIndex:indexPath.row];
        [self performSegueWithIdentifier:@"AddSegue" sender:nil];
    }
}

- (IBAction)starButtonClicked:(id)sender {
    NSInteger row = [sender tag] - TAG_OFFSET;
    VideoDevice *device = [self.savedDevices objectAtIndex:row];
    [device toggleStar];
    [self.storage saveDevice:device];
    [self.tableView reloadData];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section > 0) {
        return YES;
    }
    return NO;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self.storage removeDevice:[self.savedDevices objectAtIndex:indexPath.row]];
        self.savedDevices = NULL;
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

@end
