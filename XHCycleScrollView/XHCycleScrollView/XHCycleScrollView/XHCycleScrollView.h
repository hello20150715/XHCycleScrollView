//
//  XHCycleScrollView.h
//  CollectionView轮播
//
//  Created by 汪涛 on 16/4/16.
//  Copyright © 2016年 汪涛. All rights reserved.
//

#import <UIKit/UIKit.h>
@class XHCycleScrollView;

@protocol XHCycleScrollViewDelegate <NSObject>

@optional
- (void)cycleScrollView:(XHCycleScrollView *)cycleScrollView clickIndex:(NSInteger)index;

@end

@interface XHCycleScrollView : UIView

@property(weak,nonatomic)id<XHCycleScrollViewDelegate> delegate;


/**默认2秒滚动间隔*/
+ (instancetype)cycleScrollViewWithFrame:(CGRect)frame delegate:(id<XHCycleScrollViewDelegate>)delegate sourceImage:(NSArray *)images placeholderImage:(UIImage *)placeholderImage;

@end
