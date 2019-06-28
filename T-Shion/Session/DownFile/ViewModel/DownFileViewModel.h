//
//  DownFileViewModel.h
//  T-Shion
//
//  Created by together on 2019/2/21.
//  Copyright © 2019年 With_Dream. All rights reserved.
//

#import "BaseViewModel.h"

@class MessageModel;

NS_ASSUME_NONNULL_BEGIN

@interface DownFileViewModel : BaseViewModel
@property (strong, nonatomic) MessageModel *message;
@property (strong, nonatomic) RACCommand *downloadFileCommand;
@property (strong, nonatomic) RACSubject *opernFileSubject;
@property (strong, nonatomic) RACSubject *downloadFileSubject;
@property (assign, nonatomic) int state;//文件下载状态;
@end

NS_ASSUME_NONNULL_END
