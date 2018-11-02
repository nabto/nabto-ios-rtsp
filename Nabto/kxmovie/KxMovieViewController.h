//
//  A rewrite of Kolyvan's now deprecated KxMovieViewController
//  that runs as an isolated video player view using FFmpeg.
//
//  https://github.com/kolyvan/kxmovie
//  this file is part of KxMovie
//  KxMovie is licenced under the LGPL v3, see lgpl-3.0.txt
//
//
//  Nabto ApS extended functionality added as VideoDelegate callbacks
//  and reconnect handling.
//  Also TCP is set as default transport option instead of UDP.
//

#import <UIKit/UIKit.h>

@protocol VideoDelegate <NSObject>
- (void)videoMessage:(BOOL)start withMessage:(NSString *)message;
- (void)videoFailed:(NSString *)message;
- (void)videoReconnect;
@end

@class KxMovieDecoder;

extern NSString * const KxMovieParameterMinBufferedDuration;    // Float
extern NSString * const KxMovieParameterMaxBufferedDuration;    // Float
extern NSString * const KxMovieParameterDisableDeinterlacing;   // BOOL

@interface KxMovieViewController : UIViewController

+ (id) movieViewControllerWithContentPath: (NSString *) path
                               parameters: (NSDictionary *) parameters;

@property (nonatomic, assign)id<VideoDelegate>videoDelegate;

@property (readonly) BOOL playing;

- (void) play;
- (void) playFromNow;
- (void) pause;
- (BOOL) hasValidDecoder;

@end
