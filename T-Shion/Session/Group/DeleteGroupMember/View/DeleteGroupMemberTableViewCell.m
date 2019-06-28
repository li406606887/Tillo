//
//  DeleteGroupMemberTableViewCell.m
//  T-Shion
//
//  Created by together on 2018/8/10.
//  Copyright © 2018年 With_Dream. All rights reserved.
//

#import "DeleteGroupMemberTableViewCell.h"
#import "MemberModel.h"

@implementation DeleteGroupMemberTableViewCell

- (void)setupViews {
    [self.contentView addSubview:self.icon];
    [self.contentView addSubview:self.name];    
}

- (void)setMember:(MemberModel *)member {
    [super setMember:member];
    self.icon.image = nil;
    self.name.text = member.name;
    NSString *imagePath = [TShionSingleCase thumbAvatarImgPathWithUserId:member.userId];
    [TShionSingleCase loadingAvatarWithImageView:self.icon url:[NSString ym_thumbAvatarUrlStringWithOriginalString:member.avatar] filePath:imagePath];
    
}

@end
