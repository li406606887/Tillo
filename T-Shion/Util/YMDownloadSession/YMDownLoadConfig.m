//
//  YMDownLoadConfig.m
//  YMDownloadSessionDemo
//
//  Created by 与梦信息的Mac on 2019/5/5.
//  Copyright © 2019年 与梦信息技术有限公司. All rights reserved.
//

#import "YMDownLoadConfig.h"

@implementation YMDownLoadConfig

- (NSUInteger)maxTaskCount {
    return _maxTaskCount ? _maxTaskCount : 1;
}

@end
