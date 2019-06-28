//
//  MyInfoTableViewCell.h
//  T-Shion
//
//  Created by together on 2018/6/25.
//  Copyright © 2018年 With_Dream. All rights reserved.
//

#import "BaseTableViewCell.h"

@interface MyInfoTableViewCell : BaseTableViewCell<UINavigationControllerDelegate,UIImagePickerControllerDelegate>
@property (strong, nonatomic) UILabel *title;
@property (strong, nonatomic) UILabel *field;
@end

@interface MyInfoHeadViewCell : BaseTableViewCell<UINavigationControllerDelegate,UIImagePickerControllerDelegate>
@property (strong, nonatomic) UILabel *title;
@property (strong, nonatomic) UIImageView * headIcon;
@property (strong, nonatomic) UIImageView * headBack;
@property (copy, nonatomic) void(^headBlock) (UIImage *image);
@end
