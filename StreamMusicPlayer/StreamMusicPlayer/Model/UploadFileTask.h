//
//  UploadFileTask.h
//  GRL
//
//  Created by Mac Developer001 on 3/25/16.
//  Copyright © 2016 Wangu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"

@interface UploadFileTask : NSObject
{
    void (^_completionHandler)(int code, NSDictionary *data);
    void (^_progressHandler)(CGFloat progress);
}

- (void)sendRequest:(NSData *)data MimeType:(NSString *)mimeType FileName:(NSString *)fileName Response:(void(^)(int, NSDictionary *))response Progress:(void(^)(CGFloat value))progress;

@end