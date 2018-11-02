//
//  WebViewController.m
//  Nabto
//
//  Created by Martin Rodalgaard on 02/06/14.
//  Copyright (c) 2014 MRodalgaard. All rights reserved.
//

#import "WebViewController.h"
#import "NabtoURLProtocol.h"
#import "NabtoClient/NabtoClient.h"
#import "NabtoAppCommon.h"

@interface WebViewController ()

@end

@implementation WebViewController

@synthesize backButton = _backButton, forwardButton = _forwardButton, moreButton, urlTextField;

- (UIBarButtonItem *)backButton {
    if (!_backButton) {
        _backButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRewind target:self action:@selector(backButtonPressed:)];
        [_backButton setTintColor:NABTO_ORANGE];
    }
    return _backButton;
}

- (UIBarButtonItem *)forwardButton {
    if (!_forwardButton) {
        _forwardButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFastForward target:self action:@selector(forwardButtonPressed:)];
        [_forwardButton setTintColor:NABTO_ORANGE];
    }
    return _forwardButton;
}

- (void)setNavigationBar:(BOOL)expanded {
    NSMutableArray *leftButtons = [[NSMutableArray alloc] init];
    if ([self.webView canGoBack] && !expanded) {
        [leftButtons addObject:self.backButton];
    }
    if ([self.webView canGoForward] && !expanded) {
        [leftButtons addObject:self.forwardButton];
    }
    [self.navigationItem setLeftBarButtonItems:[leftButtons copy] animated:YES];
}

- (NSString *)appendSessionKey:(NSString *)url {
    if (![url rangeOfString:@"session_key="].length == 0) {
        return url;
    }
    
    if ([url rangeOfString:@"?"].location == NSNotFound) {
        return [url stringByAppendingFormat:@"?session_key=%@", [[NabtoClient instance] nabtoGetSessionToken]];
    }
    else {
        return [url stringByAppendingFormat:@"&session_key=%@", [[NabtoClient instance] nabtoGetSessionToken]];
    }
}

- (void)goToUrl:(NSString *)url {
    url = [self appendSessionKey:url];
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]];
}

- (void)goToDashboard {
    NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"index" ofType:@"html" inDirectory:@"nabto-dashboard"]];
    [self.webView loadRequest:[NSURLRequest requestWithURL:url]];
}

- (void)setHomepage {
    [self goToUrl:[NSString stringWithFormat:@"nabto://self/set_home_page?url=%@", self.urlTextField.text]];
}

- (void)applicationHandleOpenURL:(NSNotification *)notification {
	NSURL *url = [notification object];
	if (!url) {
        return;
    }
    
    /*
	NSURLRequest *request = [NSURLRequest requestWithURL:url];
	if (![NabtoURLProtocol canInitWithRequest:request]) {
        return;
    }
    */
	
    [self goToUrl:[url absoluteString]];
}

#pragma mark - Delegates and Events

- (void)backButtonPressed:(id)sender {
    [self.webView goBack];
}

- (void)forwardButtonPressed:(id)sender {
    [self.webView goForward];
}

- (IBAction)moreButtonPressed:(id)sender {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Discovery", @"Set Homepage", @"Add Bookmark", @"Bookmark List", @"Change User", nil];
    [actionSheet showFromBarButtonItem:self.moreButton animated:YES];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (buttonIndex) {
        case 0:
            [self goToUrl:@"nabto://self/"];
            break;
        case 1:
            [self setHomepage];
            break;
    }
}

- (void)willPresentActionSheet:(UIActionSheet *)actionSheet {
    for (UIView *subview in actionSheet.subviews) {
        if ([subview isKindOfClass:[UIButton class]]) {
            UIButton *button = (UIButton *)subview;
            [button setTitleColor:NABTO_ORANGE forState:UIControlStateNormal];
        }
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.urlTextField) {
        NSString *url = self.urlTextField.text;
        [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]];
        [self.urlTextField resignFirstResponder];
    }
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if (textField == self.urlTextField) {
        CGFloat width = self.navigationController.navigationBar.bounds.size.width;
        if (width < 400) {
            [self setNavigationBar:YES];
        }
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if (textField == self.urlTextField) {
        [self setNavigationBar:NO];
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    lastPositionY = scrollView.contentOffset.y;
}

- (void) scrollViewWillBeginDecelerating:(UIScrollView *)scrollView {
    bool hide = (scrollView.contentOffset.y > lastPositionY);
    if (hide) {
        [[self navigationController] setNavigationBarHidden:YES animated:YES];
    }
    else {
        [[self navigationController] setNavigationBarHidden:NO animated:YES];
    }
}

#pragma mark - Web View

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    NSString *urlString = [[request URL] absoluteString];
    
    if ([NabtoURLProtocol dispatchMagicUrlAction:[request URL]]) {
        NSLog(@"Magic URL, don't load");
        return NO;
    }
    
    // Fix potencially broken urls
    if ([urlString rangeOfString:@"////"].location != NSNotFound) {
        urlString = [urlString stringByReplacingOccurrencesOfString:@"////" withString:@"//"];
        [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlString]]];
        return NO;
    }
    
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    [self setNavigationBar:NO];
    self.urlTextField.text = webView.request.URL.absoluteString;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    NSLog(@"WebView loading error: %@, %@", error, [error userInfo]);
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    [self setNavigationBar:NO];
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [NSURLProtocol registerClass:[NabtoURLProtocol class]];

    [self setNavigationBar:NO];
    self.webView.scrollView.delegate = self;
    [self.moreButton setTintColor:NABTO_ORANGE];
    [self.urlTextField setTintColor:NABTO_ORANGE];
    
    self.urlTextField.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    CGRect rect = self.urlTextField.bounds;
    rect.size.width = self.navigationController.navigationBar.bounds.size.width;
    [self.urlTextField setBounds:rect];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationHandleOpenURL:) name:@"ApplicationHandleOpenURL" object:nil];
    
    [NabtoURLProtocol enableWebviewLog];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self goToUrl:@"nabto://self/show_home_page"];
    [self goToDashboard];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
