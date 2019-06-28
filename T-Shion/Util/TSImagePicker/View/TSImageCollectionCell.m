//
//  TSImageCollectionCell.m
//  T-Shion
//
//  Created by 王四的mac air on 2018/3/27.
//  Copyright © 2018年 With_Dream. All rights reserved.
//

#import "TSImageCollectionCell.h"
#import <Photos/Photos.h>
#import "PHAsset+TS.h"
#import "TSImageSelectedHandler.h"

static CGFloat const kPadding = 3.f;
#define kImageCollectionCellWidth (SCREEN_WIDTH - 5 * kPadding) / 4

@interface TSImageCollectionCell()
@property (nonatomic, strong) UILabel *gifFlag;
//@property (nonatomic, strong) UIView *videoFlag;
@property (nonatomic, strong) UILabel *videoTimeLabel;
    
@end

@implementation TSImageCollectionCell
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self.contentView addSubview:self.imageView];
        [self.contentView addSubview:self.selectedBtn];
        [self.contentView addSubview:self.gifFlag];
//        [self.contentView addSubview:self.videoFlag];
        [self.contentView addSubview:self.videoTimeLabel];
    }
    return self;
}

- (void)layoutSubviews {
    [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.contentView);
    }];
    
    [self.selectedBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView).offset(3);
        make.right.equalTo(self.contentView).offset(-3);
        make.size.mas_offset(CGSizeMake(20, 20));
    }];
    
    [self.gifFlag mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView.mas_left).with.offset(5);
        make.bottom.equalTo(self.contentView.mas_bottom).with.offset(-5);
    }];
    
//    [self.videoFlag mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.equalTo(self.contentView.mas_left).with.offset(5);
//        make.bottom.equalTo(self.contentView.mas_bottom).with.offset(-5);
//        make.size.mas_equalTo(CGSizeMake(15, 15));
//    }];
    
    [self.videoTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView.mas_left);
        make.right.equalTo(self.contentView.mas_right);
        make.bottom.equalTo(self.contentView.mas_bottom);
        make.height.mas_equalTo(20);
//        make.centerY.equalTo(self.videoFlag.mas_centerY);
    }];
    
    [super layoutSubviews];
}

- (void)selectedBtnClick:(UIButton *)sender {
    //超过选中数量，不能再选了
    if (!sender.selected && [[TSImageSelectedHandler shareInstance] selectedIndexs].count >= [[TSImageSelectedHandler shareInstance] maxSelectedCount]) {
        return;
    }
    
    if (self.phAsset.mediaType == PHAssetMediaTypeVideo) {
        //不能分享短于1秒的视频
        int videoTime = floor(self.phAsset.duration);
        if (videoTime < 1) {
            ShowWinMessage(@"不能分享短于1秒的视频");
            return;
        }
    }
    
    sender.selected = !sender.isSelected;
    if (sender.selected) {
        [[TSImageSelectedHandler shareInstance] addAsset:self.phAsset];
        [[TSImageSelectedHandler shareInstance] addIndex:self.indexPath];
        [self postSelectAssetsAddNotification:self.indexPath];
        [self addScaleAnimation:sender];
        
        NSInteger index = [[[TSImageSelectedHandler shareInstance] selectedIndexs] indexOfObject:self.indexPath] + 1;
        
        [self.selectedBtn setTitle:[NSString stringWithFormat:@"%ld",index] forState:UIControlStateNormal];
     
    } else {
        [[TSImageSelectedHandler shareInstance] removeAsset:self.phAsset];
        [[TSImageSelectedHandler shareInstance] removeIndex:self.indexPath];
        [self postSelectAssetsRemoveNotification:self.indexPath];
        [self.selectedBtn setTitle:@"" forState:UIControlStateNormal];
    }
    
    if (self.cellSelectedBlock) {
        self.cellSelectedBlock(sender.selected);
    }
}

- (void)resetSelected:(BOOL)selected {
    self.selectedBtn.selected = selected;
    if (selected) {
        NSInteger index = [[[TSImageSelectedHandler shareInstance] selectedIndexs] indexOfObject:self.indexPath] + 1;
        
        [self.selectedBtn setTitle:[NSString stringWithFormat:@"%ld",index] forState:UIControlStateNormal];
    } else {
        [self.selectedBtn setTitle:@"" forState:UIControlStateNormal];
    }
}

- (void)postSelectAssetsRemoveNotification:(NSIndexPath *)indexPath {
    [[NSNotificationCenter defaultCenter] postNotificationName:kSelectAssetsRemoveNotification object:indexPath];
}

- (void)postSelectAssetsAddNotification:(NSIndexPath *)indexPath {
    [[NSNotificationCenter defaultCenter] postNotificationName:kSelectAssetsAddNotification object:indexPath];
}

