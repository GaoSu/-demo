
//
//  PanoShowViewController.m
//  PanoramaViewDemo
//
//  Created by baidu on 15/4/10.
//  Copyright (c) 2015年 baidu. All rights reserved.
//

#import "PanoShowViewController.h"
//#import "BaiduPanoramaView.h"
//#import "BaiduPanoUtils.h"

#import <BaiduPanoSDK/BaiduPanoramaView.h>
#import <BaiduPanoSDK/BaiduLocationPanoData.h>
#import <BaiduPanoSDK/BaiduPanoDataFetcher.h>
#import <BaiduPanoSDK/BaiduPanoImageOverlay.h>
#import <BaiduPanoSDK/BaiduPanoLabelOverlay.h>
#import <BaiduPanoSDK/BaiduPanoOverlay.h>
#import <BaiduPanoSDK/BaiduPanoUtils.h>
#import <BaiduPanoSDK/BaiduPanoData.h>
#import "PanoFpsLabel.h"

@interface PanoShowViewController ()<BaiduPanoramaViewDelegate>

@property(strong, nonatomic) BaiduPanoramaView  *panoramaView;
@property(strong, nonatomic) UITextField *panoPidTF;
@property(strong, nonatomic) UITextField *panoCoorXTF;
@property(strong, nonatomic) UITextField *panoCoorYTF;
@property(strong, nonatomic) PanoFpsLabel *fpsLabel;// 是否掉帧

@end

