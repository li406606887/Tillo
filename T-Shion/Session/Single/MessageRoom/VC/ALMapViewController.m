//
//  ALMapViewController.m
//  T-Shion
//
//  Created by 与梦信息的Mac on 2019/3/6.
//  Copyright © 2019年 With_Dream. All rights reserved.
//

#import "ALMapViewController.h"
#import <GoogleMaps/GoogleMaps.h>
#import "UIView+BorderLine.h"

@interface ALMapViewController ()<GMSMapViewDelegate>

@property (nonatomic, strong) NSDictionary *placeData;
@property (nonatomic, strong) GMSMapView *mapView;

@property (nonatomic, strong) GMSMarker *userMarker;
@property (nonatomic, strong) GMSMarker *targetMarker;

@property (nonatomic, assign) BOOL firstLocationUpdate;
@property (nonatomic, strong) NSMutableArray *markers;

@property (nonatomic, strong) UIButton *bottomBtn;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *detailLabel;
@property (nonatomic, strong) UIImageView *arrowView;

@end

@implementation ALMapViewController

- (instancetype)initWithMessage:(MessageModel *)msgModel {
    if (self = [super init]) {
        _placeData = [msgModel.locationInfo mj_JSONObject];
    }
    return self;
}

- (void)dealloc {
    [_mapView removeObserver:self
                  forKeyPath:@"myLocation"
                     context:NULL];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"位置";
    self.view = self.mapView;
    [self.view addSubview:self.bottomBtn];
    [self.bottomBtn addSubview:self.titleLabel];
    [self.bottomBtn addSubview:self.detailLabel];
    [self.bottomBtn addSubview:self.arrowView];
    
    [self.mapView addObserver:self
               forKeyPath:@"myLocation"
                  options:NSKeyValueObservingOptionNew
                  context:NULL];

    @weakify(self)
    dispatch_async(dispatch_get_main_queue(), ^{
        @strongify(self)
        self.mapView.myLocationEnabled = YES;
    });
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [self.bottomBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.mas_left);
        make.right.equalTo(self.view.mas_right);
        make.bottom.equalTo(self.view.mas_bottom);
        make.height.mas_equalTo(70);
    }];
    
    [self.arrowView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.bottomBtn.mas_right).with.offset(-25);
        make.centerY.equalTo(self.bottomBtn.mas_centerY);
        make.size.mas_equalTo(CGSizeMake(50, 50));
    }];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.bottomBtn.mas_centerY).with.offset(-3);
        make.right.equalTo(self.arrowView.mas_left).with.offset(-15);
        make.left.equalTo(self.bottomBtn.mas_left).with.offset(20);
    }];
    
    [self.detailLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.bottomBtn.mas_centerY).with.offset(3);
        make.right.equalTo(self.arrowView.mas_left).with.offset(-15);
        make.left.equalTo(self.bottomBtn.mas_left).with.offset(20);
    }];
}

#pragma mark - KVO updates
- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    CLLocation *location = [change objectForKey:NSKeyValueChangeNewKey];
    self.userMarker.position = location.coordinate;
    
//    if (!_firstLocationUpdate) {
//        //第一次进入根据用户位置和所选取位置进行居中显示
//        _firstLocationUpdate = YES;
//        [self.markers addObject:self.userMarker];
//
//        CLLocationCoordinate2D firstPos = ((GMSMarker *)_markers.firstObject).position;
//        GMSCoordinateBounds *bounds =
//        [[GMSCoordinateBounds alloc] initWithCoordinate:firstPos coordinate:firstPos];
//        for (GMSMarker *marker in _markers) {
//            bounds = [bounds includingCoordinate:marker.position];
//        }
//        GMSCameraUpdate *update = [GMSCameraUpdate fitBounds:bounds withPadding:120.0f];
//        [_mapView moveCamera:update];
//    }
}

