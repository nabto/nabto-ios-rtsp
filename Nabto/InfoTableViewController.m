//
//  InfoTableViewController.m
//  Nabto
//
//  Created by Martin Rodalgaard on 10/12/15.
//  Copyright © 2015 MRodalgaard. All rights reserved.
//

#import "InfoTableViewController.h"

@interface InfoTableViewController ()

@end

@implementation InfoTableViewController

@synthesize info;

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [info count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"InfoCell" forIndexPath:indexPath];
    
    NSArray *keys = [self.info allKeys];
    NSString *aKey = [keys objectAtIndex:indexPath.row];
    NSString *anObject = [self.info objectForKey:aKey];
    
    cell.textLabel.text = aKey;
    cell.detailTextLabel.text = anObject;
    
    return cell;
}

@end
