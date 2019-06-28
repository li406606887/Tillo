//
//  MenuTableViewCell.m
//  T-Shion
//
//  Created by together on 2018/6/12.
//  Copyright © 2018年 With_Dream. All rights reserved.
//

#import "MenuTableViewCell.h"

@implementation MenuTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (void)setupViews {
    [self.contentView addSubview:self.icon];
    [self.contentView addSubview:self.name];
    [self.contentView addSubview:self.redView];
    [self setNeedsUpdateConstraints];
}

- (void)updateConstraints {
    [self.icon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView);
        make.left.equalTo(self.contentView).with.offset(22);
        make.size.mas_offset(CGSizeMake(22, 22));
    }];
    
    [self.name mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.icon.mas_right).with.offset(14);
        make.centerY.equalTo(self.contentView);
        make.right.equalTo(self.contentView.mas_right);
        make.height.offset(20);
    }];
    
    [self.redView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView);
        make.right.equalTo(self.contentView.mas_right).with.offset(-22);
        make.size.mas_offset(CGSizeMake(8, 8));
    }];
    [super updateConstraints];
}

- (void)setTag:(NSInteger)tag {
    if (tag == 1) {
        NSString *key = [NSString stringWithFormat:@"%@_Friend_Count",[SocketViewModel shared].userModel.ID];
        NSString *count = [[NSUserDefaults standardUserDefaults] objectForKey:key];
        self.redView.hidden = [count intValue]  >0 ? NO: YES;
    }
}

- (UIImageView *)icon {
    if (!_icon) {
        _icon = [[UIImageView alloc] init];
        _icon.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _icon;
}

- (UILabel *)name {
    if (!_name) {
        _name = [[UILabel alloc] init];
        _name.font = [UIFont fontWithName:@"pingfangsc-medium" size:16];
        _name.textColor = [UIColor ALTextDarkColor];
    }
    return _name;
}

- (UIView *)redView {
    if (!_redView) {
        _redView = [[UIView alloc] init];
        _redView.backgroundColor = [UIColor redColor];
        _redView.layer.masksToBounds = YES;
        _redView.layer.cornerRadius = 4;
    }
    return _redView;
}

- (void)drawRect:(CGRect)rect {
    // Drawing code.
    //获得处理的上下文
    CGContextRef context = UIGraphicsGetCurrentContext();
    //设置线条样式
    CGContextSetLineCap(context, kCGLineCapSquare);
    //设置线条粗细宽度
    CGContextSetLineWidth(context, 0.33);
    //设置颜色
    CGContextSetRGBStrokeColor(context, 0.8, 0.8, 0.8, 1.0);
    //开始一个起始路径
    CGContextBeginPath(context);
    //起始点设置为(0,0):注意这是上下文对应区域中的相对坐标，
    CGContextMoveToPoint(context, 60, 56);
    //设置下一个坐标点
    CGContextAddLineToPoint(context, SCREEN_WIDTH, 56);
    //连接上面定义的坐标点
    CGContextStrokePath(context);
}
@end
