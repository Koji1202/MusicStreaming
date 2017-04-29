
//
//  ParkingListTask.h
//  GRL
//
//  Created by Mac Developer001 on 3/3/16.
//  Copyright © 2016 Wangu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"


@interface MusicListTask : NSObject
{
    void (^_completionHandler)(int success, NSMutableArray *data);
}


- (void)sendRequest:(NSString *)userId Response:(void(^)(int, NSMutableArray *))response;

@end