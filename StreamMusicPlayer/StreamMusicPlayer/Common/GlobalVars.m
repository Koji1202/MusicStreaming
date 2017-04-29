//
//  GlobalVars.m
//  StreamMusicPlayer
//
//  Created by Mac Developer001 on 8/8/16.
//  Copyright © 2016 SCN. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "GlobalVars.h"
#import "AFNetworking.h"
#import "UIImageView+AFNetworking.h"

@implementation GlobalVars

static GlobalVars *instance = nil;
//NSString *const SERVER_ADDR = @"http://192.168.1.124/MusicStream";
NSString *const SERVER_ADDR = @"http://35.166.217.110/MusicStream";
NSString *const SERVER_URL_PREFIX = @"/index.php";

+ (GlobalVars *)sharedInstance
{
    @synchronized(self)
    {
        if(instance==nil)
        {
            instance= [GlobalVars new];
        }
    }
    
    return instance;
}

- (UIActivityIndicatorView *)showWaitingDialog:(UIView *)view {
    // create new dialog box view and components
    
    UIActivityIndicatorView *indicatorView = [[UIActivityIndicatorView alloc]
                                              initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    
    indicatorView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin;
    
    indicatorView.center = CGPointMake(view.center.x, view.center.y - 33);
    indicatorView.color = [UIColor colorWithRed:0.5f green:0.5f blue:0.5f alpha:1.0f];
    
    [view addSubview:indicatorView];
    return indicatorView;
}

- (NSString *)getServerUrl {
    return [NSString stringWithFormat:@"%@%@", SERVER_ADDR, SERVER_URL_PREFIX];
}
- (NSString *)getFileUrl:(NSString *)fileUrl {
    if ([fileUrl hasPrefix:@"/"])
        return [SERVER_ADDR stringByAppendingString:fileUrl];
    if ([fileUrl hasPrefix:@"http"])
        return fileUrl;
    return [NSString stringWithFormat:@"%@/%@", SERVER_ADDR,fileUrl];
}
+ (NSString *)getTmpFilePath:(NSString *)fileName {
    NSString * _tempPath = NSTemporaryDirectory();
    NSString *filePath = [_tempPath stringByAppendingPathComponent:fileName];
    return filePath;
}

// Show Alert

NSString *const NETWORK_ERR = @"Network Connection Fail!";
+ (UIAlertController *) networkErrAlert {
    return [self commonAlert:NETWORK_ERR message:@""];
}

+ (UIAlertController *) commonAlert: (NSString *)title message:(NSString *)message {
    NSString *msg = @"";
    if([message isEqualToString:@""])
        msg = title;
    else
        msg = message;
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:msg message:nil preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action)
                         {
                             [alertController dismissViewControllerAnimated:YES completion:nil];
                         }];
    [alertController addAction:ok];
    return alertController;
}

- (NSData *)getSubData:(NSData *)source withRange:(NSRange)range
{
    UInt8 bytes[range.length];
    [source getBytes:&bytes range:range];
    NSData *result = [[NSData alloc] initWithBytes:bytes length:sizeof(bytes)];
    return result;
}

- (id) getJsonData: (NSData *) responseObject{
    NSString *command = @"EF BB BF";
    command = [command stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSMutableData *commandToSend= [[NSMutableData alloc] init];
    unsigned char whole_byte;
    char byte_chars[3] = {'\0','\0','\0'};
    for (int i = 0; i < ([command length] / 2); i++) {
        byte_chars[0] = [command characterAtIndex:i*2];
        byte_chars[1] = [command characterAtIndex:i*2+1];
        whole_byte = strtol(byte_chars, NULL, 16);
        [commandToSend appendBytes:&whole_byte length:1];
    }
    
    NSData *bomMarker = [self getSubData:responseObject withRange:NSMakeRange(1, 3)];
    NSMutableData *result_data = [responseObject mutableCopy];
    while (YES) {
        bomMarker = [self getSubData:result_data withRange:NSMakeRange(1, 3)];
        if(![bomMarker isEqualToData: commandToSend])
            break;
        [result_data replaceBytesInRange:NSMakeRange(1, 3) withBytes:NULL length:0];
    }
    id result = [NSJSONSerialization
                 JSONObjectWithData:result_data
                 options:NSJSONReadingAllowFragments
                 error:nil];
    if(result == nil) {
        result = [[NSMutableDictionary alloc] init];
        [result setObject:[NSNumber numberWithBool:NO] forKey:@"result_code"];
    }
    NSMutableDictionary *temp = result[@"result_data"];
    
    if(temp != nil) {
        if([temp isKindOfClass:[NSMutableArray class]] || [temp isKindOfClass:[NSMutableDictionary class]]) {
            if([result[@"result_data"] count] == 0) {
                result = [[NSMutableDictionary alloc] init];
                [result setObject:[NSNumber numberWithBool:NO] forKey:@"result_code"];
            }
        }
    } else {
        result = [[NSMutableDictionary alloc] init];
        [result setObject:[NSNumber numberWithBool:NO] forKey:@"result_code"];
    }
    return result;
}

+ (void)loadImageFromUrl:(UIImageView *)imageView FileName:(NSString *)fileName defaultImage:(UIImage *)defaultImg {
    if ([fileName isEqual:[NSNull null]] || fileName == nil || [fileName isEqualToString:@""]) {
        [imageView setImage:defaultImg];
        return;
    }
    
    NSString *url = [[GlobalVars sharedInstance] getFileUrl:fileName];
    //    NSURLRequest * request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]
                                             cachePolicy:NSURLRequestReturnCacheDataElseLoad
                                         timeoutInterval:60];
    
    
    [imageView setImageWithURLRequest:request
                     placeholderImage:defaultImg
                              success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                  [imageView setImage:image];
                              } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                  //NSLog(@"failure: %@", response);
                              }];
    
    
}


@end
