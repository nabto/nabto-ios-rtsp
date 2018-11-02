//
//  ActivityViewWithLabel.h
//  Nabto
//
//  Created by Martin Rodalgaard on 07/11/14.
//  Copyright (c) 2014 MRodalgaard. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ActivityViewWithLabel : UIView {
    NSTimer *timer;
    bool persistent;
}

@property (nonatomic, retain)UIActivityIndicatorView *activityIndicator;
@property (nonatomic, retain)UIImageView *activityImageView;
@property (nonatomic, retain)UILabel *label;

- (void)start;
- (void)stop;
- (void)text:(NSString *)string;

- (void)failed:(NSString *)string;
- (void)success:(NSString *)string;
- (void)persistentSuccess:(NSString *)string;

- (BOOL)isAnimating;
- (BOOL)isShowing;

@end
