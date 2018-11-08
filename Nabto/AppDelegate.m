//
//  AppDelegate.m
//  Nabto
//
//  Created by Martin Rodalgaard on 02/06/14.
//  Copyright (c) 2014 MRodalgaard. All rights reserved.
//

#import "AppDelegate.h"
#import "NabtoURLProtocol.h"
#import "NabtoClient/NabtoClient.h"
#import "Storage.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application willFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    NSLog(@"AD::willFinishLaunchingWithOptions");
    return YES;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    NSLog(@"AD::didFinishLaunchingWithOptions");
    if ([[[NSProcessInfo processInfo] arguments] containsObject:@"clean"]) {
        // for UI test
        Storage *storage = [[Storage alloc] init];
        [storage clear];
    }
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application {
    NSLog(@"AD::applicationWillResignActive");
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    NSLog(@"AD::applicationDidEnterBackground");
    [[NabtoClient instance] nabtoShutdown];

    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    NSLog(@"AD::applicationWillEnterForeground");
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    NSLog(@"AD::applicationDidBecomeActive");
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    NSLog(@"AD::applicationWillTerminate");
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    NSLog(@"handleOpenURL invoked for url '%@'", [url absoluteString]);
    if (url) {
        // Delay needed because the view controller is not loaded yet (Application does not run in background = YES)
        // XXX: more robust approach needed, synchronize somehow
        dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC);
        dispatch_after(time, dispatch_get_main_queue(), ^() {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"ApplicationHandleOpenURL" object:url];
        });
        return YES;
    }
    return NO;
}

@end
