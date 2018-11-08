//
//  Storage.h
//  Nabto
//
//  Created by Martin Rodalgaard on 03/06/14.
//  Copyright (c) 2014 MRodalgaard. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VideoDevice.h"

// TOOD: This should eventually be moved to CoreData instead of a simple plist

@interface Storage : NSObject

@property (nonatomic)NSString *plistPath;

- (void)saveDevice:(VideoDevice *)device;
- (void)removeDevice:(VideoDevice *)device;
- (NSArray *)getSavedDevices;
- (NSArray *)getStarredDevices;
- (void)clear;

@end
