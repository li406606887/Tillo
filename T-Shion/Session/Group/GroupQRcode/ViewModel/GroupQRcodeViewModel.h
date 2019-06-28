//
//  GroupQRcodeViewModel.h
//  AilloTest
//
//  Created by together on 2019/4/18.
//  Copyright © 2019年 With_Dream. All rights reserved.
//

#import "BaseViewModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface GroupQRcodeViewModel : BaseViewModel
@property (weak, nonatomic) GroupModel *group;
@property (strong, nonatomic) RACCommand *getQrcodeCommand;
@property (strong, nonatomic) RACSubject *refreshQrcodeSubject;
@end

NS_ASSUME_NONNULL_END
