//
//  MCPanoramaAlbumView.m
//  StreetScapeFramework
//
//  Created by Captain Stanley on 16/3/8.
//  Copyright © 2016年 map.baidu. All rights reserved.
//

#import "MCPanoramaAlbumView.h"
#import "MCPanoramaAlbumCell.h"
#import "MCPanoramaCategoryCell.h"
//#import "BaiduPanoDataFetcher.h"
#import <BaiduPanoSDK/BaiduPanoramaView.h>
#import <BaiduPanoSDK/BaiduLocationPanoData.h>
#import <BaiduPanoSDK/BaiduPanoDataFetcher.h>
#import <BaiduPanoSDK/BaiduPanoImageOverlay.h>
#import <BaiduPanoSDK/BaiduPanoLabelOverlay.h>
#import <BaiduPanoSDK/BaiduPanoOverlay.h>
#import <BaiduPanoSDK/BaiduPanoUtils.h>
#import <BaiduPanoSDK/BaiduPanoData.h>
#import "MCPanoramaGuideModel.h"

#define kExtendAlbumHeight (106)
#define kNormalAlbumHeight (76)
#define kCategoryHeight    (30)
#define kImageWidth        (60)
#define kAlbumNameHeight   (32)

static NSString *albumCellIdentifier = @"albumCell";
static NSString *categoryCellIdentifier = @"categoryCell";
static const char * kIndoorAlbumQueue = "com.baidu.mcpanorama.indoor";
static const NSString * kPhotoBaseUrl = @"https://sv.map.baidu.com/scape/?qt=pdata&sid=";

@interface MCPanoramaAlbumView ()<UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) MCPanoramaGuideModel *guideModel;
@property (nonatomic, strong) NSMutableArray<NSMutableArray *> *categoryArray;
@property (nonatomic, strong) NSMutableArray *categoryNameArray;
@property (nonatomic, strong) NSMutableDictionary *pidToCategoryDictionary;

@property (nonatomic, strong) UILabel *nameLabel;   //图片控件名称
@property (nonatomic, strong) UIView *container;    //相册与类型的父容器，主要为解决背景颜色问题
@property (nonatomic, strong) UICollectionView *categoryCollectionView;     //相册分类信息的容器
@property (nonatomic, strong) UICollectionView *albumCollectionView;        //图片的容器
@property (nonatomic, strong) UILabel *line;

@property (nonatomic, assign) int defaultStartAblumIndex;
@property (nonatomic, assign) int selectedCategoryIndex;
@property (nonatomic, assign) int selectedAlbumIndex;

@property (nonatomic, copy) NSString *exitUid;
@property (nonatomic, copy) NSString *curPid;   //记录当前场景的Pid

@end


@implementation MCPanoramaAlbumView

- (id)init {
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.clipsToBounds = YES;
        [self initNameLabel];
        [self initContainer];
    }
    
    return self;
}

- (void)initNameLabel {
    self.nameLabel = [[UILabel alloc] init];
    self.nameLabel.backgroundColor = [UIColor clearColor];
    self.nameLabel.font = [UIFont systemFontOfSize:16.0f];
    self.nameLabel.textColor = [UIColor whiteColor];
    self.nameLabel.textAlignment = NSTextAlignmentCenter;
    self.nameLabel.layer.shadowOpacity = 0.6;
    self.nameLabel.layer.shadowOffset = CGSizeMake(0, 1.5f);
    self.nameLabel.layer.shadowColor = [UIColor blackColor].CGColor;
    [self addSubview:self.nameLabel];
    
}

- (void)initContainer {
    self.container = [[UIView alloc] init];
    self.container.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.6];
    [self addSubview:self.container];
    
    [self initCategory];
    [self initAlbum];
}

- (void)initCategory {
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    //等数据返回后再正真的初始化
    self.categoryCollectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    self.categoryCollectionView.showsHorizontalScrollIndicator = NO;
    self.categoryCollectionView.scrollEnabled = NO;
    self.categoryCollectionView.alwaysBounceHorizontal = NO;
    self.categoryCollectionView.delegate = self;
    self.categoryCollectionView.dataSource = self;
    [self.categoryCollectionView registerClass:[MCPanoramaCategoryCell class] forCellWithReuseIdentifier:categoryCellIdentifier];
    [self.container addSubview:self.categoryCollectionView];
    self.categoryCollectionView.backgroundColor = [UIColor clearColor];
    
    self.line = [[UILabel alloc] initWithFrame:CGRectZero];
    self.line.backgroundColor = [UIColor lightGrayColor];
    [self.container addSubview:self.line];
}

