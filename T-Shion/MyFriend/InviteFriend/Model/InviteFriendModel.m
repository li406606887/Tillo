//
//  InviteFriendModel.m
//  T-Shion
//
//  Created by together on 2018/12/20.
//  Copyright © 2018年 With_Dream. All rights reserved.
//

#import "InviteFriendModel.h"

@implementation InviteFriendModel


- (void)setFamilyName:(NSString *)familyName {
    _familyName = familyName;
    if (familyName.length>0) {
        _letter = [NSString getStringFirstLetterWithString:familyName];
    }
}

- (void)setGivenName:(NSString *)givenName {
    _givenName = givenName;
    if (givenName.length>0) {
        if (!self.letter) {
            _letter = [NSString getStringFirstLetterWithString:givenName];
        }
    }
}
@end
