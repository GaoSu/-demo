//
//  PanoOverlayViewController.m
//  PanoramaViewDemo
//
//  Created by baidu on 15/4/12.
//  Copyright (c) 2015年 baidu. All rights reserved.
//

#import "PanoOverlayViewController.h"
#import <BaiduPanoSDK/BaiduPanoramaView.h>
#import <BaiduPanoSDK/BaiduLocationPanoData.h>
#import <BaiduPanoSDK/BaiduPanoDataFetcher.h>
#import <BaiduPanoSDK/BaiduPanoImageOverlay.h>
#import <BaiduPanoSDK/BaiduPanoLabelOverlay.h>
#import <BaiduPanoSDK/BaiduPanoOverlay.h>
#import <BaiduPanoSDK/BaiduPanoUtils.h>
#import <BaiduPanoSDK/BaiduPanoData.h>
//#import "BaiduPanoramaView.h"
//#import "BaiduPanoImageOverlay.h"
//#import "BaiduPanoLabelOverlay.h"
@interface PanoOverlayViewController ()<BaiduPanoramaViewDelegate>

@property(strong, nonatomic) BaiduPanoramaView  *panoramaView;

@end

@implementation PanoOverlayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setTitle:@"全景图覆盖物"];
    [self customPanoView];
    if ( self.overlayType == panoOverlayTypeImage ) {
        [self addImageOverlayTest];
    } else {
        [self addTextOverLayTest];
    }
    
    CGFloat coffsety = 100;
    CGRect cbtnFrame = CGRectMake(260, coffsety, 50, 30);
    UIButton *testBtn = [self createButton:@"测试" target:@selector(onTestBtn) frame:cbtnFrame];
    [self.view addSubview:testBtn];
    
    // Do any additional setup after loading the view.
}

- (void)viewDidDisappear:(BOOL)animated
{
    self.panoramaView.delegate = nil;
    if( self.overlayType == panoOverlayTypeImage ) {
        [self.panoramaView removeOverlay:@"54321"];
    } else {
        [self.panoramaView removeOverlay:@"12345"];
    }
}

- (void)customPanoView {
    
    CGRect frame = CGRectMake(0, 0, CGRectGetWidth([self getFixedScreenFrame]), CGRectGetHeight([self getFixedScreenFrame]));
    
    // key 为在百度LBS平台上统一申请的接入密钥ak 字符串
    self.panoramaView = [[BaiduPanoramaView alloc] initWithFrame:frame key:@"XXX"];
    // 为全景设定一个代理
    self.panoramaView.delegate = self;
    [self.view addSubview:self.panoramaView];
    // 设定全景的清晰度， 默认为middle
    [self.panoramaView setPanoramaImageLevel:ImageDefinitionMiddle];
    // 设定全景的pid， 这是指定显示某地的全景，也可以通过百度坐标进行显示全景
    [self.panoramaView setPanoramaWithLon:116.4034 lat:39.914134  ];
    
}

- (void)addTextOverLayTest {
    BaiduPanoLabelOverlay *textOverlay = [[BaiduPanoLabelOverlay alloc] init];
    textOverlay.overlayKey = @"12345";
    // 天安门广场坐标
    textOverlay.coordinate = CLLocationCoordinate2DMake(39.915118,116.403954);
    textOverlay.height         = 1;//单位为 m
    // 字体颜色
    textOverlay.textColor = [UIColor redColor];
    // 背景颜色
    textOverlay.backgroundColor = [UIColor whiteColor];
    textOverlay.fontSize  = 10;
    // 支持换行
    textOverlay.text      = @"hello\nworld\nssssssss\ndddddssssss\nddddddddd\nssdsssddsdsdsd\nsdsdsddsds";
    // 边缘距
    textOverlay.edgeInsets = UIEdgeInsetsMake(2, 3, 4, 5);
    [self.panoramaView addOverlay:textOverlay];
}

- (void)addImageOverlayTest {
    BaiduPanoImageOverlay *imageOverlay = [[BaiduPanoImageOverlay alloc] init];
    imageOverlay.overlayKey = @"54321";
    imageOverlay.coordinate = CLLocationCoordinate2DMake(39.911402, 116.403939);
    imageOverlay.height         = -50;//单位为 m
    imageOverlay.size = CGSizeMake(153, 69);
    imageOverlay.image = [UIImage imageNamed:@"icon.png"];
    [self.panoramaView addOverlay:imageOverlay];
}

- (void)onTestBtn {
    [self.panoramaView setCustomOverlayAnchor:@"54321" x:0.5f y:0.1f];
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

//获取设备bound方法
- (BOOL)isPortrait {
    UIInterfaceOrientation orientation = [self getStatusBarOritation];
    if ( orientation == UIInterfaceOrientationPortrait || orientation == UIInterfaceOrientationPortraitUpsideDown ) {
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
    if( ![self isPortrait]&& (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_7_1) ) {
        mainScreenFrame = CGRectMake(0, 0, mainScreenFrame.size.height, mainScreenFrame.size.width);
    }
#endif
    return mainScreenFrame;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIButton *)createButton:(NSString *)title target:(SEL)selector frame:(CGRect)frame {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    button.frame = frame;
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    if ( [[[UIDevice currentDevice] systemVersion] floatValue] >= 7 ) {
        [button setBackgroundColor:[UIColor whiteColor]];
    } else {
        [button setBackgroundColor:[UIColor clearColor]];
    }
    [button addTarget:self action:selector forControlEvents:UIControlEventTouchUpInside];
    return button;
}

- (void) dealloc {
    self.panoramaView.delegate = nil;
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