- (void)initAlbum {
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    //等数据返回后再正真的初始化
    self.albumCollectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    self.albumCollectionView.showsHorizontalScrollIndicator = NO;
    self.albumCollectionView.scrollEnabled = YES;
    self.albumCollectionView.alwaysBounceHorizontal = YES;
    self.albumCollectionView.delegate = self;
    self.albumCollectionView.dataSource = self;
    [self.albumCollectionView registerClass:[MCPanoramaAlbumCell class] forCellWithReuseIdentifier:albumCellIdentifier];
    [self.container addSubview:self.albumCollectionView];
    self.albumCollectionView.backgroundColor = [UIColor clearColor];
}

- (void)showAlbumWithParams:(BaiduPoiPanoData *)data inFrame:(CGRect)frame{
    __weak __typeof(self) weakSelf = self;
    dispatch_async(dispatch_queue_create(kIndoorAlbumQueue, DISPATCH_QUEUE_SERIAL), ^{
        __strong __typeof(self) strongSelf = weakSelf;
        
        strongSelf.exitUid = data.uid;
        
        strongSelf.curPid = data.pid;    //使用当前全景pid
        if (!strongSelf.curPid.length) {
            return;
        }
        
        NSString *jsonString = [BaiduPanoDataFetcher requestPanoramaRecommendationServiceDataWithPid:strongSelf.curPid];
        strongSelf.guideModel = [[MCPanoramaGuideModel alloc] initWithString:jsonString error:nil];
        [strongSelf parseGuideData];
        
        strongSelf.selectedCategoryIndex = 0;
        strongSelf.selectedAlbumIndex = strongSelf.defaultStartAblumIndex;
        if (strongSelf.categoryArray.count == 0) {
            return;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            if (strongSelf.categoryNameArray.count > 1) {
                //有分类信息
                strongSelf.frame = CGRectMake(0, frame.size.height - kExtendAlbumHeight - kAlbumNameHeight, frame.size.width, kExtendAlbumHeight + kAlbumNameHeight);
                strongSelf.container.frame = CGRectMake(0, kAlbumNameHeight, frame.size.width, kExtendAlbumHeight);
                strongSelf.categoryCollectionView.frame = CGRectMake(0, 0, frame.size.width, kCategoryHeight);
                strongSelf.categoryCollectionView.contentOffset = CGPointZero;
                [strongSelf.categoryCollectionView reloadData];
                strongSelf.line.frame = CGRectMake(0, kCategoryHeight - 0.5f, frame.size.width, 0.5f);
            } else {
                strongSelf.frame = CGRectMake(0, frame.size.height - kNormalAlbumHeight - kAlbumNameHeight, frame.size.width, kNormalAlbumHeight + kAlbumNameHeight);
                strongSelf.container.frame = CGRectMake(0, kAlbumNameHeight, frame.size.width, kNormalAlbumHeight);
                strongSelf.categoryCollectionView.frame = CGRectZero;
                strongSelf.categoryCollectionView.contentOffset = CGPointZero;
                [strongSelf.categoryCollectionView reloadData];
            }
            strongSelf.albumCollectionView.frame = CGRectMake(0, strongSelf.container.frame.size.height - kNormalAlbumHeight, frame.size.width, kNormalAlbumHeight);
            strongSelf.albumCollectionView.contentOffset = CGPointZero;
            [strongSelf.albumCollectionView reloadData];
            [strongSelf setAlbumHighlightAtPid:strongSelf.curPid];
//            [strongSelf updateNameLabel];
        });
    });
    
}

