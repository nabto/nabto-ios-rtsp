//
//  AboutViewController.m
//  Nabto
//
//  Created by Martin Rodalgaard on 16/10/14.
//  Copyright (c) 2014 MRodalgaard. All rights reserved.
//

#import "AboutViewController.h"
#import <NabtoClient.h>

@interface AboutViewController ()

@end

@implementation AboutViewController

@synthesize textView;

- (void)viewDidLoad {
    [super viewDidLoad];

    logoImage.image = [UIImage imageNamed:@"NabtoVideoLogo"];
    
    NSString *versionString = [[NabtoClient instance] nabtoVersion];
    [self.textView setText:[NSString stringWithFormat:@"Nabto Client version: %@\n\n%@", versionString, self.textView.text]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
