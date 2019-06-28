//
//  EaseFacialView.h
//  T-Shion
//
//  Created by together on 2018/8/22.
//  Copyright © 2018年 With_Dream. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol EaseFacialViewDelegate

@optional
-(void)selectedFacialView:(NSString*)str;
-(void)deleteSelected:(NSString *)str;
-(void)sendFace;
-(void)sendFace:(NSString *)str;

@end

@class EaseEmotionManager;
@interface EaseFacialView : UIView
{
    NSMutableArray *_faces;
}

@property(nonatomic) id<EaseFacialViewDelegate> delegate;

@property(strong, nonatomic, readonly) NSArray *faces;

-(void)loadFacialView:(EaseEmotionManager*)emotionManager size:(CGSize)size;

//-(void)loadFacialView:(int)page size:(CGSize)size;

@end
