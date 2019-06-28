//
//  WebLinkView.h
//  AilloTest
//
//  Created by together on 2019/2/12.
//  Copyright © 2019年 With_Dream. All rights reserved.
//

#import "BaseView.h"

NS_ASSUME_NONNULL_BEGIN

@interface WebLinkView : BaseView
@property (strong, nonatomic) NSURL *url;
@property (copy, nonatomic) void (^changeTitleBlock) (NSString *title);
@end

NS_ASSUME_NONNULL_END
