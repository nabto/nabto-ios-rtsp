//
//  WebViewController.h
//  Nabto
//
//  Created by Martin Rodalgaard on 02/06/14.
//  Copyright (c) 2014 MRodalgaard. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WebViewController : UIViewController <UITextFieldDelegate, UIWebViewDelegate, UIActionSheetDelegate, UIScrollViewDelegate> {
    CGFloat lastPositionY;
    UINavigationBar *smallNavBar;
    
    NSTimer *statusTimer;
}

@property (nonatomic, strong)UIBarButtonItem *backButton;
@property (nonatomic, strong)UIBarButtonItem *forwardButton;
@property (nonatomic, strong)IBOutlet UIBarButtonItem *moreButton;
@property (nonatomic, strong)IBOutlet UITextField *urlTextField;

@property (nonatomic, strong)IBOutlet UIWebView *webView;

- (IBAction)moreButtonPressed:(id)sender;

@end
