//
//  TSSoundManager.h
//  T-Shion
//
//  Created by 与梦信息的Mac on 2018/11/26.
//  Copyright © 2018年 With_Dream. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TSSoundManager : NSObject

+ (instancetype)sharedManager;

- (void)playCallerSound;

- (void)playCalleeSound;

- (void)playCloseSound;

- (void)stop;

- (void)stopWithShake;

@end
