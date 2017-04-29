//
//  LoginTask.m
//  GRL
//
//  Created by Mac Developer001 on 3/3/16.
//  Copyright © 2016 Wangu. All rights reserved.
//

#import "UploadMusicTask.h"
#import "GlobalVars.h"

@implementation  UploadMusicTask

- (NSString *)getUrl {
    return [NSString stringWithFormat: @"%@/music/upload_music", [[GlobalVars sharedInstance] getServerUrl]];
}

- (void)sendRequest:(NSString *)title Album:(NSString *)album Artist:(NSString *)artist Duration:(float)duration Thumb:(NSString *)thumb Path:(NSString *)path Response:(void(^)(int, NSDictionary *))response {
    
    _completionHandler = [response copy];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    AFJSONRequestSerializer *serializer = [AFJSONRequestSerializer serializer];
    [serializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [serializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    manager.requestSerializer = serializer;
    
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    NSDictionary *params = @{@"session_id" : [GlobalVars sharedInstance].sessionId,
                             @"user_id" : [GlobalVars sharedInstance].userId,
                             @"title" : title,
                             @"artist" : artist,
                             @"album" : album,
                             @"duration" : [NSNumber numberWithFloat:duration],
                             @"thumb" : thumb,
                             @"path" : path,
                             @"latitude" : [NSNumber numberWithFloat:[GlobalVars sharedInstance].latitude],
                             @"longitude" : [NSNumber numberWithFloat:[GlobalVars sharedInstance].longitude],
                             @"city" : [[GlobalVars sharedInstance].posArea objectForKey:@"city"]
                             };
    //NSLog([NSString stringWithFormat:@"%@", params]);
    [manager POST:[self getUrl] parameters:params constructingBodyWithBlock:nil progress:nil success:^(NSURLSessionDataTask *task, id  responseObject) {
        NSString *temp = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        id result = [[GlobalVars sharedInstance] getJsonData:responseObject];
        int code = [[result objectForKey:@"result_code"] integerValue];
        if (code == ERR_OK)
            _completionHandler(code, result[@"result_data"]);
        else
            _completionHandler(code, nil);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        _completionHandler(TRUE, nil);
    }];
}

@end