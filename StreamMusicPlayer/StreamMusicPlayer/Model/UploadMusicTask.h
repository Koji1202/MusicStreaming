//
//  LoginTask.h
//  GRL
//
//  Created by Mac Developer001 on 3/3/16.
//  Copyright © 2016 Wangu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"


@interface UploadMusicTask : NSObject
{
    void (^_completionHandler)(int code, NSDictionary *data);
}


- (void)sendRequest:(NSString *)title Album:(NSString *)album Artist:(NSString *)artist Duration:(float)duration Thumb:(NSString *)thumb Path:(NSString *)path Response:(void(^)(int, NSDictionary *))response;

@end