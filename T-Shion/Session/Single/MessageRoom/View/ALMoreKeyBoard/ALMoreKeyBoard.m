//
//  ALMoreKeyBoard.m
//  T-Shion
//
//  Created by 与梦信息的Mac on 2019/2/27.
//  Copyright © 2019年 With_Dream. All rights reserved.
//

#import "ALMoreKeyBoard.h"
#import "ALMoreKeyBoardCell.h"
#import "ALMoreKeyboardItem.h"

@interface ALMoreKeyBoard ()<UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSMutableArray *chatMoreKeyboardData;

@end

@implementation ALMoreKeyBoard

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self addSubview:self.collectionView];
    }
    return self;
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.chatMoreKeyboardData.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ALMoreKeyBoardCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ALMoreKeyBoardCell" forIndexPath:indexPath];
    cell.item = self.chatMoreKeyboardData[indexPath.row];
    __weak typeof(self) weakSelf = self;
    [cell setClickBlock:^(ALMoreKeyboardItem *sItem) {
        if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(moreKeyboard:didSelectedFunctionItem:)]) {
            [weakSelf.delegate moreKeyboard:weakSelf didSelectedFunctionItem:sItem];
        }
    }];
    return cell;
}

#pragma mark - UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(55, 80);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 25;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 10;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(0, 20, 0, 20);
}


#pragma mark - getter
- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        [layout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
        _collectionView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:layout];
        [_collectionView setBackgroundColor:[UIColor clearColor]];
        [_collectionView setPagingEnabled:YES];
        [_collectionView setDataSource:self];
        [_collectionView setDelegate:self];
        [_collectionView setShowsHorizontalScrollIndicator:NO];
        [_collectionView setShowsHorizontalScrollIndicator:NO];
        [_collectionView setScrollsToTop:NO];
        
        [_collectionView registerClass:[ALMoreKeyBoardCell class] forCellWithReuseIdentifier:@"ALMoreKeyBoardCell"];
    }
    return _collectionView;
}

- (NSMutableArray *)chatMoreKeyboardData {
    if (!_chatMoreKeyboardData) {
        _chatMoreKeyboardData = [NSMutableArray arrayWithCapacity:0];
        
        ALMoreKeyboardItem *fileItem = [ALMoreKeyboardItem createByType:ALMoreKeyboardItemTypeFile
                                                                  title:Localized(@"file")
                                                               imagePath:@"keyboard_more_file"];
        
        ALMoreKeyboardItem *positionItem = [ALMoreKeyboardItem createByType:ALMoreKeyboardItemTypePosition
                                                                      title:Localized(@"location")
                                                              imagePath:@"keyboard_more_position"];
        
        ALMoreKeyboardItem *cardItem = [ALMoreKeyboardItem createByType:ALMoreKeyboardItemTypeCard
                                                                      title:Localized(@"card")
                                                                  imagePath:@"keyboard_more_card"];
        [_chatMoreKeyboardData addObjectsFromArray:@[fileItem, positionItem,cardItem]];
    }
    return _chatMoreKeyboardData;
}


@end
