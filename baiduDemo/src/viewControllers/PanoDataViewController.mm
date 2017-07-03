//
//  PanoDataViewController.m
//  PanoramaViewDemo
//
//  Created by baidu on 15/4/13.
//  Copyright (c) 2015年 baidu. All rights reserved.
//

#import "PanoDataViewController.h"
//#import "BaiduPanoramaView.h"
//#import "BaiduPanoDataFetcher.h"
//#import "BaiduPoiPanoData.h"
//#import "BaiduLocationPanoData.h"

//#import "BaiduPanoUtils.h"

#import <BaiduPanoSDK/BaiduPanoramaView.h>
#import <BaiduPanoSDK/BaiduLocationPanoData.h>
#import <BaiduPanoSDK/BaiduPanoDataFetcher.h>
#import <BaiduPanoSDK/BaiduPanoImageOverlay.h>
#import <BaiduPanoSDK/BaiduPanoLabelOverlay.h>
#import <BaiduPanoSDK/BaiduPanoOverlay.h>
#import <BaiduPanoSDK/BaiduPanoUtils.h>
#import <BaiduPanoSDK/BaiduPanoData.h>
@interface PanoDataViewController ()

@end

@implementation PanoDataViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"获取全景图数据";
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    CGFloat offsety = 20;
    CGRect btnFrame = CGRectMake(60, offsety, 200, 30);
    UIButton *btn = [self createButton:@"根据POI获取" target:@selector(onGetDataButtonClicked:) frame:btnFrame];
    btn.tag = 0;
    [self.view addSubview:btn];
    offsety += 40;
    CGRect btnFrame1 = CGRectMake(60, offsety, 200, 30);
    UIButton *btn1 = [self createButton:@"根据经纬度获取" target:@selector(onGetDataButtonClicked:) frame:btnFrame1];
    btn1.tag = 1;
    [self.view addSubview:btn1];
    offsety += 40;
    CGRect btnFrame2 = CGRectMake(60, offsety, 200, 30);
    UIButton *btn2 = [self createButton:@"根据墨卡托获取" target:@selector(onGetDataButtonClicked:) frame:btnFrame2];
    btn2.tag = 2;
    [self.view addSubview:btn2];
    offsety += 40;
    CGRect btnFrame3 = CGRectMake(60, offsety, 200, 30);
    UIButton *btn3 = [self createButton:@"获取室内信息" target:@selector(onGetDataButtonClicked:) frame:btnFrame3];
    btn3.tag = 3;
    [self.view addSubview:btn3];
    offsety += 40;
    CGRect btnFrame4 = CGRectMake(60, offsety, 200, 30);
    UIButton *btn4 = [self createButton:@"获取周边推荐服务信息" target:@selector(onGetDataButtonClicked:) frame:btnFrame4];
    btn4.tag = 4;
    [self.view addSubview:btn4];
    
    [self testCoordinateConvert];
}

- (void)onGetDataButtonClicked:(id)sender {
    UIButton *btn = (UIButton *)sender;
    switch (btn.tag) {
        case 0: {
            // 根据POI 的唯一ID获取全景数据
            BaiduPoiPanoData *data = [BaiduPanoDataFetcher requestPanoramaInfoWithUid:@"bff8fa7deabc06b9c9213da4"];
            NSLog(@"%@",data.description);
        }
            break;
        case 1: {
            BaiduLocationPanoData *data = [BaiduPanoDataFetcher requestPanoramaInfoWithLon:120.849039 Lat:29.611337];
            NSLog(@"%@",data.description);
        }
            break;
        case 2: {
            BaiduLocationPanoData *data = [BaiduPanoDataFetcher requestPanoramaInfoWithX:12948170 Y:4845075];
            NSLog(@"%@",data.description);
        }
            break;
        case 3: {
            NSString *jsonStr = [BaiduPanoDataFetcher requestPanoramaIndoorDataWithIid:@"13daddcacb839f158605bf0e"];
            NSLog(@"%@",jsonStr);
        }
            break;
        case 4: {
            NSString *jsonStr = [BaiduPanoDataFetcher requestPanoramaRecommendationServiceDataWithPid:@"1000220000150113115957235IN"];
            NSLog(@"%@",jsonStr);
            
        }
            break;
        default:
            break;
    }
}



- (void)testCoordinateConvert {
    
    CLLocationCoordinate2D common = CLLocationCoordinate2DMake(39.908946, 116.39737839);
    CLLocationCoordinate2D coor = [BaiduPanoUtils baiduCoorEncryptLon:common.longitude lat:common.latitude coorType:COOR_TYPE_COMMON];
    NSLog(@"new coor: lat->%f, lon->%f",coor.latitude,coor.longitude);
}

- (UIButton *)createButton:(NSString *)title target:(SEL)selector frame:(CGRect)frame {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    button.frame = frame;
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {
        [button setBackgroundColor:[UIColor whiteColor]];
    }else {
        [button setBackgroundColor:[UIColor clearColor]];
    }
    [button addTarget:self action:selector forControlEvents:UIControlEventTouchUpInside];
    return button;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
