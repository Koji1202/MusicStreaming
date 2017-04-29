//
//  KBHairlineLayoutContraint.m
//  GRL
//
//  Created by VICTOR on 5/18/16.
//  Copyright © 2016 Wangu. All rights reserved.
//

#import "KBHairlineLayoutContraint.h"

@implementation KBHairlineLayoutContraint
#pragma mark - 
- (void)awakeFromNib {
    [super awakeFromNib];
    if(self.constant == 1)
        self.constant = 1 /[UIScreen mainScreen].scale;
}
@end
