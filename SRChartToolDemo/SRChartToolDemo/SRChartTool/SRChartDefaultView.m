//
//  SRChartDefaultView.m
//  SRChartToolDemo
//
//  Created by 周家民 on 2017/12/29.
//  Copyright © 2017年 starrain. All rights reserved.
//

#import "SRChartDefaultView.h"
#import "SRChartDataFloatView.h"

@interface SRChartDefaultView()

@property (nonatomic,strong) SRChartDataFloatView *dataFloatView;

@property (nonatomic,strong) UIView *indicatorLine;

@end

@implementation SRChartDefaultView{
    NSArray *_xTitleArr;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setBackgroundColor:[UIColor clearColor]];
        self.fillColor=[UIColor colorWithRed:1 green:1 blue:1 alpha:0.3];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    for (CAShapeLayer *chartLayer in self.chartLayerList) {
        chartLayer.frame=CGRectMake(0, 20, self.frame.size.width, self.frame.size.height-20);
    }
    [self setNeedsDisplay];
}

-(void)drawRect:(CGRect)rect{
    [super drawRect:rect];
    CGFloat lastMaxX=0;
    for (int i=0;i<_xTitleArr.count;i++){
        NSString *xTitle=_xTitleArr[i];
        CGSize titleSize = [xTitle sizeWithMaxSize:CGSizeMake(MAXFLOAT, MAXFLOAT) font:self.xTitleFont];
        CGFloat x=(i+1)*self.gap-0.5*titleSize.width;//值的x坐标，需要根据x的字符串长度做偏移
        CGPoint titlePosition=CGPointMake(x, rect.size.height-titleSize.height);
        CGRect strFrame=CGRectMake(titlePosition.x, titlePosition.y, titleSize.width, titleSize.height);
        if (i!=0&&(lastMaxX+3)>strFrame.origin.x) {
            continue;
        }
        lastMaxX=CGRectGetMaxX(strFrame);
        [xTitle drawInRect:strFrame withAttributes:@{NSForegroundColorAttributeName:self.xTitleColor,NSFontAttributeName:self.xTitleFont}];
    }
}

#pragma mark - getter
- (NSMutableArray *)chartLayerList {
    if (!_chartLayerList) {
        _chartLayerList = [NSMutableArray array];
    }
    return _chartLayerList;
}

- (SRChartDataFloatView *)dataFloatView {
    if (!_dataFloatView) {
        _dataFloatView = [[SRChartDataFloatView alloc] init];
        _dataFloatView.hidden = YES;
        _dataFloatView.layer.anchorPoint=CGPointMake(0, 1);
        [self addSubview:_dataFloatView];
    }
    return _dataFloatView;
}

- (UIView *)indicatorLine {
    if (!_indicatorLine) {
        _indicatorLine = [[UIView alloc] init];
        [self addSubview:_indicatorLine];
        _indicatorLine.hidden = YES;
        _indicatorLine.backgroundColor = [UIColor colorWithRed:191/255.0 green:191/255.0 blue:191/255.0 alpha:1];
    }
    return _indicatorLine;
}

- (CGFloat)lineWidth {
    if (_lineWidth == 0) {
        return 1;
    }
    return _lineWidth;
}

-(CGFloat)pointRadius{
    if (_pointRadius==0) {
        _pointRadius=2;
    }
    return _pointRadius;
}

-(UIColor *)pointColor{
    if (!_pointColor) {
        _pointColor=[UIColor blackColor];
    }
    return _pointColor;
}

-(UIColor *)xTitleColor{
    if (!_xTitleColor) {
        _xTitleColor=[UIColor blackColor];
    }
    return _xTitleColor;
}

-(UIFont *)xTitleFont{
    if(!_xTitleFont){
        _xTitleFont=[UIFont systemFontOfSize:7];
    }
    return _xTitleFont;
}

-(CGFloat)gap{
    if (_gap==0) {
        _gap=50;
    }
    return _gap;
}

