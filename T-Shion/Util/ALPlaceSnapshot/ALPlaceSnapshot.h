//
//  ALPlaceSnapshot.h
//  T-Shion
//
//  Created by 与梦信息的Mac on 2019/2/28.
//  Copyright © 2019年 With_Dream. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GooglePlaces/GooglePlaces.h>

typedef void(^SnapshotSuccess)(UIImage *Snapshot);

@interface ALPlaceSnapshot : NSObject

+ (ALPlaceSnapshot *)sharedInstance;

- (void)getSnapshotWith:(GMSPlace *)place snapshotCallBack:(SnapshotSuccess)block;

@end
