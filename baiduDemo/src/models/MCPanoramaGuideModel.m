//
//  MCPanoramaGuideModel.m
//  StreetScapeFramework
//
//  Created by Captain Stanley on 16/3/9.
//  Copyright © 2016年 map.baidu. All rights reserved.
//

#import "MCPanoramaGuideModel.h"



static  NSArray *catalogNames = nil;
static  NSArray *catalogs = nil;

@implementation MCPanoramaGuideExtModel

@end

@implementation MCPanoramaGuideContentModel

+ (NSArray *)catalogNames {
    if (!catalogNames)
    catalogNames = @[@"其他",
                     @"正门",
                     @"房型",
                     @"设施",
                     @"正门",
                     @"餐饮设施",
                     @"其他设施",
                     @"正门",
                     @"设施",
                     @"观影厅",
                     @"其他设施"];
    return catalogNames;
}

+ (NSArray *)catalogs {
    if (!catalogs)
    catalogs = @[@"0",
                 @"1",
                 @"2", @"2", @"2", @"2", @"2", @"2", @"2",
                 @"3", @"3", @"3", @"3",
                 @"4",
                 @"5", @"5", @"5",
                 @"6", @"6",
                 @"7",
                 @"8", @"8", @"8",
                 @"9",
                 @"10"
                 ];
    return catalogs;
}
- (int)categoryIndex {
    if (!self.Catalog) {
        return -1;
    }
    if (self.Catalog.length == 0) {
        return [ [[self class] catalogs][0] intValue];
    }
    if ([self.Catalog intValue] < 0 && [self.Catalog intValue] >= [[self class] catalogs].count) {
        return [[[self class] catalogs][0] intValue];
    }
    return [[[self class] catalogs][[self.Catalog intValue]] intValue];
}

+ (NSString *)categoryNameForIndex:(int)index {
    if (index < 0 || index >= [[self class] catalogNames].count) {
        return [[self class] catalogNames][0];
    }
    return [[self class] catalogNames][index];
}

- (NSString *)categoryName {
    int index = [self categoryIndex];
    return [MCPanoramaGuideContentModel categoryNameForIndex:index];
}

- (NSString *)floorName {
    if (!self.Floor) {
        return nil;
    }
    return [MCPanoramaGuideContentModel floorNameForIndex:[self.Floor intValue]];
}

+ (NSString *)floorNameForIndex:(int)index {
    return [NSString stringWithFormat:@"%@%d", index<0?@"B":@"F", abs(index)];
}

@end

@implementation MCPanoramaGuideModel


@end

