//
//  OperMemberView.h
//  T-Shion
//
//  Created by together on 2019/1/21.
//  Copyright © 2019年 With_Dream. All rights reserved.
//

#import "BaseView.h"

NS_ASSUME_NONNULL_BEGIN

@interface OperMemberView : BaseView
@property (strong, nonatomic) BaseTableView *tableView;
@property (strong, nonatomic) UICollectionView *collectionView;
@property (strong, nonatomic) NSMutableArray *memberArray;
- (instancetype)initWithFrame:(CGRect)frame roomId:(NSString *)roomId type:(NSString *)type;
@end

NS_ASSUME_NONNULL_END
