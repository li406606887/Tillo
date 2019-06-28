//
//  SettingHeadView.h
//  T-Shion
//
//  Created by 与梦信息的Mac on 2019/1/11.
//  Copyright © 2019年 With_Dream. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SettingHeadViewDelegate <NSObject>

@optional

- (void)didQRCodeButtonClick;
- (void)shouldGotoUserInfo;

@end


@interface SettingHeadView : UIView

@property (nonatomic, weak) id <SettingHeadViewDelegate>delegate;

@end


