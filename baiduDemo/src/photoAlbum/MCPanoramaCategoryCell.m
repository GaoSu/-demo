//
//  MCPanoramaCategoryCell.m
//  StreetScapeFramework
//
//  Created by Captain Stanley on 16/3/15.
//  Copyright © 2016年 map.baidu. All rights reserved.
//

#import "MCPanoramaCategoryCell.h"

@interface MCPanoramaCategoryCell ()

@property (nonatomic, strong) UILabel *nameLabel;

@end

@implementation MCPanoramaCategoryCell

- (void)setName:(NSString *)name {
    if (!self.nameLabel) {
        self.nameLabel = [[UILabel alloc] init];
        self.nameLabel.backgroundColor = [UIColor clearColor];
        self.nameLabel.textAlignment = NSTextAlignmentCenter;
        self.nameLabel.font = [UIFont systemFontOfSize:16];
        [self addSubview:self.nameLabel];
    }
    self.nameLabel.text = name;
}

- (void)highlightCell:(BOOL)flag {
    if (flag) {
        self.nameLabel.textColor = [UIColor whiteColor];
    } else {
        self.nameLabel.textColor = [UIColor lightGrayColor];
    }
}

- (void)layoutSubviews {
    self.nameLabel.frame = self.bounds;
}

@end