#pragma mark - Parse Guide Data
- (void)parseGuideData{
    if (!self.guideModel || !self.guideModel.content) {
        return;
    }
    self.categoryArray = [NSMutableArray array];
    self.categoryNameArray = [NSMutableArray array];
    self.pidToCategoryDictionary = [NSMutableDictionary dictionary];
    self.defaultStartAblumIndex = 0;
    BOOL isClassifiedByCategory = NO;
    
    NSMutableSet *knownCategorySet = [NSMutableSet set];    //保存已遍历到的类型
    NSMutableSet *knownFloorSet = [NSMutableSet set];       //保存已遍历到的楼层
    for (MCPanoramaGuideContentModel *model in self.guideModel.content) {
        if (model.Type == 3) {
            //有出口则defaultStartAblumIndex = 1，否则为0
            self.defaultStartAblumIndex = 1;
        }
        if (model.Catalog) {
            if (model.Catalog.length > 0) {
                isClassifiedByCategory = YES;
            }
            if (![knownCategorySet containsObject:@([model categoryIndex])]) {
                [knownCategorySet addObject:@([model categoryIndex])];
            }
        }
        if (model.Floor) {
            if (![knownFloorSet containsObject:model.Floor]) {
                [knownFloorSet addObject:model.Floor];
            }
        }
        
    }
    
    NSArray *sortedCategoryIndexArray = [[knownCategorySet allObjects] sortedArrayUsingSelector:@selector(compare:)];
    NSArray *sortedFloorArray = [[knownFloorSet allObjects] sortedArrayUsingSelector:@selector(compare:)];
    
    NSMutableDictionary *categoryNameToIndexMap = [NSMutableDictionary dictionary]; //保存分类名称到数组下表的映射关系
    
    if (isClassifiedByCategory) {
        //按Category分类
        for (int i=0; i<sortedCategoryIndexArray.count; i++) {
            NSMutableArray *tempArray = [NSMutableArray array];
            [self.categoryArray addObject:tempArray];
            NSString *name = [MCPanoramaGuideContentModel categoryNameForIndex:[sortedCategoryIndexArray[i] intValue]];
            [categoryNameToIndexMap setObject:@(i) forKey:name];
            [self.categoryNameArray addObject:name];
        }
    } else {
        //按楼层分类
        for (int i=0; i<sortedFloorArray.count; i++) {
            NSMutableArray *tempArray = [NSMutableArray array];
            [self.categoryArray addObject:tempArray];
            NSString *name = [MCPanoramaGuideContentModel floorNameForIndex:[sortedFloorArray[i] intValue]];
            [categoryNameToIndexMap setObject:@(i) forKey:name];
            [self.categoryNameArray addObject:name];
        }
    }
    
    if (self.categoryArray.count == 0) {
        //无分类，无楼层
        return;
    }
    
    for (MCPanoramaGuideContentModel *model in self.guideModel.content) {
        if (model.Type != 3 && model.Type != 6 && model.Type != 2) {
            //不是出口、道路之类
            if (isClassifiedByCategory) {
                //按Category分类
                int index = [[categoryNameToIndexMap objectForKey:[model categoryName]] intValue];
                [[self.categoryArray objectAtIndex:index] addObject:model];
                [self.pidToCategoryDictionary setObject:[model categoryName] forKey:model.PID];
            } else {
                //按楼层分类
                int index = [[categoryNameToIndexMap objectForKey:[model floorName]] intValue];
                [[self.categoryArray objectAtIndex:index] addObject:model];
                [self.pidToCategoryDictionary setObject:[model floorName] forKey:model.PID];
            }
        } else if (model.Type == 2) {
            //相册类型为POI数据，过滤掉
        } else if (model.Type == 3) {
            //出口
            for (int i=0; i<self.categoryNameArray.count; i++) {
                [[self.categoryArray objectAtIndex:i] insertObject:model atIndex:0];
            }
        } else if (model.Type == 6) {
            //道路，过滤掉
        }
    }
    
}

- (void)updateNameLabel {
    if (self.categoryArray.count <= self.selectedCategoryIndex) {
        return;
    }
    NSArray *modelArray = [self.categoryArray objectAtIndex:self.selectedCategoryIndex];
    if (modelArray.count <= self.selectedAlbumIndex) {
        return;
    }
    MCPanoramaGuideContentModel *model = [modelArray objectAtIndex:self.selectedAlbumIndex];
    self.nameLabel.text = model.Info;
    [self.nameLabel sizeToFit];
    self.nameLabel.frame = CGRectMake(self.frame.size.width - self.nameLabel.frame.size.width - 8, 0, self.nameLabel.frame.size.width, kAlbumNameHeight);
}

