//
//  LookImageDetailsView.h
//  T-Shion
//
//  Created by together on 2018/12/26.
//  Copyright © 2018年 With_Dream. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface LookImageDetailsView : UIView
/** collectionView */
@property(nonatomic, strong) UICollectionView *collectionView;

- (instancetype)initWithFrame:(CGRect)frame array:(NSArray *)photosArr currentIndex:(NSInteger)currentIndex;
@end

NS_ASSUME_NONNULL_END
