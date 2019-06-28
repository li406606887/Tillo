//
//  ALMoreKeyBoard.h
//  T-Shion
//
//  Created by 与梦信息的Mac on 2019/2/27.
//  Copyright © 2019年 With_Dream. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ALMoreKeyboardDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@interface ALMoreKeyBoard : UIView

@property (nonatomic, weak) id <ALMoreKeyboardDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
