//
//  LoginTask.h
//  GRL
//
//  Created by Mac Developer001 on 3/3/16.
//  Copyright © 2016 Wangu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"


@interface SaveVoteTask : NSObject
{
    void (^_completionHandler)(int code, NSDictionary *result);
}


- (void)sendRequest:(NSString *)userId MusicId:(NSString *)musicId VoteValue:(NSInteger)vote Response:(void(^)(int, NSDictionary *))response;

@end