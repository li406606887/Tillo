//
//  BaseTableViewCell.m
//  RDFuturesApp
//
//  Created by user on 17/3/1.
//  Copyright © 2017年 FuturesApp. All rights reserved.
//

#import "BaseTableViewCell.h"

@implementation BaseTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupViews];
        CGRect rect = self.frame;
        UIGraphicsBeginImageContext(rect.size);
        CGContextRef context = UIGraphicsGetCurrentContext();
        //高亮颜色值
        UIColor *selectedColor = RGB(245, 245, 245);
        CGContextSetFillColorWithColor(context, [selectedColor CGColor]);
        CGContextFillRect(context, rect);
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        self.selectedBackgroundView = [[UIImageView alloc] initWithImage:image];
    }
    return self;
}

- (void)setupViews {
    
}


@end