#pragma mark - private
- (CGPoint)drawWithPath:(UIBezierPath*)path index:(int)index prePoint:(CGPoint)prePoint nextPoint:(CGPoint)nextPoint currentPercent:(CGFloat)currentPercent springPercent:(CGFloat)springPercent {
    [path moveToPoint:nextPoint];
    CGFloat radius=self.pointRadius*currentPercent+self.pointRadius*springPercent;
    radius=fmaxf(0, radius);
    [path addArcWithCenter:nextPoint radius:radius startAngle:0 endAngle:M_PI*2 clockwise:YES];
    return nextPoint;
}

- (void)hideInfo {
    self.indicatorLine.hidden = YES;
    self.dataFloatView.hidden = YES;
}

- (void)showWithPathList:(NSArray<UIBezierPath *> *)pathList {
    //判断绘制的路径数量是否跟图层数量相同，如果不相同则删除所有图层，创建跟路径数量相同的图层
    if ([pathList count] != [self.chartLayerList count]) {
        for (CAShapeLayer *chartLayer in self.chartLayerList) {
            [chartLayer removeFromSuperlayer];
        }
        [self.chartLayerList removeAllObjects];
    }
    //遍历所有的图层，挨个设置path
    for (int i = 0; i < [pathList count]; i ++) {
        if (i >= self.chartLayerList.count) {//如果没有图层则创建新的
            CAShapeLayer *chartLayer = [self createChartLayer];
            [self.layer addSublayer:chartLayer];
            [self.chartLayerList addObject:chartLayer];
        }
        CAShapeLayer *chartLayer = [self.chartLayerList objectAtIndex:i];
        UIBezierPath *path = [pathList objectAtIndex:i];
        chartLayer.path = path.CGPath;
        chartLayer.fillColor = self.fillColor.CGColor;
        chartLayer.strokeColor = [[self.lineColors objectAtIndex: i % [self.lineColors count]] CGColor];
        chartLayer.lineWidth = self.lineWidth;
    }
}

/**
 创建图层
 
 @return 返回初始化好的图层
 */
- (CAShapeLayer *)createChartLayer {
    CAShapeLayer *chartLayer=[CAShapeLayer layer];
    chartLayer.transform=CATransform3DMakeRotation(M_PI, 1, 0, 0);//纵向翻转，因为y轴的正方向是向下的，所以绘图的时候是颠倒的需要翻转
    return chartLayer;
}

-(void)didClickWithPoint:(CGPoint)point title:(NSString *)title valueStrList:(NSArray<NSString *> *)valueStrList{
    self.dataFloatView.hidden = NO;
    self.indicatorLine.hidden = NO;
    [self bringSubviewToFront:self.dataFloatView];
    [self bringSubviewToFront:self.indicatorLine];
    [self.dataFloatView showWithTitle:title infoStrList:valueStrList pointColorList:self.lineColors];
    CGPoint position=CGPointMake(point.x+5, point.y);
    self.dataFloatView.frame = CGRectMake(position.x, position.y - self.dataFloatView.frame.size.height, self.dataFloatView.frame.size.width, self.dataFloatView.frame.size.height);
    CGAffineTransform transform=CGAffineTransformMakeRotation(M_PI_4);
    self.dataFloatView.transform=transform;
    [UIView animateWithDuration:0.2 animations:^{
        self.indicatorLine.frame = CGRectMake(point.x, 0, 1, self.frame.size.height - 20);
    }];
    [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:0.5 initialSpringVelocity:0.5 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.dataFloatView.transform=CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
        
    }];
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    CGPoint touchPoint=[[touches anyObject] locationInView:self];
    int index=(touchPoint.x/self.gap)-1;
    if (index>=0&&self.delegate) {
        NSArray<NSString *> *valueStrList=[self.delegate valueForIndex:index];
        CGFloat y=[self.delegate yForIndex:index];
        NSString *xValueStr = [self.delegate xValueStrForIndex:index];
        [self didClickWithPoint:CGPointMake((index+1)*self.gap, y) title:xValueStr valueStrList:valueStrList];
    }
}

-(void)drawXTitleWithXTitleArr:(NSArray *)xTitleArr{
    _xTitleArr=xTitleArr;
    [self setNeedsDisplay];
}

@end


