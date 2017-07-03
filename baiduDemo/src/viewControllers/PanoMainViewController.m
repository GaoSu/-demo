//
//  PanoMainViewController.m
//  PanoramaViewDemo
//
//  Created by baidu on 15/4/10.
//  Copyright (c) 2015年 baidu. All rights reserved.
//

#import "PanoMainViewController.h"
#import "PanoShowViewController.h"
#import "PanoControlViewController.h"
#import "PanoOverlayViewController.h"
#import "PanoDataViewController.h"
#import "PanoInteriorViewController.h"
@interface PanoMainViewController ()

@property(strong, nonatomic) NSArray *menuData;
@property(strong, nonatomic) NSArray *submenuData;

@end

@implementation PanoMainViewController

- (instancetype)initWithStyle:(UITableViewStyle)style {
    if (self = [super initWithStyle:style]) {
        self.menuData = [[NSArray alloc] initWithObjects:@"展示全景图",@"全景图控制",@"全景图覆盖物",@"获取全景图数据",@"室内相册", nil];
        NSArray *arr1 = @[@"通过全景图ID展示",@"通过地理坐标展示",@"通过百度坐标展示",@"通过UID展示（内景使用默认相册）"];
        NSArray *arr2 = @[@"全景图控制"];
        NSArray *arr3 = @[@"文字类覆盖",@"图片类覆盖"];
        NSArray *arr4 = @[@"获取全景图数据"];
        NSArray *arr5 = @[@"室内相册显示 (使用自定义相册)"];
        self.submenuData = @[arr1,arr2,arr3,arr4,arr5];
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"百度全景SDK Demo";
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return self.menuData.count;
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return self.menuData[section];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [(NSArray *)[self.submenuData objectAtIndex:section] count];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString* cellIdentifier = @"Cell";
    
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    cell.textLabel.text = self.submenuData[indexPath.section][indexPath.row];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ( indexPath.section == 0 ) {
        PanoShowViewController *psVC = [[PanoShowViewController alloc]init];
        
        switch (indexPath.row) {
            case 0:
                psVC.showType = PanoShowTypePID;
                break;
            case 1:
                psVC.showType = PanoShowTypeGEO;
                break;
            case 2:
                psVC.showType = PanoShowTypeXY;
                break;
            case 3:
                psVC.showType = PanoShowTypeUID;
                break;
            default:
                psVC.showType = PanoShowTypePID;
                break;
        }
        
        [self.navigationController pushViewController:psVC animated:YES];
        
    } else if ( indexPath.section == 1 ) {
        PanoControlViewController *pcVC = [[PanoControlViewController alloc]init];
        [self.navigationController pushViewController:pcVC animated:YES];
    } else if ( indexPath.section == 2 ) {
        
        PanoOverlayViewController *poVC = [[PanoOverlayViewController alloc]init];
        switch (indexPath.row) {
            case 0:
                poVC.overlayType = PanoOverlayTypeText;
                break;
            case 1:
                poVC.overlayType = panoOverlayTypeImage;
                break;
            default:
                break;
        }
        [self.navigationController pushViewController:poVC animated:YES];
    } else if( indexPath.section == 3 ) {
        PanoDataViewController *pdVC = [[PanoDataViewController alloc]init];
        [self.navigationController pushViewController:pdVC animated:YES];
    } else {
        PanoInteriorViewController *pi = [[PanoInteriorViewController alloc]init];
        [self.navigationController pushViewController:pi animated:YES];
    }
}


@end
