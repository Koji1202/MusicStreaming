//
//  ParkingListTask
//  GRL
//
//  Created by Mac Developer001 on 3/3/16.
//  Copyright © 2016 Wangu. All rights reserved.
//

#import "MusicListTask.h"
#import "GlobalVars.h"

@implementation  MusicListTask

- (NSString *)getUrl {
    return [NSString stringWithFormat: @"%@/music/list_music", [[GlobalVars sharedInstance] getServerUrl]];
}

- (void)sendRequest:(NSString *)userId Response:(void(^)(int, NSMutableArray *))response {
    
    _completionHandler = [response copy];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    AFJSONRequestSerializer *serializer = [AFJSONRequestSerializer serializer];
    [serializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [serializer setValue:@"text/html" forHTTPHeaderField:@"Accept"];
    manager.requestSerializer = serializer;
    
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    NSDictionary *params = @{@"session_id" : [GlobalVars sharedInstance].sessionId,
                             @"user_id" : userId
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