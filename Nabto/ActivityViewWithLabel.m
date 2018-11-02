//
//  ActivityViewWithLabel.m
//  Nabto
//
//  Created by Martin Rodalgaard on 07/11/14.
//  Copyright (c) 2014 MRodalgaard. All rights reserved.
//

#import "ActivityViewWithLabel.h"
#import "NabtoAppCommon.h"

@implementation ActivityViewWithLabel

@synthesize activityIndicator = _activityIndicator, activityImageView = _activityImageView, label = _label;

- (UIActivityIndicatorView *)activityIndicator {
    if (!_activityIndicator) {
        _activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        _activityIndicator.color = NABTO_ORANGE;
        _activityIndicator.frame = CGRectMake(self.center.x - 15, 15, 30, 30);
        _activityIndicator.backgroundColor = [UIColor clearColor];
    }
    return _activityIndicator;
}

- (UILabel *)label {
    if (!_label) {
        _label = [[UILabel alloc] initWithFrame:CGRectMake(0, 45, 240, 25)];
        _label.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _label.font = [UIFont boldSystemFontOfSize:16.0f];
        _label.numberOfLines = 1;
        _label.backgroundColor = [UIColor clearColor];
        _label.textAlignment = NSTextAlignmentCenter;
        _label.textColor = NABTO_ORANGE;
        _label.hidden = YES;
    }
    return _label;
}

- (UIImageView *)activityImageView {
    if (!_activityImageView) {
        _activityImageView = [[UIImageView alloc] initWithFrame:self.activityIndicator.frame];
        _activityImageView.hidden = YES;
        _activityImageView.image = [UIImage imageNamed:@"Error"];
        _activityImageView.contentMode  = UIViewContentModeScaleAspectFill;
    }
    return _activityImageView;
}

- (id)init {
    self = [super init];
    if (self) {
        [self configureView];
    }
    return self;
}

- (void)configureView {
    self.hidden = YES;
    persistent = NO;
    
    [self setFrame:CGRectMake(0, 0, 240, 80)];
    self.backgroundColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:.3];
    [self.layer setCornerRadius:10.0f];
    [self.layer setBorderColor:[UIColor lightGrayColor].CGColor];
    
    [self addSubview:self.activityIndicator];
    [self addSubview:self.activityImageView];
    [self addSubview:self.label];
    [self.activityIndicator startAnimating];
}

- (void)start {
    if (!persistent) {
        self.label.hidden = NO;
        self.activityImageView.hidden = YES;
        self.hidden = NO;
        [self.activityIndicator startAnimating];
    }
}

- (void)timerEvent {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        persistent = NO;
        if (!self.activityIndicator.isAnimating) {
            [UIView transitionWithView:self
                              duration:0.5f
                               options:UIViewAnimationOptionTransitionCrossDissolve
                            animations:^{
                                [self stop];
                            } completion:NULL];
        }
    });
}

- (void)stop {
    self.hidden = YES;
}

- (void)text:(NSString *)string {
    if (!persistent) {
        self.label.text = string;
    }
}

- (void)status:(BOOL)success {
    self.label.hidden = NO;
    self.activityImageView.image = success ? [UIImage imageNamed:@"Check"] : [UIImage imageNamed:@"Error"];
    self.activityImageView.hidden = NO;
    self.hidden = NO;
    
    [timer invalidate];
    [self.activityIndicator stopAnimating];
    timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timerEvent) userInfo:nil repeats:NO];
}

- (void)failed:(NSString *)string {
    self.label.text = string;
    [self status:NO];
}

- (void)success:(NSString *)string {
    if (!persistent) {
        self.label.text = string;
        [self status:YES];
    }
}

- (void)persistentSuccess:(NSString *)string {
    [self success:string];
    persistent = YES;
}

- (BOOL)isAnimating {
    return [self.activityIndicator isAnimating];
}

- (BOOL)isShowing {
    return !self.hidden;
}

@end
