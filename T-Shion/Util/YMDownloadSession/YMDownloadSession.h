//
//  YMDownloadSession.h
//  YMDownloadSessionDemo
//
//  Created by 与梦信息的Mac on 2019/5/6.
//  Copyright © 2019年 与梦信息技术有限公司. All rights reserved.
//

#ifndef YMDownloadSession_h
#define YMDownloadSession_h

#import "YMDownloader.h"
#import "YMDownloadDB.h"
#import "YMDownloadUtils.h"
#import "YMVideoDownloadManager.h"
#import "YMImageDownloadManager.h"

#ifndef YMDownload_Manager
#if __has_include(<YMDownloadManager.h>)   &&  __has_include(<YMDownloadItem.h>)
#define YMDownload_Manager 1
#import <YMDownloadManager.h>
#elif __has_include("YMDownloadManager.h") &&  __has_include("YMDownloadItem.h")
#define YMDownload_Manager 1
#import "YMDownloadManager.h"
#else
#define YMDownload_Manager 0
#endif
#endif

#endif /* YMDownloadSession_h */