- (void)showMapListAction {
    UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"Google 地图" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"comgooglemaps://"]]) {
            
            NSString *urlString = [[NSString stringWithFormat:@"comgooglemaps://?x-source=%@&x-success=%@&saddr=&daddr=%@,%@&directionsmode=driving",@"导航测试",@"nav123456",@(self.targetMarker.position.latitude), @(self.targetMarker.position.longitude)] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
            
        } else {
            ShowWinMessage(@"请先安装谷歌地图");
        }
    }];
    
    UIAlertAction *action2 = [UIAlertAction actionWithTitle:@"Apple 地图" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        //用户位置
        MKMapItem *currentLoc = [MKMapItem mapItemForCurrentLocation];
        //终点位置
        MKMapItem *toLocation = [[MKMapItem alloc] initWithPlacemark:[[MKPlacemark alloc] initWithCoordinate:self.targetMarker.position addressDictionary:nil]];
        toLocation.name = self.targetMarker.title;
        
        NSArray *items = @[currentLoc,toLocation];
        
        NSDictionary *dic = @{
                              MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving,
                              MKLaunchOptionsMapTypeKey : @(MKMapTypeStandard),
                              MKLaunchOptionsShowsTrafficKey : @(YES)
                              };
        
        [MKMapItem openMapsWithItems:items launchOptions:dic];
    }];
    
    UIAlertAction *action3 = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];

    [action1 setValue:[UIColor ALTextDarkColor] forKey:@"titleTextColor"];
    [action2 setValue:[UIColor ALTextDarkColor] forKey:@"titleTextColor"];
    [action3 setValue:[UIColor ALBlueColor] forKey:@"titleTextColor"];
    
    [actionSheet addAction:action1];
    [actionSheet addAction:action2];
    [actionSheet addAction:action3];

    [self presentViewController:actionSheet animated:YES completion:nil];
}


#pragma mark - getter
- (GMSMapView *)mapView {
    if (!_mapView) {
        GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:[self.placeData[@"latitude"] doubleValue]
                                                                longitude:[self.placeData[@"longitude"] doubleValue]
                                                                     zoom:16];
        
        _mapView = [GMSMapView mapWithFrame:CGRectZero camera:camera];
        _mapView.delegate = self;
        _mapView.settings.compassButton = YES;
        _mapView.settings.myLocationButton = YES;
        
        _mapView.padding = UIEdgeInsetsMake(0, 0, 70, 0);
        
        self.targetMarker.map = _mapView;
        [self.markers addObject:self.targetMarker];
    }
    return _mapView;
}

- (GMSMarker *)targetMarker {
    if (!_targetMarker) {
        _targetMarker = [[GMSMarker alloc] init];
        _targetMarker.position = CLLocationCoordinate2DMake([self.placeData[@"latitude"] doubleValue], [self.placeData[@"longitude"] doubleValue]);
        _targetMarker.title = self.placeData[@"name"];
        _targetMarker.snippet = self.placeData[@"address"];
//        _targetMarker.icon = [UIImage imageNamed:@"public_map_marker"];
    }
    return _targetMarker;
}

- (GMSMarker *)userMarker {
    if (!_userMarker) {
        _userMarker = [[GMSMarker alloc] init];
    }
    return _userMarker;
}

- (UIButton *)bottomBtn {
    if (!_bottomBtn) {
        _bottomBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_bottomBtn setBackgroundImage:[UIImage imageWithColor:[UIColor whiteColor]] forState:UIControlStateNormal];
        [_bottomBtn setBackgroundImage:[UIImage imageWithColor:[UIColor ALBtnGrayColor]] forState:UIControlStateHighlighted];
        _bottomBtn.borderLineColor = [UIColor ALLineColor].CGColor;
        _bottomBtn.borderLineStyle = BorderLineStyleTop;
        _bottomBtn.borderLineWidth = 0.5;
        [_bottomBtn addTarget:self action:@selector(showMapListAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _bottomBtn;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [UILabel constructLabel:CGRectZero
                                         text:nil
                                         font:[UIFont ALBoldFontSize18]
                                    textColor:[UIColor ALTextDarkColor]];
        _titleLabel.textAlignment = NSTextAlignmentLeft;
        
        NSString *title = self.placeData[@"name"];
        title = title.length > 0 ? title : @"[位置]";
        _titleLabel.text = title;
    }
    return _titleLabel;
}

- (UILabel *)detailLabel {
    if (!_detailLabel) {
        _detailLabel = [UILabel constructLabel:CGRectZero
                                          text:nil
                                          font:[UIFont ALFontSize14]
                                     textColor:[UIColor ALTextGrayColor]];
        _detailLabel.textAlignment = NSTextAlignmentLeft;
        
        NSString *detail = self.placeData[@"address"];
        detail = detail.length > 0 ? detail : @"";
        _detailLabel.text = detail;
    }
    return _detailLabel;
}

- (UIImageView *)arrowView {
    if (!_arrowView) {
        _arrowView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"public_map_arrow_left"]];
    }
    return _arrowView;
}

- (NSMutableArray *)markers {
    if (!_markers) {
        _markers = [NSMutableArray array];
    }
    return _markers;
}

@end
