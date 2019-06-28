//
//  ALDocumentPickerViewController.h
//  T-Shion
//
//  Created by 与梦信息的Mac on 2019/2/12.
//  Copyright © 2019年 With_Dream. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ALDocumentPickerViewController : UIDocumentPickerViewController

+ (ALDocumentPickerViewController *)config;

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithURL:(NSURL *)url inMode:(UIDocumentPickerMode)mode NS_UNAVAILABLE;
- (instancetype)initWithURLs:(NSArray<NSURL *> *)urls inMode:(UIDocumentPickerMode)mode NS_UNAVAILABLE;

@end

