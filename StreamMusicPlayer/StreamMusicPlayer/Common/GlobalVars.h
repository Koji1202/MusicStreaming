//
//  GlobalVars.h
//  StreamMusicPlayer
//
//  Created by Mac Developer001 on 8/8/16.
//  Copyright © 2016 SCN. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>

#define BROWSE_BY_SEARCH 10
#define BROWSE_BY_ARTIST 0
#define BROWSE_BY_ALBUM 1
#define BROWSE_BY_SONG 2
#define BROWSE_BY_GENRES 3
#define BROWSE_BY_COMPOSER 4
#define BROWSE_BY_COMPILATION 5
#define BROWSE_BY_PLAYLIST 6

#define ERR_OK 0
#define ERR_DATABASE 1
#define ERR_INPUT 2
#define ERR_UNKOWN 3

@interface GlobalVars : NSObject

@property (nonatomic, strong) NSString *sessionId;
@property (nonatomic, strong) NSString *userId;
@property (nonatomic, strong) NSString *email;
@property (nonatomic, strong) NSString *password;
@property (nonatomic, strong) NSString *facebookId;

@property (nonatomic, assign) float latitude;
@property (nonatomic, assign) float longitude;
@property (nonatomic, strong) NSDictionary *posArea;

@property (nonatomic, assign) Boolean isPlaying;

@property (nonatomic, strong) AVPlayer *songPlayer;
@property (nonatomic, strong) AVPlayerItem *playerItem;

@property (nonatomic, strong) NSMutableArray *songList;
@property (nonatomic, assign) NSInteger uploadState;

+ (GlobalVars*)sharedInstance;
- (NSString *)getServerUrl;
- (NSString *)getFileUrl:(NSString *)fileUrl;
+ (NSString *)getTmpFilePath:(NSString *)fileName;
- (UIActivityIndicatorView *)showWaitingDialog:(UIView *)view;

+ (UIAlertController *) networkErrAlert;
+ (UIAlertController *) commonAlert: (NSString *)title message:(NSString *)message;

- (id) getJsonData: (NSData *) responseObject;
+ (void)loadImageFromUrl:(UIImageView *)imageView FileName:(NSString *)fileName defaultImage:(UIImage *)defaultImg;

@end