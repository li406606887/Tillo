//
//  LookForFileTableViewCell.m
//  T-Shion
//
//  Created by together on 2019/4/15.
//  Copyright © 2019年 With_Dream. All rights reserved.
//

#import "LookForFileTableViewCell.h"
#import "NSString+Storage.h"

@implementation LookForFileTableViewCell

- (void)setupViews {
    [self addSubview:self.head];
    [self addSubview:self.name];
    [self addSubview:self.timerLabel];
    [self addSubview:self.backView];
    [self.backView addSubview:self.icon];
    [self.backView addSubview:self.fileName];
    [self.backView addSubview:self.fileSize];
}

- (void)layoutSubviews {
    [self.head mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.equalTo(self).with.offset(15);
        make.size.mas_offset(CGSizeMake(30, 30));
    }];
    
    [self.name mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.head.mas_right).with.offset(10.5);
        make.centerY.equalTo(self.head);
        make.size.mas_offset(CGSizeMake(150, 20));
    }];
    
    [self.timerLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.head);
        make.right.equalTo(self.mas_right).with.offset(-15.5);
        make.size.mas_offset(CGSizeMake(150, 20));
    }];
    
    [self.backView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.head.mas_bottom).with.offset(20);
        make.centerX.equalTo(self);
        make.size.mas_offset(CGSizeMake(SCREEN_WIDTH-30, 70));
    }];
    
    [self.icon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_offset(CGSizeMake(29, 35));
        make.centerY.equalTo(self.backView);
        make.left.equalTo(self.backView).with.offset(15);
    }];
    
    [self.fileName mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.icon);
        make.left.equalTo(self.icon.mas_right).with.offset(14.5);
        make.right.equalTo(self.backView.mas_right).with.offset(-16.5);
        make.height.offset(18);
    }];
    
    [self.fileSize mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.icon.mas_bottom);
        make.left.equalTo(self.icon.mas_right).with.offset(14.5);
        make.right.equalTo(self.backView.mas_right).with.offset(-16.5);
        make.height.offset(14);
    }];
    
    [super layoutSubviews];
}

- (void)setMessage:(MessageModel *)message {
    self.fileName.text = message.fileName;
    long totalSize = [message.fileSize longLongValue];
    self.fileSize.text = [NSString stringWithFormat:@"%ld b",totalSize];
    if (totalSize>1000) {
        long kb = totalSize/1000;
        long b = totalSize%1000;
        self.fileSize.text = [NSString stringWithFormat:@"%ld.%ld K",kb,b];
        if (kb>1000) {
            long mb = kb/1000;
            self.fileSize.text = [NSString stringWithFormat:@"%ld.%ld M",mb,kb];
            if (mb>1000) {
                long gb = mb/1000;
                self.fileSize.text = [NSString stringWithFormat:@"%ld.%ld G",gb,mb];
                if (gb>1000) {
                    long tb = gb/1000;
                    self.fileSize.text = [NSString stringWithFormat:@"%ld.%ld T",tb,gb];
                }
            }
        }
    }
    UIImage *image ;
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
    _icon.image = image;
    
    NSString *imagePath = [TShionSingleCase thumbAvatarImgPathWithUserId:message.sender];
    [TShionSingleCase loadingAvatarWithImageView:self.head url:[NSString ym_thumbAvatarUrlStringWithOriginalString:message.senderInfo.avatar] filePath:imagePath];
    
    self.name.text = message.senderInfo.showName;
    self.timerLabel.text = message.times;
}


/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */

#pragma mark lazy load
- (UIView *)backView {
    if (!_backView) {
        _backView = [[UIView alloc] init];
        _backView.layer.cornerRadius = 5;
        _backView.layer.masksToBounds = YES;
        _backView.backgroundColor = RGB(249, 249, 248);
    }
    return _backView;
}

- (UIImageView *)head {
    if (!_head) {
        _head = [[UIImageView alloc] init];
        _head.contentMode = UIViewContentModeScaleAspectFit;
        _head.image = [UIImage imageNamed:@"Avatar_Deafult"];
        _head.layer.cornerRadius = 15;
        _head.layer.masksToBounds = YES;
    }
    return _head;
}

- (UILabel *)name {
    if (!_name) {
        _name = [[UILabel alloc] init];
        _name.font = [UIFont fontWithName:@"PingFang-SC-Bold" size:14];
        _name.lineBreakMode = NSLineBreakByTruncatingMiddle;
        _name.text = @"用户昵称";
    }
    return _name;
}

- (UILabel *)timerLabel {
    if (!_timerLabel) {
        _timerLabel = [[UILabel alloc] init];
        _timerLabel.font = [UIFont fontWithName:@"PingFang-SC-Medium" size:14];
        _timerLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
        _timerLabel.text = @"2015-03-02";
        _timerLabel.textAlignment = NSTextAlignmentRight;
    }
    return _timerLabel;
}

- (UIImageView *)icon {
    if (!_icon) {
        _icon = [[UIImageView alloc] init];
        _icon.contentMode = UIViewContentModeScaleAspectFit;
        _icon.image = [UIImage imageNamed:@"Message_File_Unknown_Type"];
    }
    return _icon;
}

- (UILabel *)fileName {
    if (!_fileName) {
        _fileName = [[UILabel alloc] init];
        _fileName.font = [UIFont systemFontOfSize:16];
        _fileName.lineBreakMode = NSLineBreakByTruncatingMiddle;
        _fileName.text = @"宇宙无敌闪瞎氪金狗眼的超级增益BUFF.buff";
    }
    return _fileName;
}

- (UILabel *)fileSize {
    if (!_fileSize) {
        _fileSize = [[UILabel alloc] init];
        _fileSize.font = [UIFont systemFontOfSize:12];
        //        _fileSize.lineBreakMode = NSLineBreakByWordWrapping;
        _fileSize.text = @"103.3tb";
    }
    return _fileSize;
}


@end
