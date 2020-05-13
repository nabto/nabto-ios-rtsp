//
//  AddVideoViewController.m
//  Nabto
//
//  Created by Martin Rodalgaard on 03/06/14.
//  Copyright (c) 2014 MRodalgaard. All rights reserved.
//

#import "AddVideoViewController.h"
#import "NabtoAppCommon.h"

#define CELL_HEIGHT 164

@interface AddVideoViewController ()

@end

@implementation AddVideoViewController

@synthesize titleField, nameField, hostField, typeLabel, portField, urlField, typePicker, activeDevice, typeArray = _typeArray, goToQR;

@synthesize addDelegate;

- (NSArray *)typeArray {
    if (!_typeArray) {
        NSMutableArray *mtypeArray = [NSMutableArray arrayWithObjects:VideoTypeArray];
        [mtypeArray removeObjectAtIndex:0];
        _typeArray = mtypeArray;
    }
    return _typeArray;
}

- (void)cancel {
    [self.addDelegate addVideo:NO withDevice:nil];
}

- (void)save {
    VideoDevice *device = [[VideoDevice alloc] initWithTitle:self.titleField.text
                                                        name:self.nameField.text
                                                        host:self.hostField.text
                                                        type:[VideoDevice stringToType:self.typeLabel.text]
                                                        port:[self.portField.text intValue]
                                                         url:self.urlField.text
                                                    category:-1
                                                     starred:self.activeDevice.star
                                                        user:@""
                                                         uid:self.activeDevice.uid];
    
    [self.addDelegate addVideo:YES withDevice:device];
}

- (void)selectRow:(NSInteger)row {
    self.typeLabel.text = [self.typeArray objectAtIndex:row];
    [self.typePicker selectRow:row inComponent:0 animated:NO];
    [self.tableView reloadData];
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return [self.typeArray count];
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return [self.typeArray objectAtIndex:row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    [self selectRow:row];
}

- (void)showTypePicker {
    pickerIsShowing = YES;
    
    [self.titleField resignFirstResponder];
    [self.nameField resignFirstResponder];
    [self.portField resignFirstResponder];
    [self.urlField resignFirstResponder];
    
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
}

- (void)hideTypePicker {
    pickerIsShowing = NO;
    
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat height = self.tableView.rowHeight;
    if (indexPath.section == 0 && indexPath.row == 1) {
        height = pickerIsShowing ? CELL_HEIGHT : 0.0f;
    }
    return height;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0 && indexPath.row == 0) {
        if (pickerIsShowing) {
            [self hideTypePicker];
        }
        else {
            [self showTypePicker];
        }
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    if (section == 0) {
        NSArray *helpArray = [NSArray arrayWithObjects:VideoTypeArrayHelp];
        return [helpArray objectAtIndex:[self.typePicker selectedRowInComponent:0] + 1];
    }
    return @"";
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([indexPath section] == 2) {
        [cell setBackgroundColor:NABTO_ORANGE];
    }
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    if (pickerIsShowing) {
        [self hideTypePicker];
    }
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.titleField) {
        [self.nameField becomeFirstResponder];
    }
    else if (textField == self.nameField) {
        [self.portField becomeFirstResponder];
    }
    else if (textField == self.portField) {
        [self.urlField becomeFirstResponder];
    }
    else if (textField == self.urlField) {
        [self.urlField resignFirstResponder];
        [self save];
    }
    return YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (self.goToQR) {
        self.goToQR = false;
        [self performSegueWithIdentifier:@"QRSegue" sender:self];
    }
    else if (self.activeDevice) {
        [self populateFields:self.activeDevice];
    }
    else {
        [self selectRow:1];
    }
}

- (void)populateFields:(VideoDevice *)device {
    self.typeLabel.text = [VideoDevice typeToString:device.type];
    if (![device.title isEqualToString:device.name]) {
        self.titleField.text = device.title;
    }
    self.nameField.text = device.name;
    self.hostField.text = device.host;
    self.portField.text = [NSString stringWithFormat:@"%d", device.port];
    self.urlField.text = device.url;
    [self selectRow:device.type - 1];
}

- (IBAction)cancelButtonPressed:(id)sender {
    [self cancel];
}

- (IBAction)doneButtonPressed:(id)sender {
    [self save];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
