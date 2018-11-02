//
//  QRViewController.h
//  Nabto
//
//  Created by Martin Rodalgaard on 16/10/14.
//  Copyright (c) 2014 MRodalgaard. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "Storage.h"

@interface QRViewController : UIViewController <AVCaptureMetadataOutputObjectsDelegate>

@property (weak, nonatomic) IBOutlet UIView *viewPreview;
@property (weak, nonatomic) IBOutlet UIView *scanRectView;

- (IBAction)cancel:(id)sender;

@end
