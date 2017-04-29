//
//  LoginTask.h
//  GRL
//
//  Created by Mac Developer001 on 3/3/16.
//  Copyright © 2016 Wangu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"


@interface LoginTask : NSObject
{
    void (^_completionHandler)(int code, NSDictionary *data);
}

- (void)sendRequest:(NSString *)email Password:(NSString *)password FacebookId:(NSString *)facebookId Response:(void(^)(int, NSDictionary *))response;

@end