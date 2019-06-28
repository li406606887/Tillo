//
//  FriendsTableViewCell+SessionModel.m
//  T-Shion
//
//  Created by mac on 2019/2/27.
//  Copyright © 2019年 With_Dream. All rights reserved.
//

#import "CreatGroupTableViewCell+GroupModel.h"
#import "NSString+Storage.h"

@implementation CreatGroupTableViewCell (GroupModel)

- (GroupModel *)group
{
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setGroup:(GroupModel *)group {
    objc_setAssociatedObject(self, @selector(group), group, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    self.name.text = group.name;
    NSString *imagePath = [[[TShionSingleCase doucumentPath] stringByAppendingPathComponent:@"Head"] stringByAppendingPathComponent:[NSString stringWithFormat:@"head_%@.jpg",group.roomId]];
    [TShionSingleCase loadingAvatarWithImageView:self.icon url:group.avatar filePath:imagePath placeHolder:[UIImage imageNamed:@"Group_Deafult_Avatar"]];
    
}

@end

@implementation OperMemberCollectionCell (GroupModel)

- (GroupModel *)group
{
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setGroup:(GroupModel *)group {
    objc_setAssociatedObject(self, @selector(group), group, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    self.nameLabel.text = group.name;
    NSString *imagePath = [[[TShionSingleCase doucumentPath] stringByAppendingPathComponent:@"Head"] stringByAppendingPathComponent:[NSString stringWithFormat:@"head_%@.jpg",group.roomId]];
    [TShionSingleCase loadingAvatarWithImageView:self.headIcon url:group.avatar filePath:imagePath placeHolder:[UIImage imageNamed:@"Group_Deafult_Avatar"]];
}

@end



