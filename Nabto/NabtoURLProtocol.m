//
//  NabtoURLProtocol.m
//  Nabto
//
//  Created by Kaspar Rosengreen Nielsen on 04/10/10.
//  Copyright 2010 Alexandra A/S. All rights reserved.
//

#import "NabtoURLProtocol.h"
#import <NabtoClient.h>

@implementation NabtoURLUtils

+ (BOOL)isKnownNabtoPrefix:(NSString *)scheme {
    return [scheme isEqualToString:@"nabto"];
}

+ (NSURL *)stripParameters:(NSURL *)url {
    // Do not add another slash if path already starts with it
    if ([url.path rangeOfString:@"/"].location == 0) {
        return [NSURL URLWithString:[NSString stringWithFormat:@"%@://%@%@", url.scheme, url.host, url.path]];
    }
    return [NSURL URLWithString:[NSString stringWithFormat:@"%@://%@/%@", url.scheme, url.host, url.path]];
}

+ (NSDictionary *)getParameters:(NSURL *)url {
    if (![url isKindOfClass:[NSURL class]]) {
        return nil;
    }
    
    NSScanner *scanner = [NSScanner scannerWithString:[url absoluteString]];
    [scanner setCharactersToBeSkipped:[NSCharacterSet characterSetWithCharactersInString:@"&?"]];
    NSString *tempString;
    NSMutableDictionary *dict = [NSMutableDictionary new];
    [scanner scanUpToString:@"?" intoString:nil];
    while ([scanner scanUpToString:@"&" intoString:&tempString]) {
        NSArray *arr = [tempString componentsSeparatedByString:@"="];
        if ([arr count] > 1) {
            NSString *encodedParameter = [arr objectAtIndex:0];
            NSString *encodedValue = [arr objectAtIndex:1];
            NSString *decodedValue = (__bridge_transfer NSString *)CFURLCreateStringByReplacingPercentEscapesUsingEncoding(NULL, (CFStringRef)encodedValue, CFSTR(""), kCFStringEncodingUTF8);
            [dict setObject:decodedValue forKey:encodedParameter];
        }
    }
    return dict;
}

@end

@implementation NabtoURLProtocol

@synthesize loadThread;

+ (BOOL)canInitWithRequest:(NSURLRequest *)request {
    if ([[[request URL] host] isEqualToString:@"debug"]) {
        NSLog(@"Webview Debug: %@", [[[request URL] path] substringFromIndex: 1]);
    }
    return [NabtoURLUtils isKnownNabtoPrefix:[[request URL] scheme]];
}

+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request {
    return request;
}

- (void)startLoading {
	// Perform load in seperate thread
	self.loadThread = [[NSThread alloc] initWithTarget:self selector:@selector(loadResourceThreadedMethod) object:nil];
	[loadThread start];
}

/** Called by URL loading system in response to normal finish, error or abort. Cleans up in each case. */
- (void)stopLoading {
	// TODO: needs cleanup
	NSLog(@"Stop loading...");
}

+ (BOOL)dispatchMagicUrlAction:(NSURL *)nsurl {
    NSString *event = NULL;
    NSString *url = [nsurl absoluteString];
    
    if ([url rangeOfString:@"://self/login/form"].location != NSNotFound ||
        [url rangeOfString:@"://self/show_login"].location != NSNotFound ||
        [url rangeOfString:@"://self/logout"].location != NSNotFound) {
        event = @"handleShowLogin";
    }
    else if ([url rangeOfString:@"://self/send_mail"].location != NSNotFound) {
        event = @"handleSendMail";
    }
    else if ([url rangeOfString:@"://self/open_tunnel"].location != NSNotFound) {
        event = @"handleOpenTunnel";
    }
    else {
        return NO;
    }
    
    NSLog(@"Handling magic url: %@", url);
    NSNotification *notification = [NSNotification notificationWithName:event object:nsurl];
    [[NSNotificationCenter defaultCenter] performSelectorOnMainThread:@selector(postNotification:) withObject:notification waitUntilDone:NO];
    return YES;
}