#pragma mark - Collection Delegate
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (collectionView == self.albumCollectionView) {
        if (self.categoryArray.count <= self.selectedCategoryIndex) {
            return 0;
        }
        return [[self.categoryArray objectAtIndex:self.selectedCategoryIndex] count];
    } else if (collectionView == self.categoryCollectionView) {
        return [self.categoryNameArray count];
    }
    return 0;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    if (collectionView == self.albumCollectionView) {
        //定义每个图片的大小
        return CGSizeMake(kImageWidth, kImageWidth);
    } else if (collectionView == self.categoryCollectionView) {
        if (self.categoryNameArray.count <= indexPath.item) {
            return CGSizeZero;
        }
        NSString *categoryName = [self.categoryNameArray objectAtIndex:indexPath.item];
        CGSize cellSize = [categoryName sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:16]}];    //这里需要与CategorycCell中的font保持一致
        return CGSizeMake(cellSize.width + 15, kCategoryHeight);
    }
    return CGSizeZero;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    if (collectionView == self.albumCollectionView) {
        //定义每个图片的margin
        return UIEdgeInsetsMake(8, 8, 8, 8);
    } else if (collectionView == self.categoryCollectionView) {
        return UIEdgeInsetsMake(0, 8, 0, 8);
    }
    return UIEdgeInsetsZero;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (collectionView == self.albumCollectionView) {
        MCPanoramaAlbumCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:albumCellIdentifier forIndexPath:indexPath];
        if (self.categoryArray.count <= self.selectedCategoryIndex) {
            return nil;
        }
        NSArray *modelArray = [self.categoryArray objectAtIndex:self.selectedCategoryIndex];
        if (modelArray.count <= indexPath.item) {
            return nil;
        }
        MCPanoramaGuideContentModel *model = [modelArray objectAtIndex:indexPath.item];
        [cell setImageUrl:[NSString stringWithFormat:@"%@%@&pos=0_0&z=0", kPhotoBaseUrl, model.PID] name:model.Info isExit:(model.Type == 3)];
        [cell highlightCell:(indexPath.item == self.selectedAlbumIndex && [self.curPid isEqualToString:model.PID])];
        return cell;
    } else if (collectionView == self.categoryCollectionView) {
        MCPanoramaCategoryCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:categoryCellIdentifier forIndexPath:indexPath];
        if (self.categoryNameArray.count <= indexPath.item) {
            return nil;
        }
        NSString *name = [self.categoryNameArray objectAtIndex:indexPath.item];
        [cell setName:name];
        [cell highlightCell:(indexPath.item == self.selectedCategoryIndex) && [[self.pidToCategoryDictionary objectForKey:self.curPid] isEqualToString:name]];
        return cell;
    }
    return nil;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (collectionView == self.albumCollectionView) {
        if (self.categoryArray.count <= self.selectedCategoryIndex) {
            return;
        }
        NSArray *modelArray = [self.categoryArray objectAtIndex:self.selectedCategoryIndex];
        if (modelArray.count <= indexPath.item) {
            return;
        }
        MCPanoramaGuideContentModel *model = [modelArray objectAtIndex:indexPath.item];
        if ([model.PID isEqualToString:self.curPid]) {
            return;
        }
        self.curPid = model.PID;
        if (indexPath.item == 0 && model.Type == 3) {
            if ([self.delegate respondsToSelector:@selector(onSelectExitWithUid:)]) {
                if (self.exitUid.length) {
                    [self.delegate onSelectExitWithUid:self.exitUid];
                } else {
                    //从openapi进来的没有uid，则直接通过pid出内景，但会没有入口
                    [self.delegate onSelectAlbumWithPid:model.PID];
                }
            }
        } else {
            [self setAlbumHighlightAtIndex:(int)indexPath.item];
            if ([self.delegate respondsToSelector:@selector(onSelectAlbumWithPid:)]) {
                [self.delegate onSelectAlbumWithPid:model.PID];
            }
        }
    } else if (collectionView == self.categoryCollectionView) {
        if ([[self.pidToCategoryDictionary objectForKey:self.curPid] isEqualToString:[self.categoryNameArray objectAtIndex:(int)indexPath.item]]) {
            //当前pid属于点中的类别
            return;
        }
        [self setCategoryHighlightAtIndex:(int)indexPath.item];
        self.selectedAlbumIndex = self.defaultStartAblumIndex;
        [self.albumCollectionView reloadData];
        
        if (self.categoryArray.count <= self.selectedCategoryIndex) {
            return;
        }
        NSArray *modelArray = [self.categoryArray objectAtIndex:self.selectedCategoryIndex];
        if (modelArray.count <= self.selectedAlbumIndex) {
            return;
        }
        MCPanoramaGuideContentModel *model = [modelArray objectAtIndex:self.selectedAlbumIndex];
        self.curPid = model.PID;
        if ([self.delegate respondsToSelector:@selector(onSelectAlbumWithPid:)]) {
            [self.delegate onSelectAlbumWithPid:model.PID];
        }
    }
}

