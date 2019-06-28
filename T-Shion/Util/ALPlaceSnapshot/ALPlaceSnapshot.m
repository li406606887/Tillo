//
//  ALPlaceSnapshot.m
//  T-Shion
//
//  Created by 与梦信息的Mac on 2019/2/28.
//  Copyright © 2019年 With_Dream. All rights reserved.
//

#import "ALPlaceSnapshot.h"
#import <GoogleMaps/GoogleMaps.h>

@interface ALPlaceSnapshot ()<GMSMapViewDelegate>

@property (nonatomic, strong) GMSMapView *mapView;
@property (nonatomic, copy) SnapshotSuccess successBlock;

@end

static ALPlaceSnapshot *manager;

@implementation ALPlaceSnapshot

+ (ALPlaceSnapshot *)sharedInstance {
    static dispatch_once_t once;
    
    dispatch_once(&once, ^{
        manager = [[ALPlaceSnapshot alloc] init];
    });
    return manager;
}

- (void)getSnapshotWith:(GMSPlace *)place snapshotCallBack:(SnapshotSuccess)block {
   
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:place.coordinate.latitude
                                                            longitude:place.coordinate.longitude
                                                                 zoom:16];
    
    self.mapView.camera = camera;
    
    GMSMarker *marker = [[GMSMarker alloc] init];
    marker.position = place.coordinate;
//    marker.icon = [UIImage imageNamed:@"public_map_marker"];
    marker.map = self.mapView;
    
    UIViewController *topViewVC = (UIViewController *)[SocketViewModel getTopViewController];
    [topViewVC.view insertSubview:self.mapView atIndex:0];
    self.successBlock = block;
}

#pragma mark - GMSMapViewDelegate
//可以截图的时候才截图
- (void)mapViewSnapshotReady:(GMSMapView *)mapView {
    //获取截图
    UIGraphicsBeginImageContextWithOptions(mapView.bounds.size, YES, 0);
    [mapView drawViewHierarchyInRect:mapView.bounds afterScreenUpdates:YES];
    UIImage *mapSnapShot = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    if (self.successBlock) {
        self.successBlock(mapSnapShot);
    }
    [self.mapView removeFromSuperview];
    self.mapView = nil;
}

#pragma mark - getter
- (GMSMapView *)mapView {
    if (!_mapView) {
        _mapView = [[GMSMapView alloc] initWithFrame:CGRectMake(0, 0, 300, 150)];
        _mapView.delegate = self;
    }
    return _mapView;
}


@end
