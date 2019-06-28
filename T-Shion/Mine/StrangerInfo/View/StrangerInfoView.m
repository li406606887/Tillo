//
//  StrangerInfoView.m
//  T-Shion
//
//  Created by together on 2018/8/9.
//  Copyright © 2018年 With_Dream. All rights reserved.
//

#import "StrangerInfoView.h"

@implementation StrangerInfoView
- (instancetype)initWithViewModel:(id<BaseViewModelProtocol>)viewModel {
    self.viewModel = (StrangerInfoViewModel *)viewModel;
    return [super initWithViewModel:viewModel];
}

- (void)setupViews {
    [self addSubview:self.icon];
    [self addSubview:self.name];
    [self addSubview:self.addBtn];
}

- (void)layoutSubviews {
    [self.icon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self);
        make.left.equalTo(self).with.offset(10);
        make.size.mas_offset(CGSizeMake(40, 40));
    }];
    
    [self.name mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.icon.mas_right).with.offset(14);
        make.centerY.equalTo(self);
        make.right.equalTo(self.mas_right);
        make.height.offset(20);
    }];
    
    [self.addBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.mas_right).with.offset(-14);
        make.centerY.equalTo(self);
        make.size.mas_offset(CGSizeMake(60, 30));
    }];
    
    [super layoutSubviews];
}

- (void)showAddFirendView {
    // 1.创建UIAlertController
    __block UITextField *field;
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"验证信息"
                                                                             message:@""
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    
    // 2.1 添加文本框
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"";
//        textField.
        field = textField;
    }];
    
    UIAlertAction *send = [UIAlertAction actionWithTitle:@"发送" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
        [param setObject:@"0" forKey:@"status"];//0表示申请加好友  1表示通过
        [param setObject:[SocketViewModel shared].userModel.ID forKey:@"sender"];
        [param setObject:self.model.userId forKey:@"receiver"];
        [param setObject:field.text forKey:@"remark"];
        [self.viewModel.addFriendsCommand execute:param];
    }];
    
    
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:Localized(@"Cancel") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        NSLog(@"Reset Action");
    }];
    [alertController addAction:send];
    [alertController addAction:cancel];
    // 3.显示警报控制器
    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alertController animated:YES completion:nil];
}


- (void)setModel:(MemberModel *)model {
    _model = model;
    self.icon.image = nil;
    self.name.text = model.name;
    
    NSString *imagePath = [TShionSingleCase thumbAvatarImgPathWithUserId:model.userId];
    [TShionSingleCase loadingAvatarWithImageView:self.icon url:[NSString ym_thumbAvatarUrlStringWithOriginalString:model.avatar] filePath:imagePath];
    
}

- (UIImageView *)icon {
    if (!_icon) {
        _icon = [[UIImageView alloc] init];
        _icon.layer.masksToBounds = YES;
        _icon.layer.cornerRadius = 20;
    }
    return _icon;
}

- (UILabel *)name {
    if (!_name) {
        _name = [[UILabel alloc] init];
        _name.font = [UIFont systemFontOfSize:15];
        _name.textColor = [UIColor ALTextDarkColor];
    }
    return _name;
}

- (UIButton *)addBtn {
    if (!_addBtn) {
        _addBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        [_addBtn setTitle:@"添加" forState:UIControlStateNormal];
        [_addBtn.titleLabel setFont:[UIFont systemFontOfSize:14]];
        @weakify(self)
        [[_addBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
            @strongify(self)
            [self showAddFirendView];
        }];
    }
    return _addBtn;
}
@end
