//
//  WebVideoViewController.m
//  Nabto
//
//  Created by Martin Rodalgaard on 04/06/14.
//  Copyright (c) 2014 MRodalgaard. All rights reserved.
//

#import "WebVideoViewController.h"
#import <NabtoClient.h>

@interface WebVideoViewController ()

@end

@implementation WebVideoViewController

@synthesize webView, url, activityView = _activityView;

- (ActivityViewWithLabel *)activityView {
    if (!_activityView) {
        _activityView = [[ActivityViewWithLabel alloc] init];
    }
    return _activityView;
}

- (void)startLoading {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [self.activityView start];
    [self.activityView text:@"loading..."];
}

- (void)stopLoading {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    [self.activityView stop];
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    [self startLoading];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    NSLog(@"WebView finish");
    [self stopLoading];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    NSLog(@"WebView loading error: %@, %@", error, [error userInfo]);
    [self stopLoading];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    NSLog(@"Should load: %@", [[request URL] absoluteString]);

    (void)[NSURLConnection connectionWithRequest:request delegate:self];
    return YES;
}

- (void)connection:(NSURLConnection *)connection willSendRequestForAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
    NSLog(@"got auth challenge");
    
    if (auth) {
        NSURLCredential * cred = [NSURLCredential credentialWithUser:username
                                                            password:password
                                                         persistence:NSURLCredentialPersistenceForSession];
        [[NSURLCredentialStorage sharedCredentialStorage] setCredential:cred forProtectionSpace:[challenge protectionSpace]];
    }
    else {
        auth = YES;
        prevURL = connection.originalRequest.URL;
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Login" message:@"Authentication needed" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Login", nil];
        alert.alertViewStyle = UIAlertViewStyleLoginAndPasswordInput;
        [alert show];
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSLog(@"connection did fail");
    [self.webView stopLoading];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    NSLog(@"received response via nsurlconnection");
}

- (BOOL)connectionShouldUseCredentialStorage:(NSURLConnection *)connection {
    return YES;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    [alertView removeFromSuperview];
    
    if ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"Login"]) {
        username = [alertView textFieldAtIndex:0].text;
        password = [alertView textFieldAtIndex:1].text;

        [webView stopLoading];
        [webView loadRequest:[NSURLRequest requestWithURL:prevURL]];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    auth = NO;
    
    NSURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:self.url]
                                                    cachePolicy:NSURLRequestReloadIgnoringCacheData
                                                timeoutInterval:12];
    [self.webView loadRequest:request];
    
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    self.activityView.center = self.view.center;
    [self.view bringSubviewToFront:self.activityView];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self.webView stopLoading];
    [self.activityView removeFromSuperview];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
