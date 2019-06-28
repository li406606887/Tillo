//
//  LookForCollectionViewCell.h
//  T-Shion
//
//  Created by together on 2019/4/15.
//  Copyright © 2019年 With_Dream. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface LookForCollectionViewCell : UICollectionViewCell
@property (strong, nonatomic) SDAnimatedImageView *imageView;
@property (weak, nonatomic) MessageModel *message;
@end

NS_ASSUME_NONNULL_END
