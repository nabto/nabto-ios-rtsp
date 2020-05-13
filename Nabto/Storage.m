//
//  Storage.m
//  Nabto
//
//  Created by Martin Rodalgaard on 03/06/14.
//  Copyright (c) 2014 MRodalgaard. All rights reserved.
//

#import "Storage.h"
#import "SSKeychain.h"

@implementation Storage

@synthesize plistPath = _plistPath;

- (NSString *)plistPath {
    if (!_plistPath) {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *docPath = [paths objectAtIndex:0];
        _plistPath = [docPath stringByAppendingPathComponent:@"devices.plist"];
    }
    return _plistPath;
}

- (void)saveDevice:(VideoDevice *)device {
    NSArray *devices = [NSArray arrayWithContentsOfFile:self.plistPath];
    if ([devices count] == 0) {
        devices = [[NSArray alloc] init];
    }

    NSMutableArray *newDevices = [[NSMutableArray alloc] init];
    for (NSDictionary *_device in devices) {
        if (![[_device objectForKey:VD_UID] isEqualToNumber:device.uid]) {
            [newDevices addObject:_device];
        }
    }
    
    [newDevices addObject:device.dictionary];
    [newDevices writeToFile:self.plistPath atomically:YES];
}

- (void)removeDevice:(VideoDevice *)device {
    // Remove saved password for device from keychain
    [SSKeychain deletePasswordForService:[device.uid stringValue] account:VD_KEYCHAIN];
    
    NSArray *devices = [NSArray arrayWithContentsOfFile:self.plistPath];
    NSMutableArray *newDevices = [[NSMutableArray alloc] init];
    for (NSDictionary *_device in devices) {
        if (![_device objectForKey:VD_UID]) {
            if (![[_device objectForKey:VD_NAME] isEqualToString:device.name]) {
                [newDevices addObject:_device];
            }
        }
        else if (![[_device objectForKey:VD_UID] isEqualToNumber:device.uid]) {
            [newDevices addObject:_device];
        }
    }
    [newDevices writeToFile:self.plistPath atomically:YES];
}

- (NSArray *)getSavedDevices {
    NSArray *savedDevices = [NSArray arrayWithContentsOfFile:self.plistPath];
    NSMutableArray *devices = [[NSMutableArray alloc] init];
    for (NSDictionary *deviceDict in savedDevices) {
        VideoDevice *device = [[VideoDevice alloc] initWithDictionary:deviceDict];
        
        // Handle old devices added without an uid
        if (![deviceDict objectForKey:VD_UID]) {
            [self removeDevice:device];
            [self saveDevice:device];
        }
        
        [devices addObject:device];
    }
    return devices;
}

- (NSArray *)getStarredDevices {
    NSArray *savedDevices = [NSArray arrayWithContentsOfFile:self.plistPath];
    NSMutableArray *devices = [[NSMutableArray alloc] init];
    for (NSDictionary *device in savedDevices) {
        if ([[device objectForKey:VD_STAR] intValue] == 1) {
            // migrate to new format with host field
            if ([device objectForKey:VD_HOST] != nil) {
                [devices addObject:[[VideoDevice alloc] initWithDictionary:device]];
            } else {
                NSDictionary* copy = [device mutableCopy];
                [copy setValue:@"127.0.0.1" forKey:VD_HOST];
                [devices addObject:[[VideoDevice alloc] initWithDictionary:copy]];
            }
        }
    }
    return devices;
}

- (void) clear {
    NSError *error = nil;
    [[NSFileManager defaultManager] removeItemAtPath:self.plistPath error:&error];
}

@end
