//
//  YYTextView+Message.m
//  AilloTest
//
//  Created by together on 2019/6/21.
//  Copyright © 2019 With_Dream. All rights reserved.
//

#import "YYTextView+Message.h"

static const char *key = "msg";

@implementation YYTextView (Message)
- (MessageModel *)msg {
    // 根据关联的key，获取关联的值。
    return objc_getAssociatedObject(self, key);
}

- (void)setMsg:(MessageModel *)msg {
     objc_setAssociatedObject(self, key, msg, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
