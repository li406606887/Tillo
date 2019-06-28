//
//  ALMoreKeyBoardCell.h
//  T-Shion
//
//  Created by 与梦信息的Mac on 2019/2/27.
//  Copyright © 2019年 With_Dream. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ALMoreKeyboardItem;

@interface ALMoreKeyBoardCell : UICollectionViewCell

@property (nonatomic, strong) ALMoreKeyboardItem *item;

@property (nonatomic, strong) void(^clickBlock)(ALMoreKeyboardItem *item);

@end

