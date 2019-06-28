
//
//  MessageFileView.m
//  AilloTest
//
//  Created by together on 2019/2/18.
//  Copyright © 2019年 With_Dream. All rights reserved.
//

#import "MessageFileView.h"

@implementation MessageFileView
- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupViews];
        self.layer.cornerRadius = 5;
        self.layer.masksToBounds = YES;
    }
    return self;
}

- (void)setupViews {
    [self addSubview:self.backView];
    [self addSubview:self.touchView];
    [self.touchView addSubview:self.icon];
    [self.touchView addSubview:self.fileName];
    [self.touchView addSubview:self.fileSize];
}

- (void)layoutSubviews {
    [self.backView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    
    [self.touchView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    
    [self.icon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_offset(CGSizeMake(29, 35));
        make.centerY.equalTo(self);
        make.left.equalTo(self).with.offset(15);
    }];
    
    [self.fileName mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.icon);
        make.left.equalTo(self.icon.mas_right).with.offset(14.5);
        make.right.equalTo(self.touchView.mas_right).with.offset(-16.5);
        make.height.offset(18);
    }];
    
    [self.fileSize mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.icon.mas_bottom);
        make.left.equalTo(self.icon.mas_right).with.offset(14.5);
        make.right.equalTo(self.touchView.mas_right).with.offset(-16.5);
        make.height.offset(14);
    }];
    
    [super layoutSubviews];
}

- (void)setMessage:(MessageModel *)message {
    [super setMessage:message];
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
}

- (CGSize)bubbleSize {
    return CGSizeMake(250, 70);
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    self.touchView.backgroundColor = RGBACOLOR(200, 200, 200, 0.5);
    [super touchesBegan:touches withEvent:event];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self hiddenTouchView];
    [super touchesEnded:touches withEvent:event];
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self hiddenTouchView];
    [super touchesCancelled:touches withEvent:event];
}

- (void)hiddenTouchView {
    @weakify(self)
    [UIView animateWithDuration:0.15 animations:^{
       @strongify(self)
        self.touchView.backgroundColor = [UIColor whiteColor];
    }];
}
/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */

#pragma mark lazy load
- (UIView *)touchView {
    if (!_touchView) {
        _touchView = [[UIView alloc] init];
        _touchView.backgroundColor = [UIColor whiteColor];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] init];
        @weakify(self)
        [[tap rac_gestureSignal] subscribeNext:^(__kindof UIGestureRecognizer * _Nullable x) {
            @strongify(self)
            if (self.fileClickBlock) {
                self.fileClickBlock(self.message);
            }
            self.touchView.backgroundColor = RGBACOLOR(200, 200, 200, 0.5);
            [self hiddenTouchView];
        }];
        [_touchView addGestureRecognizer:tap];
        _touchView.userInteractionEnabled = YES;
    }
    return _touchView;
}

- (UIView *)backView {
    if (!_backView) {
        _backView = [[UIView alloc] init];
        _backView.backgroundColor = [UIColor whiteColor];
    }
    return _backView;
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
