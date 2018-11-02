//
//  WebVideoViewController.h
//  Nabto
//
//  Created by Martin Rodalgaard on 04/06/14.
//  Copyright (c) 2014 MRodalgaard. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ActivityViewWithLabel.h"

@interface WebVideoViewController : UIViewController <UIWebViewDelegate, NSURLConnectionDelegate, UIAlertViewDelegate> {
    NSURL *prevURL;
    NSString *username;
    NSString *password;
    BOOL auth;
}

@property (nonatomic, strong)IBOutlet UIWebView *webView;
@property (nonatomic, strong)NSString *url;

@property (nonatomic, retain)ActivityViewWithLabel *activityView;

@end
