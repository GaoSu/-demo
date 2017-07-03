//
//  PanoInteriorViewController.m
//  BaiduPanoDemo
//
//  Created by baidu on 15/7/14.
//  Copyright (c) 2015年 baidu. All rights reserved.
//

#import "PanoInteriorViewController.h"
//#import "BaiduPanoramaView.h"
//#import "BaiduPanoDataFetcher.h"

#import <BaiduPanoSDK/BaiduPanoramaView.h>
#import <BaiduPanoSDK/BaiduLocationPanoData.h>
#import <BaiduPanoSDK/BaiduPanoDataFetcher.h>
#import <BaiduPanoSDK/BaiduPanoImageOverlay.h>
#import <BaiduPanoSDK/BaiduPanoLabelOverlay.h>
#import <BaiduPanoSDK/BaiduPanoOverlay.h>
#import <BaiduPanoSDK/BaiduPanoUtils.h>
#import <BaiduPanoSDK/BaiduPanoData.h>
#import "PanoFpsLabel.h"
#import "MCPanoramaAlbumView.h"
@interface PanoInteriorViewController ()<BaiduPanoramaViewDelegate,MCPanoramaAlbumDelegate> {
    
}

@property (strong, nonatomic) BaiduPanoramaView  *panoramaView;
@property (strong, nonatomic) PanoFpsLabel *fpsLabel;// 是否掉帧
@property (strong, nonatomic) MCPanoramaAlbumView *indoorAlbum;

@end

@implementation PanoInteriorViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"内景显示";
    [self.view setBackgroundColor:[UIColor whiteColor]];
    [self customPanoView];
    [self customPanoFPSLabel];
}


- (void)customPanoFPSLabel {
    _fpsLabel = [ PanoFpsLabel new];
    [_fpsLabel sizeToFit];
    _fpsLabel.frame = CGRectMake(20.0f, self.view.frame.size.height-40, 60.0f, 25.0f);
    [self.view addSubview:_fpsLabel];
}


- (MCPanoramaAlbumView *)indoorAlbum {
    if (!_indoorAlbum) {
        _indoorAlbum = [[MCPanoramaAlbumView alloc]init];
        _indoorAlbum.delegate = self;
    }
    
    return _indoorAlbum;
}
- (void)dealloc {
    self.panoramaView.delegate = nil;
}


- (void)onGetDataButtonClicked {

}
#pragma mark - panorama view delegate

- (void)panoramaWillLoad:(BaiduPanoramaView *)panoramaView {
    
}

- (void)panoramaDidLoad:(BaiduPanoramaView *)panoramaView descreption:(NSString *)jsonStr {
    
}


- (void)panoramaLoadFailed:(BaiduPanoramaView *)panoramaView error:(NSError *)error {
    
}

- (void)panoramaView:(BaiduPanoramaView *)panoramaView overlayClicked:(NSString *)overlayId {
    
}

//- (UIView *)indoorAlbumViewForPanoramaView:(BaiduPanoramaView *)panoramaView poiData:(BaiduPoiPanoData *)data {
//
///* 室内相册
// * 假如返回的是 nil 的话，将会采用加载默认相册的方案，默认相册即是 IndoorAlbumPlugin对应的.a 
// * 假如开发者想要自己开发室内相册，自己定制自己的室内相册的话，可以删掉 IndoorAlbumPlugin.a ,然后创建完之后的室内相册通过此接口进行返回。
// */
//    // 开发者使用默认相册，需要引入 IndoorAlbumPlugin
////    return nil;
//    // 开发者自己开发相册，这里给出了一个室内相册 View 示例 MCPanoramaAlbum
//    CGRect frame = self.view.frame;
//    [self.indoorAlbum showAlbumWithParams:data inFrame:frame];
//    return self.indoorAlbum;
//
//}

#pragma mark - 相册回调，非主线程
- (void)onSelectAlbumWithPid:(NSString *)pid {
    [self.panoramaView setPanoramaWithPid:pid];
}

- (void)onSelectExitWithUid:(NSString *)uid {
    [self.panoramaView setPanoramaWithUid:uid];
}

- (void)shouldHideEagleEye:(BOOL)flag {
    
}
- (void)customPanoView {
    CGRect frame = CGRectMake(0, 0, CGRectGetWidth([self getFixedScreenFrame]), CGRectGetHeight([self getFixedScreenFrame]));
    
    // key 为在百度LBS平台上统一申请的接入密钥ak 字符串
    self.panoramaView = [[BaiduPanoramaView alloc] initWithFrame:frame key:@"XXXX"];
    // 为全景设定一个代理
    self.panoramaView.delegate = self;
    [self.view addSubview:self.panoramaView];
    // 设定全景的清晰度， 默认为middle
    [self.panoramaView setPanoramaImageLevel:ImageDefinitionMiddle];
    // 根据某一的POI 的UID，来请求这个地点的室内信息,假如我们知道如家酒店的POI 的UID，然后用这个UID就可以请求到如家酒店测室内全景信息
//    [self.panoramaView setPanoramaWithUid:@"bff8fa7deabc06b9c9213da4" type:BaiduPanoramaTypeStreet];
    // 只有内景
//    [self.panoramaView setPanoramaWithUid:@"fd007c5e7df31675a8f729c0" type:BaiduPanoramaTypeInterior];
    // 拓扑内景
//    [self.panoramaView setPanoramaWithUid:@"7c86f335bbcc18fc5fbe8669" type:BaiduPanoramaTypeInterior];
    // 希尔顿王府井
    [self.panoramaView setPanoramaWithUid:@"7aea43b75f0ee3e17c29bd71" type:BaiduPanoramaTypeInterior];

}

- (UIButton *)createButton:(NSString *)title target:(SEL)selector frame:(CGRect)frame {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    button.frame = frame;
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {
        [button setBackgroundColor:[UIColor whiteColor]];
    } else {
        [button setBackgroundColor:[UIColor clearColor]];
    }
    [button addTarget:self action:selector forControlEvents:UIControlEventTouchUpInside];
    return button;
}

//获取设备bound方法
- (BOOL)isPortrait {
    UIInterfaceOrientation orientation = [self getStatusBarOritation];
    if (orientation == UIInterfaceOrientationPortrait || orientation == UIInterfaceOrientationPortraitUpsideDown) {
        return YES;
    }
    return NO;
}
- (UIInterfaceOrientation)getStatusBarOritation {
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    return orientation;
}
- (CGRect)getFixedScreenFrame {
    CGRect mainScreenFrame = [UIScreen mainScreen].bounds;
#ifdef NSFoundationVersionNumber_iOS_7_1
    if( ![self isPortrait] && (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_7_1) ) {
        mainScreenFrame = CGRectMake(0, 0, mainScreenFrame.size.height, mainScreenFrame.size.width);
    }
#endif
    return mainScreenFrame;
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
