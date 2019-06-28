//
//  ALMoreKeyboardItem.h
//  T-Shion
//
//  Created by 与梦信息的Mac on 2019/2/27.
//  Copyright © 2019年 With_Dream. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, ALMoreKeyboardItemType) {
    ALMoreKeyboardItemTypeFile,//文件
    ALMoreKeyboardItemTypePosition,//位置
    ALMoreKeyboardItemTypeCard,//个人名片
};


@interface ALMoreKeyboardItem : NSObject

@property (nonatomic, assign) ALMoreKeyboardItemType type;

@property (nonatomic, strong) NSString *title;

@property (nonatomic, strong) NSString *imagePath;


/**
 快捷创建MoreKeyboardItem

 @param type 类型
 @param title 类型描述
 @param imagePath 图标
 @return ALMoreKeyboardItem
 */
+ (ALMoreKeyboardItem *)createByType:(ALMoreKeyboardItemType)type
                               title:(NSString *)title
                           imagePath:(NSString *)imagePath;

@end

NS_ASSUME_NONNULL_END