- (void)addScaleAnimation:(UIView *)totalView {
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animation];
    animation.keyPath = @"transform.scale";
    animation.duration = 0.4f;
    NSValue *value0 = [NSValue valueWithCATransform3D:CATransform3DMakeScale(1, 1, 1)];
    NSValue *value1 = [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.25, 1.25, 1)];
    NSValue *value2 = [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.1, 1.1, 1)];
    NSValue *value3 = [NSValue valueWithCATransform3D:CATransform3DMakeScale(1, 1, 1)];
    NSValue *value4 = [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.05, 1.05, 1)];
    NSValue *value5 = [NSValue valueWithCATransform3D:CATransform3DMakeScale(1, 1, 1)];
    
    animation.values = @[value0,
                         value1,
                         value2,
                         value3,
                         value4,
                         value5];
    if (totalView.layer) {
        [totalView.layer addAnimation:animation forKey:nil];
    }
}

#pragma mark - getter and setter
- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc] init];
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.clipsToBounds = YES;
    }
    return _imageView;
}

- (UIButton *)selectedBtn {
    if (!_selectedBtn) {
        _selectedBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_selectedBtn setBackgroundImage:[UIImage imageNamed:@"photo_selected_n"] forState:UIControlStateNormal];
        [_selectedBtn setBackgroundImage:[UIImage imageWithColor:[UIColor ALKeyColor]] forState:UIControlStateSelected];
        [_selectedBtn addTarget:self action:@selector(selectedBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        _selectedBtn.layer.cornerRadius = 10;
        _selectedBtn.layer.masksToBounds = YES;
        _selectedBtn.titleLabel.font = [UIFont systemFontOfSize:13];
    }
    return _selectedBtn;
}

- (UILabel *)gifFlag {
    if (!_gifFlag) {
        _gifFlag = [UILabel constructLabel:CGRectZero
                                      text:@"GIF"
                                      font:[UIFont ALBoldFontSize15]
                                 textColor:[UIColor whiteColor]];
        _gifFlag.textAlignment = NSTextAlignmentLeft;
        _gifFlag.hidden = YES;
    }
    return _gifFlag;
}

//- (UIView *)videoFlag {
//    if (!_videoFlag) {
//        _videoFlag = [[UIView alloc] init];
//        _videoFlag.backgroundColor = [UIColor whiteColor];
//        _videoFlag.hidden = YES;
//    }
//    return _videoFlag;
//}

- (UILabel *)videoTimeLabel {
    if (!_videoTimeLabel) {
        _videoTimeLabel = [UILabel constructLabel:CGRectZero
                                             text:nil
                                             font:[UIFont ALFontSize13]
                                        textColor:[UIColor whiteColor]];
        _videoTimeLabel.textAlignment = NSTextAlignmentLeft;
        _videoTimeLabel.backgroundColor = RGBACOLOR(0, 0, 0, 0.3);
        _videoTimeLabel.hidden = YES;
    }
    return _videoTimeLabel;
}

- (void)setPhAsset:(PHAsset *)phAsset {
    _phAsset = phAsset;
    @weakify(self)
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        @strongify(self)
        [phAsset thumbnail:CGSizeMake((SCREEN_WIDTH - 5 * kPadding) / 4, (SCREEN_WIDTH - 5 * kPadding) / 4) resultHandler:^(UIImage *result, NSDictionary *info) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.imageView.image = result;
            });
        }];
    });
    
    NSArray *resources = [PHAssetResource assetResourcesForAsset:phAsset];
    NSString *orgFilename = ((PHAssetResource*)resources[0]).originalFilename;
    self.gifFlag.hidden = ![orgFilename containsString:@"GIF"] && ![orgFilename containsString:@"gif"];
    
    if (phAsset.mediaType == PHAssetMediaTypeVideo) {
//        self.videoFlag.hidden = NO;
        self.videoTimeLabel.hidden = NO;
        int videoTime = floor(phAsset.duration);
        self.videoTimeLabel.text = [NSString stringWithFormat:@" %@",[self convertTimeSecond:videoTime]];
    } else {
//        self.videoFlag.hidden = YES;
        self.videoTimeLabel.hidden = YES;
        self.videoTimeLabel.text = nil;
    }
}

- (NSString *)convertTimeSecond:(NSInteger)timeSecond {
    NSString *theLastTime = nil;
    long second = timeSecond;
    if (timeSecond < 60) {
        theLastTime = [NSString stringWithFormat:@"00:%02zd", second];
    } else if(timeSecond >= 60 && timeSecond < 3600){
        theLastTime = [NSString stringWithFormat:@"%02zd:%02zd", second/60, second%60];
    } else if(timeSecond >= 3600){
        theLastTime = [NSString stringWithFormat:@"%02zd:%02zd:%02zd", second/3600, second%3600/60, second%60];
    }
    return theLastTime;
}


- (void)setIndexPath:(NSIndexPath *)indexPath {
    _indexPath = indexPath;
}
@end
