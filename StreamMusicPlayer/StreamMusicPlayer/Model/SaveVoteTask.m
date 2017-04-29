//
//  LoginTask.m
//  GRL
//
//  Created by Mac Developer001 on 3/3/16.
//  Copyright © 2016 Wangu. All rights reserved.
//

#import "SaveVoteTask.h"
#import "GlobalVars.h"

@implementation  SaveVoteTask

- (NSString *)getUrl {
    return [NSString stringWithFormat: @"%@/music/save_vote", [[GlobalVars sharedInstance] getServerUrl]];
}

- (void)sendRequest:(NSString *)userId MusicId:(NSString *)musicId VoteValue:(NSInteger)vote Response:(void(^)(int, NSDictionary *))response {
    
    _completionHandler = [response copy];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    AFJSONRequestSerializer *serializer = [AFJSONRequestSerializer serializer];
    [serializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [serializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    manager.requestSerializer = serializer;
    
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    NSDictionary *params = @{@"session_id" : [GlobalVars sharedInstance].sessionId,
                             @"user_id" : userId,
                             @"music_id" : musicId,
                             @"vote" : [NSNumber numberWithInteger:vote]
                             };
    
    //NSLog([NSString stringWithFormat:@"%@", params]);
    [manager POST:[self getUrl] parameters:params constructingBodyWithBlock:nil progress:nil success:^(NSURLSessionDataTask *task, id  responseObject) {
        NSString *temp = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        id result = [[GlobalVars sharedInstance] getJsonData:responseObject];
        NSInteger code = [[result objectForKey:@"result_code"] integerValue];
        _completionHandler(code, [result objectForKey:@"result_data"]);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        _completionHandler(ERR_UNKOWN, nil);
    }];
}

@end