//
//  TransmitRecentlyView.h
//  T-Shion
//
//  Created by mac on 2019/2/27.
//  Copyright © 2019年 With_Dream. All rights reserved.
//

#import "BaseView.h"
#import "TransmitViewModel.h"

@interface TransmitView : BaseView

- (instancetype)initWithViewModel:(id<BaseViewModelProtocol>)viewModel type:(TransmitViewType)type;
@end


