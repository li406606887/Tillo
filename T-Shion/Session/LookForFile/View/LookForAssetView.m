//
//  LookForAssetView.m
//  AilloTest
//
//  Created by together on 2019/4/12.
//  Copyright © 2019年 With_Dream. All rights reserved.
//

#import "LookForAssetView.h"
#import "LookForCollectionViewCell.h"
#import "LookForFileViewModel.h"

#import "YMImageBrowser.h"
#import "YMVideoBrowseCellData.h"
#import "YMImageBrowseCellData.h"

#define padding 7.5

@interface LookForAssetView ()<UICollectionViewDelegate,UICollectionViewDataSource, YMImageBrowserDataSource>
@property (strong, nonatomic) UICollectionView *collectionView;
@property (strong, nonatomic) LookForFileViewModel *viewModel;

@property (nonatomic, copy) NSArray *imageBrowserArray;
@property (nonatomic, weak) id imageBrowserSourceObject;
@property (nonatomic, assign) NSInteger imageBrowserShowIndex;

@end

@implementation LookForAssetView
- (instancetype)initWithViewModel:(id<BaseViewModelProtocol>)viewModel {
    self.viewModel = (LookForFileViewModel *)viewModel;
    return [super initWithViewModel:viewModel];
}

- (void)setupViews {
    [self addSubview:self.collectionView];
}

- (void)layoutSubviews {
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    [super layoutSubviews];
}

#pragma mark - 图片浏览器相关
- (void)showBrowserWithModel:(MessageModel *)model {
    NSDictionary *dictionary = [FMDBManager selectImageOrVideoWithRoom:model.roomId messageId:model.messageId];
    
    NSArray *array = dictionary.allKeys;
    if (array.count > 0) {
        int index = [[NSString stringWithFormat:@"%@",array[0]] intValue];
        NSArray *dataArray = [dictionary objectForKey:@(index)];
        self.imageBrowserShowIndex = index;
        self.imageBrowserArray = [dataArray copy];
        YMImageBrowser *browser = [[YMImageBrowser alloc] initWithType:YMImageBrowserTypeDefault];
        browser.dataSource = self;
        browser.currentIndex = index;
        [browser show];
    }
}

- (NSUInteger)ym_numberOfCellForImageBrowserView:(YMImageBrowserView *)imageBrowserView {
    return self.imageBrowserArray.count;
}