- (void)setCategoryHighlightAtIndex:(int)index {
//    if (index == self.selectedCategoryIndex) {
//        return;
//    }
    int lastSelectedIndex = self.selectedCategoryIndex;
    self.selectedCategoryIndex = (int)index;
    if (self.categoryNameArray.count > lastSelectedIndex && lastSelectedIndex >= 0) {
        [self.categoryCollectionView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:lastSelectedIndex inSection:0]]];
    }
    if (self.categoryNameArray.count > self.selectedCategoryIndex && self.selectedCategoryIndex >= 0) {
        [self.categoryCollectionView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:self.selectedCategoryIndex inSection:0]]];
    }
}

- (void)setAlbumOffsetAtIndex:(int)index {
    if (index < 0) {
        return;
    }
    CGPoint offset = self.albumCollectionView.contentOffset;
    if (offset.x + self.albumCollectionView.frame.size.width > (kImageWidth + 10) * index &&
        (kImageWidth + 10) * index > offset.x) {
        return;
    }
    offset.x = MIN((kImageWidth + 10) * index, self.albumCollectionView.contentSize.width - CGRectGetWidth(self.albumCollectionView.frame));
    [self.albumCollectionView setContentOffset:offset animated:YES];
}

- (void)setAlbumHighlightAtIndex:(int)index {
    int lastSelectedIndex = self.selectedAlbumIndex;
    self.selectedAlbumIndex = (int)index;
    
    if (self.selectedCategoryIndex >= 0 && self.selectedCategoryIndex < self.categoryArray.count) {
        if ([self.categoryArray objectAtIndex:self.selectedCategoryIndex].count > lastSelectedIndex && lastSelectedIndex >= 0) {
            [self.albumCollectionView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:lastSelectedIndex inSection:0]]];
        }
        if ([self.categoryArray objectAtIndex:self.selectedCategoryIndex].count > self.selectedAlbumIndex && self.selectedAlbumIndex >= 0) {
            [self.albumCollectionView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:self.selectedAlbumIndex inSection:0]]];
        }
    }
    
    [self setAlbumOffsetAtIndex:index];
    [self updateNameLabel];
}

- (void)setAlbumHighlightAtPid:(NSString *)pid {
    self.curPid = pid;
    for (int i=0; i<self.categoryArray.count; i++) {
        NSArray *photos = self.categoryArray[i];
        for (int j=0; j<photos.count; j++) {
            MCPanoramaGuideContentModel *model = photos[j];
            if ([model.PID isEqualToString:pid]) {
                [self setCategoryHighlightAtIndex:i];
                [self setAlbumHighlightAtIndex:j];
                return;
            }
        }
    }
    //如果没有匹配到pid，取消所有高亮和删除相册名
    MCPanoramaAlbumCell *albumCell = (MCPanoramaAlbumCell *)[self.albumCollectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:self.selectedAlbumIndex inSection:0]];
    MCPanoramaCategoryCell *categoryCell = (MCPanoramaCategoryCell *)[self.categoryCollectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:self.selectedCategoryIndex inSection:0]];
    [albumCell highlightCell:NO];
    [categoryCell highlightCell:NO];
    self.nameLabel.text = @"";
    self.nameLabel.frame = CGRectZero;
}

- (CGFloat)albumHeight {
    return self.frame.size.height > 0 ? self.container.frame.size.height : 0;
}

- (void)dealloc {
#ifdef DEBUG
    NSLog(@"Indoor Album dealloc");
#endif
}
@end

