//
//  EMTextAttachment.h
//  T-Shion
//
//  Created by together on 2018/8/22.
//  Copyright © 2018年 With_Dream. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EaseEmotionEscape : NSObject

+(NSMutableAttributedString *) attributtedStringFromText:(NSString *) aInputText;

+(NSAttributedString *) attStringFromTextForChatting:(NSString *) aInputText;

+(NSAttributedString *) attStringFromTextForInputView:(NSString *) aInputText;

@end

@interface EMTextAttachment : NSTextAttachment

@property(nonatomic, strong) NSString *imageName;

@end
