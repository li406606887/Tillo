//
//  ScanResultOfGroupViewController.h
//  T-Shion
//
//  Created by 与梦信息的Mac on 2019/4/26.
//  Copyright © 2019年 With_Dream. All rights reserved.
//

#import "BaseViewController.h"

typedef NS_ENUM(NSInteger, ScanResultOfGroupType)
{
    ScanResultOfGroupTypeDefault,//正常可以加入
    ScanResultOfGroupTypeVerify,//开启验证
    ScanResultOfGroupTypePastDue,//二维码过期
    ScanResultOfGroupTypeLeave,//邀请人以离开群
};


@interface ScanResultOfGroupViewController : BaseViewController

- (instancetype)initWithType:(ScanResultOfGroupType)type resultData:(id)resultData;

@end

