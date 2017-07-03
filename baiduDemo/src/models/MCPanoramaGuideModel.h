//
//  MCPanoramaGuideModel.h
//  StreetScapeFramework
//
//  Created by Captain Stanley on 16/3/9.
//  Copyright © 2016年 map.baidu. All rights reserved.
//

#import "JSONLiteModel.h"


@interface MCPanoramaGuideExtModel : JSONLiteModel

@property (nonatomic, assign) NSInteger ImageType;  //0表示普通内景，2表示有拓扑的内景

@end

@interface MCPanoramaGuideContentModel : JSONLiteModel

@property (nonatomic, assign) float Dir;
@property (nonatomic, copy) NSString *Info;
@property (nonatomic, copy) NSString *PID;
@property (nonatomic, assign) NSInteger Pitch;
@property (nonatomic, assign) NSInteger PrvDir;
@property (nonatomic, assign) NSInteger PrvFovy;
@property (nonatomic, assign) NSInteger PrvPitch;
@property (nonatomic, assign) NSInteger Type;   //1表示离散内景的相册，5表示带有拓扑的内景
@property (nonatomic, assign) NSInteger Weigh;
@property (nonatomic, assign) NSInteger X;
@property (nonatomic, assign) NSInteger Y;
//正常相册专有字段
@property (nonatomic, copy) NSString *Catalog;
@property (nonatomic, assign) NSNumber *Floor;

//出口专有的字段
@property (nonatomic, assign) NSInteger PanoX;
@property (nonatomic, assign) NSInteger PanoY;
@property (nonatomic, copy) NSString *UID;

- (int)categoryIndex;
- (NSString *)categoryName;
+ (NSString *)categoryNameForIndex:(int)index;

- (NSString *)floorName;
+ (NSString *)floorNameForIndex:(int)index;

@end

@protocol MCPanoramaGuideContentModel <NSObject>

@end

@interface MCPanoramaGuideModel : JSONLiteModel

@property (nonatomic, strong) MCPanoramaGuideExtModel *ExtInfo;
@property (nonatomic, strong) NSArray<MCPanoramaGuideContentModel> *content;
@end