@implementation PanoShowViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setTitle:@"百度全景展示"];
    [self customPanoView];
    [self customInputView];
    [self customPanoFPSLabel];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
  
}
- (void)dealloc {
    [self.panoramaView removeFromSuperview];
    self.panoramaView.delegate = nil;
    self.panoramaView = nil;
}
- (void)customInputView {
    
    CGFloat offsety = 64;
    CGRect btnFrame = CGRectMake(260, offsety, 50, 30);
    UIButton *enterBtn = [self createButton:@"确定" target:@selector(refreshPanoViewData) frame:btnFrame];
    [self.view addSubview:enterBtn];
    
    CGFloat coffsety = 124;
    CGRect cbtnFrame = CGRectMake(260, coffsety, 50, 30);
    UIButton *testBtn = [self createButton:@"测试" target:@selector(onTestBtn) frame:cbtnFrame];
    [self.view addSubview:testBtn];
    if (self.showType == PanoShowTypePID) {
        self.panoPidTF = [[UITextField alloc]initWithFrame:CGRectMake(5, offsety, 250, 30)];
        self.panoPidTF.backgroundColor = [UIColor whiteColor];
        self.panoPidTF.placeholder     = @" 输入全景PID展示全景";
        [self.view addSubview:self.panoPidTF];
    }else if (self.showType == PanoShowTypeGEO) {
        self.panoCoorXTF = [[UITextField alloc]initWithFrame:CGRectMake(5, offsety, 250, 30)];
        self.panoCoorXTF.backgroundColor = [UIColor whiteColor];
        self.panoCoorXTF.placeholder     = @"输入地理坐标longitude";
        offsety += 35;
        self.panoCoorYTF = [[UITextField alloc]initWithFrame:CGRectMake(5, offsety, 250, 30)];
        self.panoCoorYTF.backgroundColor = [UIColor whiteColor];
        self.panoCoorYTF.placeholder     = @"输入地理坐标latitude";
        [self.view addSubview:self.panoCoorXTF];
        [self.view addSubview:self.panoCoorYTF];
    }else if (self.showType == PanoShowTypeUID) {
        self.panoPidTF = [[UITextField alloc]initWithFrame:CGRectMake(5, offsety, 250, 30)];
        self.panoPidTF.backgroundColor = [UIColor whiteColor];
        self.panoPidTF.placeholder     = @" 输入POI 的 UID展示全景";
        // uid 测试
        self.panoPidTF.text = @"06d2dffda107b0ef89f15db6";
//        self.panoPidTF.text = @"5c2dc21d1edf15046ec02caa";// 只有外景
//        self.panoPidTF.text = @"1a30c5f8cbb55eff71210b02";
//        self.panoPidTF.text = @"fd007c5e7df31675a8f729c0";
        [self.view addSubview:self.panoPidTF];
    }else {
        self.panoCoorXTF = [[UITextField alloc]initWithFrame:CGRectMake(5, offsety, 250, 30)];
        self.panoCoorXTF.backgroundColor = [UIColor whiteColor];
        self.panoCoorXTF.placeholder     = @"输入百度坐标X";
        self.panoCoorXTF.text = @"1293476325";
        offsety += 35;
        self.panoCoorYTF = [[UITextField alloc]initWithFrame:CGRectMake(5, offsety, 250, 30)];
        self.panoCoorYTF.backgroundColor = [UIColor whiteColor];
        self.panoCoorYTF.placeholder     = @"输入百度坐标Y";
        self.panoCoorYTF.text = @"485045009";
        [self.view addSubview:self.panoCoorXTF];
        [self.view addSubview:self.panoCoorYTF];
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
    [self.panoramaView setPanoramaImageLevel:ImageDefinitionLow];
    // 设定全景的pid， 这是指定显示某地的全景，/Work/Code/app/panosdk2/ios/demo/BaiduPanoDemo/BaiduPanoDemo也可以通过百度坐标进行显示全景
//    [self.panoramaView setPanoramaWithPid:@"01002200001309101607372275K"];
    
    // 西单大悦城坐标
    [self.panoramaView setPanoramaWithLon:116.379918 lat:39.916634];
    
}

- (void)customPanoFPSLabel {
    _fpsLabel = [ PanoFpsLabel new];
    [_fpsLabel sizeToFit];
    _fpsLabel.frame = CGRectMake(20.0f, self.view.frame.size.height-40, 60.0f, 25.0f);
    [self.view addSubview:_fpsLabel];
}

- (void)showPanoViewWithPID:(NSString *)pid {
    [self.panoramaView setPanoramaWithPid:pid];
}

- (void)showPanoViewWithLon:(double)lon lat:(double)lat {
    [self.panoramaView setPanoramaWithLon:lon lat:lat];
}

- (void)showPanoViewWithX:(int)x Y:(int)y {
    [self.panoramaView setPanoramaWithX:x Y:y];
}

- (void)showPanoViewWithUID:(NSString *)uid {
    [self.panoramaView setPanoramaWithUid:uid type:BaiduPanoramaTypeInterior];
}

- (void)onTestBtn {
    [self.panoramaView setPoiOverlayHidden:YES];
}

- (void)refreshPanoViewData {
    if ( self.showType == PanoShowTypePID ) {
        if (self.panoPidTF.text.length>0) {
            [self showPanoViewWithPID:self.panoPidTF.text];
        }
        [self.panoPidTF resignFirstResponder];
    } else if ( self.showType == PanoShowTypeGEO ) {
        if ( self.panoCoorXTF.text.length > 0 && self.panoCoorYTF.text.length > 0 ) {
            [self showPanoViewWithLon:[self.panoCoorXTF.text doubleValue] lat:[self.panoCoorYTF.text doubleValue]];
        }
        [self.panoCoorXTF resignFirstResponder];
        [self.panoCoorYTF resignFirstResponder];
    } else if ( self.showType == PanoShowTypeUID ) {
        if ( self.panoPidTF.text.length ) {
            [self showPanoViewWithUID:self.panoPidTF.text];
//              [self.panoramaView setPanoramaWithLon:121.454051 lat:31.267445];
        }
    } else {
        if ( self.panoCoorXTF.text.length > 0 && self.panoCoorYTF.text.length > 0 ) {
            [self showPanoViewWithX:[self.panoCoorXTF.text intValue] Y:[self.panoCoorYTF.text intValue]];
        }
        [self.panoCoorXTF resignFirstResponder];
        [self.panoCoorYTF resignFirstResponder];
    }

}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

- (void)panoramaView:(BaiduPanoramaView *)panoramaView didReceivedMessage:(NSDictionary *)dict {
    
}


#pragma mark - other func 
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
    if(![self isPortrait]&& (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_7_1)) {
        mainScreenFrame = CGRectMake(0, 0, mainScreenFrame.size.height, mainScreenFrame.size.width);
    }
#endif
    return mainScreenFrame;
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
