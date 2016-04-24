//
//  ViewController.m
//  CollectionView轮播
//
//  Created by 汪涛 on 16/3/22.
//  Copyright © 2016年 汪涛. All rights reserved.
//

#import "ViewController.h"
#import "XHCycleScrollView.h"

#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height

@interface ViewController ()<XHCycleScrollViewDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    NSMutableArray *imageArr = [NSMutableArray array];
    for (int i = 0; i<5; i++) {
        NSString *imageName = [NSString stringWithFormat:@"home_%d.png",i+1];
        UIImage *image = [UIImage imageNamed:imageName];
        [imageArr addObject:image];
    }
    XHCycleScrollView *scroll = [XHCycleScrollView cycleScrollViewWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 150) delegate:self sourceImage:imageArr placeholderImage:nil];
    scroll.delegate = self;
    [self.view addSubview:scroll];
   
}

- (void)cycleScrollView:(XHCycleScrollView *)cycleScrollView clickIndex:(NSInteger)index
{
    NSLog(@"选中的照片索引：%ld",index);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
