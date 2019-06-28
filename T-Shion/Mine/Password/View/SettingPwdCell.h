//
//  SettingPwdCell.h
//  T-Shion
//
//  Created by 与梦信息的Mac on 2018/12/21.
//  Copyright © 2018年 With_Dream. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SettingPwdCell;
UIKIT_EXTERN NSString *const SettingPwdCellReuseIdentifier;

@protocol SettingPwdCellDelegate <NSObject>

@optional

- (void)settingPwdCell:(SettingPwdCell *)cell didContentChange:(NSString *)content;

@end


@interface SettingPwdCell : UITableViewCell

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *placeholder;
@property (nonatomic, copy) NSString *content;
@property (nonatomic, strong) NSIndexPath *editIndexPath;

@property (nonatomic, weak) id <SettingPwdCellDelegate> delegate;

@end

