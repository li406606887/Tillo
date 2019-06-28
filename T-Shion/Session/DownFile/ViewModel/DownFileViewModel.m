//
//  DownFileViewModel.m
//  T-Shion
//
//  Created by together on 2019/2/21.
//  Copyright © 2019年 With_Dream. All rights reserved.
//

#import "DownFileViewModel.h"

@implementation DownFileViewModel
- (void)initialize {
//    @weakify(self)
    [self.downloadFileCommand.executionSignals.switchToLatest subscribeNext:^(id  _Nullable x) {
//       @strongify(self)
        ShowWinMessage(@"下载成功");
        self.state = 1;
        [self.downloadFileSubject sendNext:nil];
    }];
}

- (RACCommand *)downloadFileCommand {
    if (!_downloadFileCommand) {
        _downloadFileCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(id  _Nullable input) {
            return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
                LoadingView(@"下载中");
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    NSError *error;
                    BOOL state = [TSRequest downloadFileWithMessageModel:input error:&error];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        HiddenHUD;
                        if (!error &&state == YES) {
                            [subscriber sendNext:nil];
                        }else {
                            ShowWinMessage(@"下载失败");
                        }
                        [subscriber sendCompleted];
                    });
                });
                return nil;
            }];
        }];
    }
    return _downloadFileCommand;
}

- (void)setMessage:(MessageModel *)message {
    _message = message;
    if ([FMDBManager seletedFileIsSaveWithPath:message]) {
        self.state = 1;
    }else {
        self.state = 0;
    }
}

- (RACSubject *)opernFileSubject {
    if (!_opernFileSubject) {
        _opernFileSubject = [RACSubject subject];
    }
    return _opernFileSubject;
}

- (RACSubject *)downloadFileSubject {
    if (!_downloadFileSubject) {
        _downloadFileSubject = [RACSubject subject];
    }
    return _downloadFileSubject;
}
@end
