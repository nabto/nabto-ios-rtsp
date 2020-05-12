//
//  NabtoDevice.h
//  Nabto
//
//  Created by Martin Rodalgaard on 03/06/14.
//  Copyright (c) 2014 MRodalgaard. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NabtoClient/NabtoClient.h"

#define NCATEGORIES 2
#define NTYPES 2

// TOOD: This should eventually be moved to CoreData instead of a simple plist

typedef enum {
    UNKNOWN,
    WEB,
    MPEG
} VideoType;
#define VideoTypeArray @"Unknown", @"Web", @"MPEG", nil

#define VideoTypeArrayHelp @"Device type unknown", @"Uses a web view to show mjpeg feeds or web interface", @"Uses an FFMPEG player to show video streams", nil

#define VD_TITLE     @"title"
#define VD_NAME      @"name"
#define VD_TYPE      @"type"
#define VD_PORT      @"port"
#define VD_URL       @"url"
#define VD_CATEGORY  @"category"
#define VD_STAR      @"star"
#define VD_VERSION   @"version"
#define VD_USER      @"user"
#define VD_UID       @"uid"
#define VD_KEYCHAIN  @"Nabto"

@interface VideoDevice : NSObject

@property (nonatomic, strong)NSString *title;
@property (nonatomic, strong)NSString *name;
@property (nonatomic, strong)NSString *url;
@property (nonatomic)VideoType type;
@property (nonatomic)int port;
@property (nonatomic)int category;
@property (nonatomic)int star;
@property (nonatomic, strong)NSString *user;
@property (nonatomic, strong)NSString *pass;
@property (nonatomic)NabtoTunnelHandle tunnel;
@property (nonatomic, strong)NSNumber *uid;

@property (nonatomic, strong)NSMutableDictionary *dictionary;

- (id)init;
- (id)initWithName:(NSString *)name;
- (id)initWithDictionary:(NSDictionary *)dict;
- (id)initWithTitle:(NSString *)theTitle
               name:(NSString *)theName
               type:(VideoType)theType
               port:(int)thePort
                url:(NSString *)theUrl
           category:(int)theCategory
            starred:(int)theStar
               user:(NSString *)theUser
                uid:(NSNumber *)theUid;
- (BOOL)toggleStar;
- (void)setAuth:(NSString *)user withPass:(NSString *)pass;

+ (VideoDevice *)parseURL:(NSURL *)url;
+ (NSString *)typeToString:(VideoType)type;
+ (VideoType)stringToType:(NSString *)string;

@end
