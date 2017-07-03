//
//  MCPanoramaAlbumCell.m
//  StreetScapeFramework
//
//  Created by Captain Stanley on 16/3/9.
//  Copyright © 2016年 map.baidu. All rights reserved.
//

#import "MCPanoramaAlbumCell.h"
#import "UIImageView+WebCache.h"

@interface MCPanoramaAlbumCell()

@property (nonatomic, strong) UIImageView *thumbImageView;
@property (nonatomic, strong) UIImageView *coverImageView;
@property (nonatomic, strong) UILabel *nameLabel;

@end

@implementation MCPanoramaAlbumCell

- (void)setImageUrl:(NSString *)url name:(NSString *)name isExit:(BOOL)flag {
    if (!self.thumbImageView) {
        self.thumbImageView = [[UIImageView alloc] init];
        self.thumbImageView.contentMode = UIViewContentModeCenter;
        self.thumbImageView.clipsToBounds = YES;
        [self addSubview:self.thumbImageView];
        
        self.coverImageView = [[UIImageView alloc] init];
        self.coverImageView.contentMode = UIViewContentModeCenter;
        self.coverImageView.image = [UIImage imageNamed:@"icon_streetscape_exit"];
        self.coverImageView.backgroundColor = [UIColor blackColor];
        self.coverImageView.alpha = 0.7f;
        [self.thumbImageView addSubview:self.coverImageView];
    }
    
    [self.thumbImageView sd_setImageWithURL:[NSURL URLWithString:url] placeholderImage: [UIImage imageNamed:@"baidu_map_default_holder_icon"]];
    self.coverImageView.hidden = !flag;
    
    if (!self.nameLabel) {
        self.nameLabel = [[UILabel alloc] init];
        self.nameLabel.backgroundColor = [UIColor clearColor];
        self.nameLabel.textColor = [UIColor whiteColor];
        self.nameLabel.textAlignment = NSTextAlignmentCenter;
        self.nameLabel.font = [UIFont systemFontOfSize:12];
        [self addSubview:self.nameLabel];
    }
    self.nameLabel.text = name;
    self.nameLabel.hidden = flag;
}

- (void)highlightCell:(BOOL)flag {
    if (flag) {
        self.layer.borderWidth = 2;
        self.layer.borderColor = [[self getColorFromString:@"#3385ff"] CGColor];
    } else {
        self.layer.borderWidth = 0;
    }
}

- (void)layoutSubviews {
    self.thumbImageView.frame = self.bounds;
    self.coverImageView.frame = self.bounds;
    [self.nameLabel sizeToFit];
    self.nameLabel.frame = CGRectMake(0,
                                      CGRectGetHeight(self.bounds) - self.nameLabel.frame.size.height,
                                      CGRectGetWidth(self.bounds),
                                      self.nameLabel.frame.size.height);
}

- (UIColor *)getColorFromString:(NSString *)colorString
{
    NSString *cString = [[colorString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];//字符串处理
    //例子，stringToConvert #ffffff
    if ([cString length] < 6)
        return [UIColor whiteColor];//如果非十六进制，返回白色
    if ([cString hasPrefix:@"#"])
        cString = [cString substringFromIndex:1];//去掉头
    if ([cString length] != 6)//去头非十六进制，返回白色
        return [UIColor whiteColor];
    //分别取RGB的值
    NSRange range;
    range.location = 0;
    range.length = 2;
    NSString *rString = [cString substringWithRange:range];
    
    range.location = 2;
    NSString *gString = [cString substringWithRange:range];
    
    range.location = 4;
    NSString *bString = [cString substringWithRange:range];
    
    unsigned int r, g, b;
    //NSScanner把扫描出的制定的字符串转换成Int类型
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    //转换为UIColor
    return [UIColor colorWithRed:((float) r / 255.0f)
                           green:((float) g / 255.0f)
                            blue:((float) b / 255.0f)
                           alpha:1.0f];
}

@end
