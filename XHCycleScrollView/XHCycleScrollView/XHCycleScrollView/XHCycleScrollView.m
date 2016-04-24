//
//  XHCycleScrollView.m
//  CollectionView轮播
//
//  Created by 汪涛 on 16/4/16.
//  Copyright © 2016年 汪涛. All rights reserved.
//

#import "XHCycleScrollView.h"
#import "UIImageView+WebCache.h"

#define pageCount 100

#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height

static NSString *identifier = @"cell";

@interface XHCycleScrollView ()<UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout>

@property(weak,nonatomic)UICollectionView *collectionView;

@property(weak,nonatomic)UICollectionViewFlowLayout *flowLayout;

@property(weak,nonatomic)UIPageControl *pageControl;

@property(strong,nonatomic)NSTimer *timer;

@property(strong,nonatomic)NSArray *images;

@property(strong,nonatomic)NSMutableArray *downloadImageArray;

@property(weak,nonatomic)UIImage *placeholderImage;
@end

@implementation XHCycleScrollView


+ (instancetype)cycleScrollViewWithFrame:(CGRect)frame delegate:(id<XHCycleScrollViewDelegate>)delegate sourceImage:(NSArray *)images placeholderImage:(UIImage *)placeholderImage
{
    XHCycleScrollView *cycleScrollView = [[XHCycleScrollView alloc] initWithFrame:frame];
    cycleScrollView.delegate = delegate;
    cycleScrollView.placeholderImage = placeholderImage;
    cycleScrollView.images = images;
    
    return cycleScrollView;
}

- (void)setImages:(NSArray *)images
{
    _images = images;
    
    self.pageControl.numberOfPages = images.count;
    [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:(pageCount * self.images.count)/2 inSection:0] atScrollPosition:UICollectionViewScrollPositionLeft animated:NO];
}
- (instancetype)initWithFrame:(CGRect)frame
{
    if (self == [super initWithFrame:frame]) {
        
        [self initColectionAndPageControl];
    }
    
    return self;
}

- (void)initColectionAndPageControl
{
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.minimumLineSpacing = 0;
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.itemSize = CGSizeMake(SCREEN_WIDTH, 150);
    self.flowLayout = layout;
    
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:layout];
    collectionView.showsHorizontalScrollIndicator = NO;
    collectionView.showsVerticalScrollIndicator = NO;
    collectionView.pagingEnabled = YES;
    collectionView.dataSource = self;
    collectionView.delegate = self;
    [collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:identifier];
    [self addSubview:collectionView];
    self.collectionView = collectionView;
    
    UIPageControl *pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, self.frame.size.height - 20, SCREEN_WIDTH, 20)];
    _pageControl.currentPage = 0;
    [self addSubview:pageControl];
    self.pageControl = pageControl;
    
//    [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:(pageCount * self.images.count)/2 inSection:0] atScrollPosition:UICollectionViewScrollPositionLeft animated:NO];
//    
    [self addtimer];
    
}

#pragma mark action
- (void)addtimer
{
    NSTimer *timer = [NSTimer timerWithTimeInterval:2.0 target:self selector:@selector(nextPage) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
    self.timer = timer;
}
- (void)nextPage
{
    NSIndexPath *currentIndexPath = [[self.collectionView indexPathsForVisibleItems] lastObject];
    NSInteger nextItem = currentIndexPath.row + 1;
    if (nextItem >= self.images.count*pageCount) {
        nextItem = pageCount*self.images.count * 0.5;
        [_collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:nextItem inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
        return;
    }
    NSIndexPath *nextIndexPath = [NSIndexPath indexPathForRow:nextItem inSection:currentIndexPath.section];
    [self.collectionView scrollToItemAtIndexPath:nextIndexPath atScrollPosition:UICollectionViewScrollPositionLeft animated:YES];
}

// 压缩图片
- (UIImage *)imageWithImageSimple:(UIImage*)image scaledToSize:(CGSize)newSize
{
    UIGraphicsBeginImageContext(newSize);
    
    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return newImage;
}


#pragma mark collectionView DataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.images.count*pageCount;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 150)];
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    
    long itemIndex = indexPath.item % self.images.count;
    NSString *imagePath = self.images[itemIndex];
    
    if ([imagePath isKindOfClass:[NSString class]]) {
        if ([imagePath hasPrefix:@"http"]) {
            [imageView sd_setImageWithURL:[NSURL URLWithString:imagePath] placeholderImage:self.placeholderImage];
            [cell.contentView addSubview:imageView];
        } else {
            imageView.image = [UIImage imageNamed:imagePath];
            if (!imageView.image) {
                imageView.image = [UIImage imageWithContentsOfFile:imagePath];
            }
            [cell.contentView addSubview:imageView];
        }
    } else if ([imagePath isKindOfClass:[UIImage class]]) {
        imageView.image = self.images[itemIndex];
        [cell.contentView addSubview:imageView];
    }
    return cell;
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.delegate respondsToSelector:@selector(cycleScrollView:clickIndex:)]) {
        
        [self.delegate cycleScrollView:self clickIndex:indexPath.item%self.images.count];
    }
}
#pragma mark scrollViewDelegate
- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView
{
    [self.timer invalidate];
    self.timer = nil;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [self addtimer];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    
    int page = (int)(scrollView.contentOffset.x/SCREEN_WIDTH + 0.5)%self.images.count;
    self.pageControl.currentPage = page;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
