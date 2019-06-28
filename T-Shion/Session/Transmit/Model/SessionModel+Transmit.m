//
//  SessionModel+Transmit.m
//  AilloTest
//
//  Created by mac on 2019/2/28.
//  Copyright © 2019年 With_Dream. All rights reserved.
//

#import "SessionModel+Transmit.h"

@implementation SessionModel (Transmit)

- (BOOL)transmitSelected {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

- (void)setTransmitSelected:(BOOL)transmitSelected {
    objc_setAssociatedObject(self, @selector(transmitSelected), @(transmitSelected), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end

@implementation FriendsModel (Transmit)

- (BOOL)transmitSelected {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

- (void)setTransmitSelected:(BOOL)transmitSelected {
    objc_setAssociatedObject(self, @selector(transmitSelected), @(transmitSelected), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)disableSelect {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

- (void)setDisableSelect:(BOOL)disableSelect{
    objc_setAssociatedObject(self, @selector(disableSelect), @(disableSelect), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end

@implementation GroupModel (Transmit)

- (BOOL)transmitSelected {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

- (void)setTransmitSelected:(BOOL)transmitSelected {
    objc_setAssociatedObject(self, @selector(transmitSelected), @(transmitSelected), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)disableSelect {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

- (void)setDisableSelect:(BOOL)disableSelect{
    objc_setAssociatedObject(self, @selector(disableSelect), @(disableSelect), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end

