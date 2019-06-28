//
//  LookForFileViewModel.h
//  AilloTest
//
//  Created by together on 2019/4/12.
//  Copyright © 2019年 With_Dream. All rights reserved.
//

#import "BaseViewModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface LookForFileViewModel : BaseViewModel
@property (strong, nonatomic) NSMutableArray *assetArray;
@property (strong, nonatomic) NSMutableArray *assetIndexArray;
@property (strong, nonatomic) NSMutableArray *fileArray;
@property (strong, nonatomic) NSMutableArray *fileIndexArray;
@property (strong, nonatomic) RACSubject *refreshTableSubject;
@property (strong, nonatomic) RACSubject *clickAssetSubject;
@property (strong, nonatomic) RACSubject *clickFileSubject;
@property (strong, nonatomic) NSString *roomId;
@property (assign, nonatomic) int type;//1 单聊 其他 群聊
- (NSArray *)messageSortWithArray:(NSArray *)array index:(NSMutableArray *)indexArray;
@end

NS_ASSUME_NONNULL_END
