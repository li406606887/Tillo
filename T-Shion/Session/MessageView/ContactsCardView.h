//
//  ContactsCardView.h
//  AilloTest
//
//  Created by together on 2019/6/12.
//  Copyright © 2019 With_Dream. All rights reserved.
//

#import "MessageBaseView.h"

NS_ASSUME_NONNULL_BEGIN

@interface ContactsCardView : MessageBaseView
@property (copy, nonatomic) void (^clickBlcok) (id data,int type);//type 1发送消息 2 加好友
@end

NS_ASSUME_NONNULL_END
