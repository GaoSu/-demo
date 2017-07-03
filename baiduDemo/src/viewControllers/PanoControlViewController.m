//
//  PanoControlViewController.m
//  PanoramaViewDemo
//
//  Created by baidu on 15/4/10.
//  Copyright (c) 2015年 baidu. All rights reserved.
//

#import "PanoControlViewController.h"
//#import "BaiduPanoramaView.h"
#import <BaiduPanoSDK/BaiduPanoramaView.h>
#import <BaiduPanoSDK/BaiduLocationPanoData.h>
#import <BaiduPanoSDK/BaiduPanoDataFetcher.h>
#import <BaiduPanoSDK/BaiduPanoImageOverlay.h>
#import <BaiduPanoSDK/BaiduPanoLabelOverlay.h>
#import <BaiduPanoSDK/BaiduPanoOverlay.h>
#import <BaiduPanoSDK/BaiduPanoUtils.h>
#import <BaiduPanoSDK/BaiduPanoData.h>
#import "PanoFpsLabel.h"



#define TAG_SLIDER_PITCH   100001
#define TAG_SLIDER_HEADING 100002
#define TAG_SLIDER_LEVEL   100003

@interface PanoControlViewController ()<BaiduPanoramaViewDelegate>

@property(strong, nonatomic) BaiduPanoramaView  *panoramaView;
@property(strong, nonatomic) UISlider    *panoPitchSlider;
@property(strong, nonatomic) UISlider    *panoHeadingSlider;
@property(strong, nonatomic) UISlider    *panoLevelSlider;
@property(strong, nonatomic) PanoFpsLabel *fpsLabel;// 是否掉帧

@end

@implementation PanoControlViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"全景图控制";
    [self customPanoView];
    [self customSliderView];
    [self customPanoFPSLabel];
    // Do any additional setup after loading the view.
}

- (void)customPanoView {
    CGRect frame = CGRectMake(0, 0, CGRectGetWidth(getFixedScreenFrame()), CGRectGetHeight(getFixedScreenFrame()));
    
    // key 为在百度LBS平台上统一申请的接入密钥ak 字符串
    self.panoramaView = [[BaiduPanoramaView alloc] initWithFrame:frame key:@"sQP3SZ3gcYY6vHLfEbUeGmcGk0jiLYPG"];
    // 为全景设定一个代理
    self.panoramaView.delegate = self;
    [self.view addSubview:self.panoramaView];
    // 设定全景的清晰度， 默认为middle
    [self.panoramaView setPanoramaImageLevel:ImageDefinitionMiddle];
    // 设定全景的pid， 这是指定显示某地的全景，也可以通过百度坐标进行显示全景
    [self.panoramaView setPanoramaWithLon:113.37802626 lat:23.13271432];
    
}

- (void)customSliderView {
    CGFloat offsety = self.view.frame.size.height - 180;
    CGFloat offsetx = 5;
    UILabel *pitchLabel = [[UILabel alloc]initWithFrame:CGRectMake(offsetx, offsety, 100, 20)];
    pitchLabel.text = @"俯仰角控制";
    [self.view addSubview:pitchLabel];
    self.panoPitchSlider = [[UISlider alloc]initWithFrame:CGRectMake(105+offsetx, offsety, 200, 20)];
    [self.panoPitchSlider setMaximumValue:90];
    [self.panoPitchSlider setMinimumValue:-15];
    [self.panoPitchSlider addTarget:self action:@selector(updateValue:) forControlEvents:UIControlEventValueChanged];
    [self.panoPitchSlider setTag:TAG_SLIDER_PITCH];
    [self.view addSubview:self.panoPitchSlider];
    offsety += 35;
    UILabel *headLabel = [[UILabel alloc]initWithFrame:CGRectMake(offsetx, offsety, 100, 20)];
    headLabel.text = @"朝向控制";
    [self.view addSubview:headLabel];
    self.panoHeadingSlider = [[UISlider alloc]initWithFrame:CGRectMake(105+offsetx, offsety, 200, 20)];
    [self.panoHeadingSlider setMaximumValue:360];
    [self.panoHeadingSlider setMinimumValue:0];
    [self.panoHeadingSlider addTarget:self action:@selector(updateValue:) forControlEvents:UIControlEventValueChanged];
    [self.panoHeadingSlider setTag:TAG_SLIDER_HEADING];
    [self.view addSubview:self.panoHeadingSlider];
    offsety += 35;
    UILabel *levelLabel = [[UILabel alloc]initWithFrame:CGRectMake(offsetx, offsety, 100, 20)];
    levelLabel.text = @"缩放控制";
    [self.view addSubview:levelLabel];
    self.panoLevelSlider = [[UISlider alloc]initWithFrame:CGRectMake(105+offsetx, offsety, 200, 20)];
    [self.panoLevelSlider setMaximumValue:5];
    [self.panoLevelSlider setMinimumValue:1];
    [self.panoLevelSlider addTarget:self action:@selector(updateValue:) forControlEvents:UIControlEventValueChanged];
    [self.panoLevelSlider setTag:TAG_SLIDER_LEVEL];
    [self.view addSubview:self.panoLevelSlider];
}

- (void)customPanoFPSLabel {
    _fpsLabel = [ PanoFpsLabel new];
    [_fpsLabel sizeToFit];
    _fpsLabel.frame = CGRectMake(20.0f, self.view.frame.size.height-40, 60.0f, 25.0f);
    [self.view addSubview:_fpsLabel];
}

- (void)updateValue:(id)sender {
    
    UISlider *slider = (UISlider *)sender;
    if ( slider.tag == TAG_SLIDER_PITCH ) {
        [self.panoramaView setPanoramaPitch:slider.value];
    } else if ( slider.tag == TAG_SLIDER_HEADING ) {
        [self.panoramaView setPanoramaHeading:slider.value];
    } else if ( slider.tag == TAG_SLIDER_LEVEL ) {
        [self.panoramaView setPanoramaZoomLevel:slider.value];
    }
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
BOOL isPortrait() {
    UIInterfaceOrientation orientation = getStatusBarOritation();
    if ( orientation == UIInterfaceOrientationPortrait || orientation == UIInterfaceOrientationPortraitUpsideDown ) {
        return YES;
    }
    return NO;
}
UIInterfaceOrientation getStatusBarOritation() {
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    return orientation;
}
CGRect getFixedScreenFrame() {
    CGRect mainScreenFrame = [UIScreen mainScreen].bounds;
#ifdef NSFoundationVersionNumber_iOS_7_1
    if( !isPortrait() && (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_7_1) ) {
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
- (void)dealloc {
    [self.panoramaView removeFromSuperview];
    self.panoramaView.delegate = nil;
}

@end
