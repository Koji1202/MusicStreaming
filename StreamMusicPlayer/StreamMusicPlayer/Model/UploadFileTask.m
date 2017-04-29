//
//  UploadFileTask.m
//  GRL
//
//  Created by Mac Developer001 on 3/25/16.
//  Copyright © 2016 Wangu. All rights reserved.
//

#import "UploadFileTask.h"
#import "GlobalVars.h"

@implementation  UploadFileTask

- (NSString *)getUrl {
    return [NSString stringWithFormat: @"%@/upload/file_upload", [[GlobalVars sharedInstance] getServerUrl]];
}

- (void)sendRequest:(NSData *)data MimeType:(NSString *)mimeType FileName:(NSString *)fileName Response:(void(^)(int, NSDictionary *))response Progress:(void(^)(CGFloat value))progress {
    
    _completionHandler = [response copy];
    if (progress != nil)
        _progressHandler = [progress copy];
    else
        _progressHandler = nil;
    
    NSDictionary *params = @{@"session_id" : [GlobalVars sharedInstance].sessionId,
                             @"user_id" : [GlobalVars sharedInstance].userId
                            };
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    [manager setTaskDidSendBodyDataBlock:^(NSURLSession *session, NSURLSessionTask *task, int64_t bytesSent, int64_t totalBytesSent, int64_t totalBytesExpectedToSend) {
        //during the progress
        if (_progressHandler != nil)
            _progressHandler(totalBytesSent / totalBytesExpectedToSend);
    }];
    
    NSMutableURLRequest *request = [[AFHTTPRequestSerializer serializer]  multipartFormRequestWithMethod:@"POST" URLString:[self getUrl] parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFileData:data name:@"upfile" fileName:fileName mimeType:mimeType];
    } error:nil];

    NSURLSessionDataTask *uploadTask = [manager uploadTaskWithStreamedRequest:request progress:nil completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        NSString *temp = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        id result = [[GlobalVars sharedInstance] getJsonData:responseObject];
        int code = [[result objectForKey:@"result_code"] integerValue];
        if (code == ERR_OK) {
            _completionHandler(code, result[@"result_data"]);
        } else {
            _completionHandler(code, nil);
        }
    }];
    [uploadTask resume];
}

@end