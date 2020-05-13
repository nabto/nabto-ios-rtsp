//
//  AddVideoViewController.h
//  Nabto
//
//  Created by Martin Rodalgaard on 03/06/14.
//  Copyright (c) 2014 MRodalgaard. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VideoDevice.h"
#import "QRViewController.h"

@protocol AddVideoViewDelegate <NSObject>
- (void)addVideo:(BOOL)done withDevice:(VideoDevice *)device;
@end

@interface AddVideoViewController : UITableViewController <UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate> {
    BOOL pickerIsShowing;
}

@property (nonatomic, assign)id<AddVideoViewDelegate>addDelegate;

@property (nonatomic, strong)IBOutlet UIPickerView *typePicker;
@property (nonatomic, retain)NSArray *typeArray;

@property (nonatomic, strong)IBOutlet UILabel *typeLabel;
@property (nonatomic, strong)IBOutlet UITextField *titleField;
@property (nonatomic, strong)IBOutlet UITextField *nameField;
@property (nonatomic, strong)IBOutlet UITextField *hostField;
@property (nonatomic, strong)IBOutlet UITextField *portField;
@property (nonatomic, strong)IBOutlet UITextField *urlField;

@property (nonatomic, strong)VideoDevice *activeDevice;
@property (nonatomic, assign)BOOL goToQR;

- (IBAction)cancelButtonPressed:(id)sender;
- (IBAction)doneButtonPressed:(id)sender;

@end
