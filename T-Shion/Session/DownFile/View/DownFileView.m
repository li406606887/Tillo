//
//  DownFileView.m
//  T-Shion
//
//  Created by together on 2019/2/21.
//  Copyright © 2019年 With_Dream. All rights reserved.
//

#import "DownFileView.h"
#import "DownFileViewModel.h"
#import "MessageModel.h"

@interface DownFileView ()
@property (weak, nonatomic) DownFileViewModel *viewModel;
@property (strong, nonatomic) UILabel *fileName;
@property (strong, nonatomic) UIImageView *fileIcon;
@property (strong, nonatomic) UIButton *downBtn;
    
@end

@implementation DownFileView
- (instancetype)initWithViewModel:(id<BaseViewModelProtocol>)viewModel {
    self.viewModel = (DownFileViewModel *)viewModel;
    return [super initWithViewModel:viewModel];
}

- (void)setupViews {
    [self addSubview:self.fileIcon];
    [self addSubview:self.fileName];
    [self addSubview:self.downBtn];
}

- (void)layoutSubviews {
    [self.fileIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).with.offset(125.5);
        make.centerX.equalTo(self);
        make.size.mas_offset(CGSizeMake(59.5, 70.5));
    }];
    
    [self.fileName mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.top.equalTo(self.fileIcon.mas_bottom).with.offset(30);
        make.size.mas_offset(CGSizeMake(SCREEN_WIDTH - 50, 50));
    }];
    
    [self.downBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_offset(CGSizeMake(200, 45));
        make.top.equalTo(self.fileName.mas_bottom).with.offset(150);
        make.centerX.equalTo(self);
    }];
    [super layoutSubviews];
}

- (void)bindViewModel {
    @weakify(self)
    [self.viewModel.downloadFileSubject subscribeNext:^(id  _Nullable x) {
        @strongify(self)
        [self.downBtn setTitle:@"用其他方式打开" forState:UIControlStateNormal];
        [self.viewModel.opernFileSubject sendNext:nil];
    }];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (UIImageView *)fileIcon {
    if (!_fileIcon) {
        _fileIcon = [[UIImageView alloc] init];
        UIImage *image ;
        MessageModel *message = self.viewModel.message;
        if ([message.fileName containsString:@".zip"]||[message.fileName containsString:@".rar"]) {
            image = [UIImage imageNamed:@"Message_File_Assets"];
        }else if ([message.fileName containsString:@".doc"]) {
            image = [UIImage imageNamed:@"Message_File_Word"];
        }else if ([message.fileName containsString:@".ppt"]) {
            image = [UIImage imageNamed:@"Message_File_PPT"];
        }else if ([message.fileName containsString:@".xls"]) {
            image = [UIImage imageNamed:@"Message_File_Excel"];
        }else if ([message.fileName containsString:@".html"]) {
            image = [UIImage imageNamed:@"Message_File_Html"];
        }else if ([message.fileName containsString:@".mp3"]) {
            image = [UIImage imageNamed:@"Message_File_Music"];
        }else if ([message.fileName containsString:@".mp4"]) {
            image = [UIImage imageNamed:@"Message_File_Video"];
        }else if ([message.fileName containsString:@".text"]) {
            image = [UIImage imageNamed:@"Message_File_Text"];
        }else {
            image = [UIImage imageNamed:@"Message_File_Unknown_Type"];
        }
        _fileIcon.image = image;
    }
    return _fileIcon;
}

- (UILabel *)fileName {
    if (!_fileName) {
        _fileName = [[UILabel alloc] init];
        _fileName.font = [UIFont fontWithName:@"PingFang-SC-Bold" size:17];
        _fileName.textAlignment = NSTextAlignmentCenter;
        _fileName.text = self.viewModel.message.fileName;
    }
    return _fileName;
}

- (UIButton *)downBtn {
    if (!_downBtn) {
        _downBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        if (self.viewModel.state == 1) {
            [_downBtn setTitle:@"用其他方式打开" forState:UIControlStateNormal];
        }else {
            [_downBtn setTitle:@"下载" forState:UIControlStateNormal];
        }
        _downBtn.backgroundColor = RGB(84, 208, 172);
        _downBtn.layer.cornerRadius = 22.5;
        _downBtn.layer.masksToBounds = YES;
        @weakify(self)
        [[_downBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
            @strongify(self)
            if (self.viewModel.state == 1) {
                [self.viewModel.opernFileSubject sendNext:nil];
            }else {
                [self.viewModel.downloadFileCommand execute:self.viewModel.message];
            }
        }];
    }
    return _downBtn;
}
@end