- (id<YMImageBrowserCellDataProtocol>)ym_imageBrowserView:(YMImageBrowserView *)imageBrowserView dataForCellAtIndex:(NSUInteger)index {
    
    
    MessageModel *message = (MessageModel *)self.imageBrowserArray[index];
    
    if (message.msgType == MESSAGE_IMAGE) {//如果是图片消息
        
        YMImageBrowseCellData *browseCellData = [YMImageBrowseCellData new];
        browseCellData.extraData = message;//直接传入到扩展信息，用于图片加载完成操作
        
        NSString *bigImagePath = [FMDBManager selectBigImageWithMessageModel:message];
        NSString *localImgPath = [[FMDBManager getMessagePathWithMessage:message] stringByAppendingPathComponent:message.fileName];
        
        if (bigImagePath.length > 5) {
            //如果数据库存在大图本地路径
            if (message.fileName.length > 0 && [[NSFileManager defaultManager] fileExistsAtPath:localImgPath]) {
                NSData *localData = [NSData dataWithContentsOfFile:localImgPath];
                
                //如果本地存在大图图片,直接加载本地大图
                browseCellData.imageBlock = ^__kindof UIImage * _Nullable{
                    return [YMImage imageWithData:localData];
                };
            }
            
        } else {
            //预先展示缩略图
            if (message.fileName.length > 0 && [[NSFileManager defaultManager] fileExistsAtPath:localImgPath]) {
                //如果存在本地缩略文件
                NSData *localData = [NSData dataWithContentsOfFile:localImgPath];
                BOOL isGif = [[SDImageGIFCoder sharedCoder] canDecodeFromData:localData];
                if (isGif) {
                    //如果是gif直接打开不需要再次加载
                    browseCellData.imageBlock = ^__kindof UIImage * _Nullable{
                        return [YMImage imageWithData:localData];
                    };
                } else {
                    if (message.isCryptoMessage) {
                        //如果是加密图片则不需要请求网络加载了
                        browseCellData.imageBlock = ^__kindof UIImage * _Nullable{
                            return [YMImage imageWithData:localData];
                        };
                    } else {
                        browseCellData.thumbImage = [UIImage imageWithContentsOfFile:localImgPath];
                    }
                }
            } else {
                //如果不存在本地缩略文件则传缩略文件url
                NSString *thumbString = [NSString ym_thumbImgUrlStringWithMessage:message];
                browseCellData.thumbUrl = [NSURL URLWithString:thumbString];
            }
        }
        
        if (self.imageBrowserShowIndex == index) {
            //该方法赋值为了展示动画过度效果
            browseCellData.sourceObject = self.imageBrowserSourceObject;
        }
        
        NSString *bigImgURLStr = [NSString ym_imageUrlStringWithSourceId:message.sourceId];
        browseCellData.url = [NSURL URLWithString:bigImgURLStr];
        return browseCellData;
    }
    
    else if (message.msgType == MESSAGE_Video) {
        //如果是视频消息
        YMVideoBrowseCellData *browseCellData = [YMVideoBrowseCellData new];
        browseCellData.extraData = message;//直接传入到扩展信息，用于视频加载完成操作
        
        if (self.imageBrowserShowIndex == index) {
            //该方法赋值为了展示动画过度效果
            browseCellData.sourceObject = self.imageBrowserSourceObject;
            browseCellData.isShowIndex = YES;
        }
        
        NSString *firstFramePath = [[FMDBManager getMessagePathWithMessage:message] stringByAppendingPathComponent:message.videoIMGName];
        
        if ([FMDBManager seletedFileIsSaveWithFilePath:firstFramePath] && message.videoIMGName) {
            //如果有第一帧先进行显示
            browseCellData.firstFrame = [UIImage imageWithContentsOfFile:firstFramePath];
        }
        
        NSString *localVideoPath = [[FMDBManager getMessagePathWithMessage:message] stringByAppendingPathComponent:message.fileName];
        
        if (message.fileName.length > 0 && [[NSFileManager defaultManager] fileExistsAtPath:localVideoPath]) {
            //有本地视频直接播放
            browseCellData.url = [NSURL fileURLWithPath:localVideoPath];
        } else {
            //没有本地视频则加载
            browseCellData.url = [NSURL URLWithString:[NSString ym_fileUrlStringWithSourceId:message.sourceId]];
        }
        
        return browseCellData;
    }
    
    return nil;
}


#pragma mark - UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return self.viewModel.assetIndexArray.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    NSArray *array = self.viewModel.assetArray[section];
    return array.count;
}

- (CGFloat) collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 7.5f;
}

-(CGSize)collectionView: (UICollectionView*)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection: (NSInteger)section{
    return CGSizeMake(SCREEN_WIDTH, 30);
}

- (UICollectionReusableView *)collectionView: (UICollectionView*)collectionView viewForSupplementaryElementOfKind: (NSString*)kind atIndexPath: (NSIndexPath*)indexPath {
    if(kind == UICollectionElementKindSectionHeader){
        UICollectionReusableView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"LookForCollectionHeadView" forIndexPath:indexPath];
        for (UIView *view in headerView.subviews) {
            if ([view isKindOfClass:[UILabel class]]) {
                [view removeFromSuperview];
            }
        }
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 30)];
        label.textColor = RGB(153, 153, 153);
        label.text = [NSString stringWithFormat:@"  %@",self.viewModel.assetIndexArray[indexPath.section]];
        [headerView addSubview:label];
        return headerView;
    }
    return nil;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    LookForCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[NSString stringWithUTF8String:object_getClassName([LookForCollectionViewCell class])] forIndexPath:indexPath];
    NSArray *array = self.viewModel.assetArray[indexPath.section];
    cell.message = array[indexPath.row];
    return cell;
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *array = self.viewModel.assetArray[indexPath.section];
    MessageModel *model = array[indexPath.row];
    
    LookForCollectionViewCell *cell = (LookForCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    self.imageBrowserSourceObject = cell.imageView;
    [self showBrowserWithModel:model];
//    [self.viewModel.clickAssetSubject sendNext:model];
}

#pragma mark - getter
- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        CGFloat diameter = (SCREEN_WIDTH-15)/3;
        layout.itemSize = CGSizeMake(diameter, diameter);
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.backgroundColor = RGB(248, 248, 248);
        [_collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"LookForCollectionHeadView"];
        [_collectionView registerClass:[LookForCollectionViewCell class] forCellWithReuseIdentifier:[NSString stringWithUTF8String:object_getClassName([LookForCollectionViewCell class])]];
    }
    return _collectionView;
}
@end
