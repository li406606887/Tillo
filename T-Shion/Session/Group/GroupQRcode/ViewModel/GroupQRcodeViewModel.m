//
//  GroupQRcodeViewModel.m
//  AilloTest
//
//  Created by together on 2019/4/18.
//  Copyright © 2019年 With_Dream. All rights reserved.
//

#import "GroupQRcodeViewModel.h"
#import "ZXingObjC.h"

@implementation GroupQRcodeViewModel
- (void)initialize {
    @weakify(self)
    [self.getQrcodeCommand.executionSignals.switchToLatest subscribeNext:^(id  _Nullable x) {
        @strongify(self)
        NSString *url = [NSString stringWithFormat:@"%@%@%@",x[@"urlHead"],GroupCodeUrl,x[@"uri"]];
        UIImage *image = [self creatQrcodeWithString:url];
        [self.refreshQrcodeSubject sendNext:image];
    }];
}

- (RACCommand *)getQrcodeCommand {
    if (!_getQrcodeCommand) {
        _getQrcodeCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(id  _Nullable input) {
            return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    NSError *error;
                    RequestModel *model = [TSRequest getRequetWithApi:api_get_groupQrCode withParam:input error:&error];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (error == nil) {
                            [subscriber sendNext:model.data];
                        }else {
                            if (model.message.length>0) {
                                ShowWinMessage(model.message);
                            }
                        }
                        [subscriber sendCompleted];
                    });
                });
                return nil;
            }];
        }];
    }
    return _getQrcodeCommand;
}

- (UIImage *)creatQrcodeWithString:(NSString *)string {
    ZXMultiFormatWriter *writer = [[ZXMultiFormatWriter alloc] init];
    ZXEncodeHints *hints = [ZXEncodeHints hints];
    hints.margin = @(0);
    ZXBitMatrix *result = [writer encode:string
                                  format:kBarcodeFormatQRCode
                                   width:SCREEN_WIDTH
                                  height:SCREEN_WIDTH
                                   hints:hints
                                   error:nil];
    
    if (result) {
        ZXImage *image = [ZXImage imageWithMatrix:result];
        return [UIImage imageWithCGImage:image.cgimage];
    }
    return nil;
}

- (RACSubject *)refreshQrcodeSubject {
    if (!_refreshQrcodeSubject) {
        _refreshQrcodeSubject = [RACSubject subject];
    }
    return _refreshQrcodeSubject;
}
@end
