//
//  MCPanoramaAlbumView.h
//  StreetScapeFramework
//
//  Created by Captain Stanley on 16/3/8.
//  Copyright © 2016年 map.baidu. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BaiduPoiPanoData;

@protocol MCPanoramaAlbumDelegate <NSObject>

/**
 *  @abstract 选择相应相册的回调
 */
- (void)onSelectAlbumWithPid:(NSString *)pid;

/**
 *  @abstract 点击出口的回调
 */
- (void)onSelectExitWithUid:(NSString *)uid;

/**
 *  @abstract 收到Guide数据后决定是否影藏鹰眼图
 */
- (void)shouldHideEagleEye:(BOOL)flag;

@end

@interface MCPanoramaAlbumView : UIView

@property (nonatomic, weak) id<MCPanoramaAlbumDelegate> delegate;

- (void)showAlbumWithParams:(BaiduPoiPanoData *)data inFrame:(CGRect)frame;
- (void)setAlbumHighlightAtIndex:(int)index;
- (void)setAlbumHighlightAtPid:(NSString *)pid;
- (CGFloat)albumHeight;

@end
