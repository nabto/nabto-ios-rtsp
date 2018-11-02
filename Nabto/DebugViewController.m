//
//  DebugViewController.m
//  Nabto
//
//  Created by Martin Rodalgaard on 15/10/14.
//  Copyright (c) 2014 MRodalgaard. All rights reserved.
//

#import "DebugViewController.h"
#import <NabtoClient.h>

@interface DebugViewController ()

@end

@implementation DebugViewController

@synthesize textView;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.textView.text = [NSString stringWithFormat:@"Nabto version: %@", [[NabtoClient instance] nabtoVersion]];
}

@end
