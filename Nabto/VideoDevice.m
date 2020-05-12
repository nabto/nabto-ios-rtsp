//
//  NabtoDevice.m
//  Nabto
//
//  Created by Martin Rodalgaard on 03/06/14.
//  Copyright (c) 2014 MRodalgaard. All rights reserved.
//

#import "VideoDevice.h"
#import "NabtoURLProtocol.h"
#import "SSKeychain.h"

@implementation VideoDevice

@synthesize title = _title, name = _name, url =_url, type = _type, port = _port, category = _category, star = _star, user = _user, pass = _pass, tunnel = _tunnel;
@synthesize dictionary = _dictionary;

- (NSMutableDictionary *)dictionary {
    if (!_dictionary) {
        _dictionary = [[NSMutableDictionary alloc] init];
    }
    return _dictionary;
}

- (NSString *)title {
    if ([self.dictionary objectForKey:VD_TITLE]) {
        return [self.dictionary objectForKey:VD_TITLE];
    }
    return [self.dictionary objectForKey:VD_NAME];
}

- (void)setTitle:(NSString *)title {
    [self.dictionary setValue:title forKey:VD_TITLE];
}

- (NSString *)name {
    return [self.dictionary objectForKey:VD_NAME];
}

- (void)setName:(NSString *)name {
    [self.dictionary setValue:name forKey:VD_NAME];
}

- (VideoType)type {
    return [[self.dictionary objectForKey:VD_TYPE] intValue];
}

- (void)setType:(VideoType)type {
    [self.dictionary setValue:[[NSNumber alloc] initWithInt:type] forKey:VD_TYPE];
}

- (int)port {
    return [[self.dictionary objectForKey:VD_PORT] intValue];
}

- (void)setPort:(int)port {
    [self.dictionary setValue:[[NSNumber alloc] initWithInt:port] forKey:VD_PORT];
}

- (NSString *)url {
    return [self.dictionary objectForKey:VD_URL];
}

- (void)setUrl:(NSString *)url {
    [self.dictionary setValue:url forKey:VD_URL];
}

- (int)category {
    if ([self.dictionary objectForKey:VD_CATEGORY]) {
        return [[self.dictionary objectForKey:VD_CATEGORY] intValue];
    }
    return 0;
}

- (void)setCategory:(int)category {
    [self.dictionary setValue:[[NSNumber alloc] initWithInt:category] forKey:VD_CATEGORY];
}

- (int)star {
    if ([self.dictionary objectForKey:VD_STAR]) {
        return [[self.dictionary objectForKey:VD_STAR] intValue];
    }
    return 0;
}

- (void)setStar:(int)star {
    [self.dictionary setValue:[[NSNumber alloc] initWithInt:star] forKey:VD_STAR];
}

- (NSString *)user {
    if ([self.dictionary objectForKey:VD_USER]) {
        return [self.dictionary objectForKey:VD_USER];
    }
    return @"";
}

- (void)setUser:(NSString *)user {
    [self.dictionary setValue:user forKey:VD_USER];
}

- (NSString *)pass {
    NSString *key = [SSKeychain passwordForService:[self.uid stringValue] account:VD_KEYCHAIN];
    if (key) {
        return key;
    }
    return @"";
}

- (void)setPass:(NSString *)pass {
    if (pass && ![pass isEqualToString:@""]) {
        [SSKeychain setPassword:pass forService:[self.uid stringValue] account:VD_KEYCHAIN];
    }
}

- (NSNumber *)uid {
    if ([self.dictionary objectForKey:VD_UID]) {
        return [self.dictionary objectForKey:VD_UID];
    }
    return 0;
}

- (void)setUid:(NSNumber *)uid {
    [self.dictionary setValue:uid forKey:VD_UID];
}

- (NabtoTunnelHandle)tunnel {
    if (!_tunnel) {
        return nil;
    }
    return _tunnel;
}

- (void)setTunnel:(NabtoTunnelHandle)tunnel {
    _tunnel = tunnel;
}

- (id)init {
    // init with default values
    return [self initWithTitle:nil name:nil type:-1 port:-1 url:nil category:-1 starred:0 user:nil uid:0];
}

- (id)initWithName:(NSString *)name {
    return [self initWithTitle:nil name:name type:-1 port:-1 url:nil category:-1 starred:0 user:nil uid:0];
}

- (id)initWithDictionary:(NSDictionary *)dict {
    return [self initWithTitle:[dict objectForKey:VD_TITLE]
                          name:[dict objectForKey:VD_NAME]
                          type:[[dict objectForKey:VD_TYPE] intValue]
                          port:[[dict objectForKey:VD_PORT] intValue]
                           url:[dict objectForKey:VD_URL]
                      category:[[dict objectForKey:VD_CATEGORY] intValue]
                       starred:[[dict objectForKey:VD_STAR] intValue]
                          user:[dict objectForKey:VD_USER]
                           uid:[dict objectForKey:VD_UID]];
}

- (id)initWithTitle:(NSString *)theTitle
               name:(NSString *)theName
               type:(VideoType)theType
               port:(int)thePort
                url:(NSString *)theUrl
           category:(int)theCategory
            starred:(int)theStar
               user:(NSString *)theUser
                uid:(NSNumber *)theUid {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    if (!theTitle || [theTitle isEqualToString:@""]) { theTitle = theName; }
    self.title = theTitle;
    
    if (!theName || [theName rangeOfString:@"."].location == NSNotFound) { return nil; }
    self.name = theName;
    
    if (!theType || theType < 1 || theType > NTYPES) { theType = MPEG; }
    self.type = theType;
    
    if (!thePort || thePort < 1) { thePort = 554; }
    self.port = thePort;
    
    if (!theUrl || [theUrl isEqualToString:@""]) { theUrl = @"/"; }
    self.url = theUrl;
    
    if (!theCategory || theCategory < 0 || theCategory > NCATEGORIES) { theCategory = 0; }
    self.category = theCategory;
    
    self.star = theStar ? 1 : 0;
    
    if (!theUser) { theUser = @""; }
    self.user = theUser;
    
    if (!theUid || theUid == 0) { theUid = [self createUid]; }
    self.uid = theUid;
    
    return self;
}

- (BOOL)toggleStar {
    self.star = self.star ? 0 : 1;
    return self.star;
}

- (void)setAuth:(NSString *)user withPass:(NSString *)pass {
    self.user = user;
    self.pass = pass;
}

- (NSNumber *)createUid {
    return [NSNumber numberWithInteger:[NSDate timeIntervalSinceReferenceDate]];
}

+ (VideoDevice *)parseURL:(NSURL *)url {
    if (![[url scheme] isEqualToString:@"nabtovideo"]) {
        return nil;
    }
    
    NSDictionary *queries = [NabtoURLUtils getParameters:url];
    if (queries == nil) {
        return nil;
    }
    
    if ([[queries objectForKey:VD_VERSION] isEqualToString:@"1"]) {
        return [[VideoDevice alloc] initWithDictionary:queries];
    }
    return nil;
}

+ (NSString *)typeToString:(VideoType)type {
    NSArray *videoTypeArray = [[NSArray alloc] initWithObjects:VideoTypeArray];
    if ([videoTypeArray count] <= type) {
        type = WEB;
    }
    return [videoTypeArray objectAtIndex:type];
}

+ (VideoType)stringToType:(NSString *)string {
    NSArray *videoTypeArray = [[NSArray alloc] initWithObjects:VideoTypeArray];
    return (VideoType)[videoTypeArray indexOfObject:string];
}

@end
