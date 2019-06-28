//
//  TSImageCollectionCell.h
//  T-Shion
//
//  Created by 王四的mac air on 2018/3/27.
//  Copyright © 2018年 With_Dream. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>

@interface TSImageCollectionCell : UICollectionViewCell

@property (strong , nonatomic) PHAsset *phAsset;
@property (strong , nonatomic) NSIndexPath *indexPath;
@property (strong , nonatomic) UIButton *selectedBtn;
@property (strong , nonatomic) UIImageView *imageView;
@property (copy, nonatomic) void (^cellSelectedBlock) (BOOL state);

- (void)resetSelected:(BOOL)selected;

- (void)selectedBtnClick:(UIButton *)sender;

@end
