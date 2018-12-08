//
//  SRChartDataFloatView.m
//  SRChartToolDemo
//
//  Created by 周家民 on 2018/12/7.
//  Copyright © 2018 starrain. All rights reserved.
//

#import "SRChartDataFloatView.h"
#import "NSString+SRChartTool.h"

@interface SRChartDataFloatView ()

@property (nonatomic,weak) UILabel *titleLabel;

@property (nonatomic,strong) NSMutableArray *pointViewList;

@property (nonatomic,strong) NSMutableArray *infoLabelList;

@end

@implementation SRChartDataFloatView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        //创建标题控件
        UILabel *titleLabel = [[UILabel alloc] init];
        [self addSubview:titleLabel];
        _titleLabel = titleLabel;
        titleLabel.font = [UIFont systemFontOfSize:9];
        titleLabel.textColor = [UIColor whiteColor];
        
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat titleX = 8;
    CGFloat titleY = 2;
    CGSize titleSize = [self.titleLabel.text sizeWithMaxSize:CGSizeMake(self.maxWidth - 2 * titleX, MAXFLOAT) font:self.titleLabel.font];
    self.titleLabel.frame = CGRectMake(titleX, titleY, titleSize.width, titleSize.height);
    
    CGFloat infoLabelX = 15;
    CGFloat infoLabelY = CGRectGetMaxY(self.titleLabel.frame) + 3;
    UILabel *previousInfoLabel = nil;
    CGFloat maxX = CGRectGetMaxX(self.titleLabel.frame) + 8;
    for (int i = 0; i < self.infoLabelList.count; i ++) {
        UILabel *infoLabel = [self.infoLabelList objectAtIndex:i];
        CGSize infoLabelSize = [infoLabel.text sizeWithMaxSize:CGSizeMake(self.maxWidth - infoLabelX - 8, MAXFLOAT) font:infoLabel.font];
        if (previousInfoLabel) {
            infoLabelY = CGRectGetMaxY(previousInfoLabel.frame) + 2;
        }
        infoLabel.frame = CGRectMake(infoLabelX, infoLabelY, infoLabelSize.width, infoLabelSize.height);
        UIView *pointView = [self.pointViewList objectAtIndex:i];
        pointView.center = infoLabel.center;
        pointView.frame = CGRectMake(8, pointView.frame.origin.y, pointView.frame.size.width, pointView.frame.size.height);
        previousInfoLabel = infoLabel;
        maxX = fmaxf(maxX, CGRectGetMaxX(infoLabel.frame) + 8);
    }
    
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, maxX, CGRectGetMaxY(previousInfoLabel.frame) + 2);
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    UIColor *bgColor = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:0.9];
    CGFloat cornerRadius = 5;
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    //从左边三角形顶点开始
    CGFloat startY = rect.size.height * 0.8;
    CGFloat h = 4;//三角形的高
    CGContextMoveToPoint(ctx, 0, startY);
    //三角形上边
    CGContextAddLineToPoint(ctx, h, startY - 0.5 * h);
    //到左上角圆角下端
    CGContextAddLineToPoint(ctx, h, cornerRadius);
    //圆角
    CGContextAddArc(ctx, h + cornerRadius, cornerRadius, cornerRadius, M_PI, 1.5 * M_PI, 0);
    //到右上角圆角左端
    CGContextAddLineToPoint(ctx, rect.size.width - cornerRadius, 0);
    //圆角
    CGContextAddArc(ctx, rect.size.width - cornerRadius, cornerRadius, cornerRadius, -0.5 * M_PI, 0, 0);
    //到右下角圆角上端
    CGContextAddLineToPoint(ctx, rect.size.width, rect.size.height - cornerRadius);
    //圆角
    CGContextAddArc(ctx, rect.size.width - cornerRadius, rect.size.height - cornerRadius, cornerRadius, 0, 0.5 * M_PI, 0);
    //到左下角圆角右端
    CGContextAddLineToPoint(ctx, cornerRadius, rect.size.height);
    //圆角
    CGContextAddArc(ctx, cornerRadius + h, rect.size.height - cornerRadius, cornerRadius, 0.5 * M_PI, M_PI, 0);
    //到三角形底边
    CGContextAddLineToPoint(ctx, h, startY + 0.5 * h);
    //闭合
    CGContextClosePath(ctx);
    CGContextSetFillColorWithColor(ctx, bgColor.CGColor);
    CGContextFillPath(ctx);
}

#pragma mark - getter
- (NSMutableArray *)pointViewList {
    if (!_pointViewList) {
        _pointViewList = [NSMutableArray array];
    }
    return _pointViewList;
}

- (NSMutableArray *)infoLabelList {
    if (!_infoLabelList) {
        _infoLabelList = [NSMutableArray array];
    }
    return _infoLabelList;
}

- (CGFloat)maxWidth {
    if (_maxWidth == 0) {
        return 100;
    }
    return _maxWidth;
}

#pragma mark - private
- (void)showWithTitle:(NSString *)title infoStrList:(NSArray<NSString *> *)infoStrList pointColorList:(NSArray<UIColor *> *)pointColorList {
    self.titleLabel.text = title;
    //清除原来的原点视图
    for (UIView *pointView in self.pointViewList) {
        [pointView removeFromSuperview];
    }
    [self.pointViewList removeAllObjects];
    //清除原来的信息label
    for (UILabel *infoLabel in self.infoLabelList) {
        [infoLabel removeFromSuperview];
    }
    [self.infoLabelList removeAllObjects];
    //重新添加信息视图和原点视图
    for (int i = 0; i < [infoStrList count]; i ++) {
        NSString *infoStr = [infoStrList objectAtIndex:i];
        UIView *pointView = [self createPointView];
        [self addSubview:pointView];
        [self.pointViewList addObject:pointView];
        if (i < [pointColorList count]) {
            pointView.backgroundColor = [pointColorList objectAtIndex:i];
        }
        
        UILabel *infoLabel = [self createInfoLabel];
        [self addSubview:infoLabel];
        [self.infoLabelList addObject:infoLabel];
        infoLabel.text = infoStr;
    }
    [self setNeedsDisplay];
}

/**
 创建信息标签视图

 @return 实例
 */
- (UILabel *)createInfoLabel {
    UILabel *infoLabel = [[UILabel alloc] init];
    infoLabel.font = [UIFont systemFontOfSize:9];
    infoLabel.textColor = [UIColor whiteColor];
    infoLabel.numberOfLines = 0;
    return infoLabel;
}

/**
 创建原点视图

 @return 实例
 */
- (UIView *)createPointView {
    UIView *pointView = [[UIView alloc] init];
    pointView.layer.masksToBounds = YES;
    pointView.frame = CGRectMake(0, 0, 5, 5);
    pointView.layer.cornerRadius = 0.5 * pointView.frame.size.height;
    return pointView;
}

@end
