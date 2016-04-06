//
//  VideoModel.m
//  视频
//
//  Created by 魏永贺 on 16/4/4.
//  Copyright © 2016年 魏永贺. All rights reserved.
//

#import "VideoModel.h"

@implementation VideoModel
- (void)setValue:(id)value forUndefinedKey:(NSString *)key
{
    if ([key isEqualToString:@"description"]) {
        self.descriptionDe = value;
    }
}

@end
