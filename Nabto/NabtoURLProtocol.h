//
//  NabtoURLProtocol.h
//  Nabto
//
//  Created by Kaspar Rosengreen Nielsen on 04/10/10.
//  Copyright 2010 Alexandra A/S. All rights reserved.
//
//  This class defines the nabto protocol and is invoked whenever the WebKit
//  instance tries to load a request with a nabto URL.
// 
//  The protocol is registered in the NabtoAppDelegate class.

#import <Foundation/Foundation.h>

@interface NabtoURLUtils : NSObject

+ (NSURL *)stripParameters:(NSURL *)url;
+ (NSDictionary *)getParameters:(NSURL *)url;

@end

@interface NabtoURLProtocol : NSURLProtocol {
	NSThread *loadThread;
}

+ (BOOL)dispatchMagicUrlAction:(NSURL*)url;
+ (void)enableWebviewLog;

@property(nonatomic,retain) NSThread *loadThread;

@end
