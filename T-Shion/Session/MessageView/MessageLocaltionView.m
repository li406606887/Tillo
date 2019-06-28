//
//  MessageLocaltionView.m
//  T-Shion
//
//  Created by 与梦信息的Mac on 2019/3/4.
//  Copyright © 2019年 With_Dream. All rights reserved.
//

#import "MessageLocaltionView.h"

@interface MessageLocaltionView ()

@property (nonatomic, strong) UIImageView *snapView;//位置截图
@property (nonatomic, strong) UILabel *contentLabel;//位置信息

@end


@implementation MessageLocaltionView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor whiteColor];
        self.userInteractionEnabled = YES;
        self.layer.masksToBounds = YES;
        self.layer.cornerRadius = 6;
        self.layer.borderColor = [UIColor ALLineColor].CGColor;
        self.layer.borderWidth = 0.5;
        [self addSubview:self.snapView];
        [self addSubview:self.contentLabel];
        [self setupConstraints];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] init];
        @weakify(self)
        [[tap rac_gestureSignal] subscribeNext:^(__kindof UIGestureRecognizer * _Nullable x) {
            @strongify(self)
            if (self.lookLocationDetailBlock) {
                self.lookLocationDetailBlock(self.message);
            }
        }];
        [self addGestureRecognizer:tap];
    }
    return self;
}

- (void)setupConstraints {
    [self.snapView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.mas_left);
        make.right.equalTo(self.mas_right);
        make.top.equalTo(self.mas_top);
        make.height.mas_equalTo(100);
    }];
    
    [self.contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.mas_left).with.offset(5);
        make.right.equalTo(self.mas_right).with.offset(-5);
        make.top.equalTo(self.snapView.mas_bottom);
        make.bottom.equalTo(self.mas_bottom);
    }];
}

- (CGSize)bubbleSize {
    return CGSizeMake(200, 140);
}


#pragma mark - getter
- (UIImageView *)snapView {
    if (!_snapView) {
        _snapView = [[UIImageView alloc] init];
        _snapView.backgroundColor = [UIColor ALGrayBgColor];
        _snapView.contentMode = UIViewContentModeScaleAspectFill;
    }
    return _snapView;
}

- (UILabel *)contentLabel {
    if (!_contentLabel) {
        _contentLabel = [UILabel constructLabel:CGRectZero
                                           text:nil
                                           font:[UIFont ALFontSize13]
                                      textColor:[UIColor ALTextDarkColor]];
        _contentLabel.textAlignment = NSTextAlignmentLeft;
        _contentLabel.numberOfLines = 2;
        _contentLabel.backgroundColor = [UIColor whiteColor];
        _contentLabel.preferredMaxLayoutWidth = 200;
    }
    return _contentLabel;
}

#pragma mark - setter
- (void)setMessage:(MessageModel *)message {
    [super setMessage:message];
    self.snapView.image = nil;
    NSDictionary *dataDict = [message.locationInfo mj_JSONObject];
    __block NSString *imagePath = [[FMDBManager getMessagePathWithMessage:message] stringByAppendingPathComponent:message.fileName];
    
    if ([FMDBManager seletedFileIsSaveWithPath:message]) {
        [self.snapView sd_setImageWithURL:[NSURL fileURLWithPath:imagePath]];
    } else {
        if (message.isCryptoMessage) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                NSError *error;
                BOOL result = [TSRequest downloadImageWithMessageModel:message imageURL:dataDict[@"locationImg"] error:&error];
                if (error==nil&&result==YES) {
                    NSLog(@"图片下载成功");
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    UIImage *image = [UIImage imageWithContentsOfFile:imagePath];
                    self.snapView.image = image;
                    [self bringSubviewToFront:self.contentLabel];
                });
            });
        }
        else {
            [self.snapView sd_setImageWithURL:[NSURL URLWithString:dataDict[@"locationImg"]] completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
                if (!error) {
                    //指定新建文件夹路径
                    NSData *data = UIImageJPEGRepresentation(image, 1);
                    [data writeToFile:imagePath atomically:YES];
                }
            }];
        }
    }

    if (dataDict) {
        self.contentLabel.text = [NSString stringWithFormat:@"%@%@",dataDict[@"name"],dataDict[@"address"]];
    }
    
}

@end