- (BOOL)handleMagicUrls {
    if ([NabtoURLProtocol dispatchMagicUrlAction:[self.request URL]]) {
        [self.client URLProtocolDidFinishLoading:self];
        return YES;
    }
    else {
        return NO;
    }
}

+ (void)enableWebviewLog {
    [NSURLProtocol registerClass:[NabtoURLProtocol class]];
}

#pragma mark Thread methods
- (void)loadResourceThreadedMethod {
    NSLog(@"Loading %@", [self.request URL]);
    
    nabto_status_t status;
    char* resultBuffer = 0;
    size_t resultLen = 0;
    char* resultMimeType = 0;
    
    NSString *urlString = [[self.request URL] absoluteString];
    
    // Stop if handling a magic url
    if ([self handleMagicUrls]) {
        return;
    }
    
    if ([[self.request HTTPMethod] isEqualToString:@"POST"]) {
        NSString *postData = [[NSString alloc] initWithData:[self.request HTTPBody] encoding:NSASCIIStringEncoding];
        
        status = [[NabtoClient instance] nabtoSubmitPostData:urlString withBuffer:postData resultBuffer:&resultBuffer resultLength:&resultLen mimeType:&resultMimeType];
    }
    else {
        status = [[NabtoClient instance] nabtoFetchUrl:urlString withResultBuffer:&resultBuffer resultLength:&resultLen mimeType:&resultMimeType];
    }

    if (status == NABTO_OK) {
        NSData *data = nil;
        NSString *textEncodingName = NULL;
        NSString *mimeType = NULL;
        if (resultMimeType) {
            NSString *contentType = [[NSString alloc] initWithUTF8String:resultMimeType];
            NSLog(@"Contenttype: %@", contentType);
            data = [NSData dataWithBytes:resultBuffer length:resultLen];
            NSRange delimiter = [contentType rangeOfString:@";"];					
            if (delimiter.location != NSNotFound) {
                mimeType = [contentType substringToIndex:delimiter.location];
                NSString *secondPart = [contentType substringFromIndex:delimiter.location + 1];
                NSRange charsetRange = [secondPart rangeOfString:@"charset=" 
                                                options:(NSCaseInsensitiveSearch | NSBackwardsSearch)];
                if (charsetRange.location != NSNotFound) {
                    textEncodingName = [[[secondPart substringFromIndex:charsetRange.location + charsetRange.length] 
                                            lowercaseString] 
                                                stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                }
            }
            else {
                mimeType = contentType;
            }
            NSURLResponse *theResponse = [[NSURLResponse alloc] initWithURL:[self.request URL] MIMEType:mimeType expectedContentLength:resultLen textEncodingName:textEncodingName];
            [self.client URLProtocol:self didReceiveResponse:theResponse cacheStoragePolicy:NSURLCacheStorageNotAllowed];
        } else {
            assert(resultBuffer && "nabtoFetchUrl returned ok, but result was null");
            NSLog(@"Content: %@", [[NSString alloc] initWithUTF8String:resultBuffer]);
            data = [[[NSString alloc] initWithUTF8String:resultBuffer] dataUsingEncoding:NSUTF8StringEncoding];
        }
        if (data) {
            [self.client URLProtocol:self didLoadData:data];
        }
        
        [[NabtoClient instance] nabtoFree:resultBuffer];
        [[NabtoClient instance] nabtoFree:resultMimeType];
    }
    else {
        NSError *err = [NSError errorWithDomain:NSURLErrorDomain
                                           code:NSURLErrorUnknown 
                                       userInfo:[NSDictionary dictionaryWithObjectsAndKeys:self.request.URL, NSURLErrorKey,nil]];
        [self.client URLProtocol:self didFailWithError:err];
    }
    [self.client URLProtocolDidFinishLoading:self];
}

#pragma mark NSURLConnection delegate methods
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    NSLog(@"NabtoURLProtocol::didReceiveResponse");
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    NSLog(@"NabtoURLProtocol::didReceiveData");
	[self.client URLProtocol:self didLoadData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    NSLog(@"NabtoURLProtocol::connectionDidFinishLoading");
	[self.client URLProtocolDidFinishLoading:self];
}

- (void)dealloc {
}

@end
