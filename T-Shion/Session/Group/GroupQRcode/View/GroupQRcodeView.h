//
//  GroupQRcodeView.h
//  AilloTest
//
//  Created by together on 2019/4/18.
//  Copyright © 2019年 With_Dream. All rights reserved.
//

#import "BaseView.h"
#import "GroupQRcodeViewModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface GroupQRcodeView : BaseView
@property (strong, nonatomic) UIView *backView;
@property (strong, nonatomic) UIImageView *icon;
@property (strong, nonatomic) UILabel *name;
@property (strong, nonatomic) UIImageView *qrcode;
@property (strong, nonatomic) UILabel *details;
@property (weak, nonatomic) GroupQRcodeViewModel *viewModel;
@end

NS_ASSUME_NONNULL_END
