//
//  MCPanoramaAlbumCell.h
//  StreetScapeFramework
//
//  Created by Captain Stanley on 16/3/9.
//  Copyright © 2016年 map.baidu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MCPanoramaAlbumCell : UICollectionViewCell

- (void)setImageUrl:(NSString *)url name:(NSString *)name isExit:(BOOL)flag;

- (void)highlightCell:(BOOL)flag;

@end
