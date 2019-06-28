//
//  EaseFaceView.h
//  T-Shion
//
//  Created by together on 2018/8/22.
//  Copyright © 2018年 With_Dream. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol EMFaceDelegate
@required
- (void)selectedFaceWithEmoji:(NSString *)emoji;
- (void)deleteFace;
@end

@interface EaseFaceView : UIView
@property (nonatomic, assign) id<EMFaceDelegate> delegate;
@end
