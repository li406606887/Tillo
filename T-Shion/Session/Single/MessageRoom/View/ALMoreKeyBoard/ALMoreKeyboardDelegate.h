//
//  ALMoreKeyboardDelegate.h
//  T-Shion
//
//  Created by 与梦信息的Mac on 2019/2/27.
//  Copyright © 2019年 With_Dream. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ALMoreKeyboardItem.h"

NS_ASSUME_NONNULL_BEGIN

@protocol ALMoreKeyboardDelegate <NSObject>

@optional
- (void)moreKeyboard:(id)keyboard didSelectedFunctionItem:(ALMoreKeyboardItem *)funcItem;

@end

NS_ASSUME_NONNULL_END
