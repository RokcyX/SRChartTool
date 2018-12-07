//
//  SRChartContainerView.m
//  SRChartToolDemo
//
//  Created by 周家民 on 2018/1/2.
//  Copyright © 2018年 starrain. All rights reserved.
//

#import "SRChartContainerView.h"
@interface SRChartContainerView()<SRChartDefaultViewDelegate>

@property(nonatomic,strong)CADisplayLink *displayLink;

@end

@implementation SRChartContainerView{
    UIScrollView *_scrollView;
    NSTimeInterval animationStartTime;
    
    CGFloat stiffness;//弹性刚度，如果小于1，表示不开启弹性效果
}

-(instancetype)initWithFrame:(CGRect)frame{
    if (self=[super initWithFrame:frame]) {
        [self setBackgroundColor:[UIColor clearColor]];
        _scrollView=[[UIScrollView alloc] init];
        [self addSubview:_scrollView];
        [_scrollView setShowsHorizontalScrollIndicator:NO];
        [_scrollView setContentInset:UIEdgeInsetsMake(0, 50, 0, 50)];
        [_scrollView.layer setMasksToBounds:NO];
        
        UIPinchGestureRecognizer *pinchRecognizer=[[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchRecognizer:)];
        [self addGestureRecognizer:pinchRecognizer];
        
    }
    return self;
}

/**
 捏合手势响应方法
 
 @param pinchRecognizer 捏合手势识别对象
 */
-(void)pinchRecognizer:(UIPinchGestureRecognizer*)pinchRecognizer{
    self.displayLink.paused=YES;
    if( pinchRecognizer.numberOfTouches == 2 ) {
        [self.chartView hideInfo];
        //2.获取捏合中心点 -> 捏合中心点距离scrollviewcontent左侧的距离
        CGPoint p1 = [pinchRecognizer locationOfTouch:0 inView:_scrollView];
        CGPoint p2 = [pinchRecognizer locationOfTouch:1 inView:_scrollView];
        CGFloat centerX = (p1.x+p2.x)/2;
        int curIndex=centerX/self.chartView.gap+0.5;
        
        CGFloat leftMagin=curIndex*self.chartView.gap-_scrollView.contentOffset.x;
        
        CGFloat pinchScale=pinchRecognizer.scale;
        self.gap*=pinchScale;
        self.gap=fmaxf(self.minGap, fminf(self.maxGap, self.gap));
        if (self.gap==self.chartView.gap) {
            return;
        }
        self.chartView.gap=self.gap;
        [self.chartView setHidden:YES];
        [self showChartWithAnimated:NO];
        CGFloat offsetX=fmaxf(0,curIndex*self.chartView.gap-leftMagin);
        [self.chartView setHidden:NO];
        [_scrollView setContentOffset:CGPointMake(offsetX, 0)];
        pinchRecognizer.scale=1;
    }
}

-(void)drawRect:(CGRect)rect{
    [super drawRect:rect];
    CGContextRef ctx=UIGraphicsGetCurrentContext();
    CGFloat value=self.yMaxValue/self.seperateLineCount;
    CGFloat h=self.chartView.frame.size.height-20;
    CGFloat seperateH=h/self.seperateLineCount;
    for (int i=0; i<self.seperateLineCount; i++) {
        NSString *yTitle=[NSString stringWithFormat:@"%.2f",i*value];
        UIFont *yTitleFont=[UIFont systemFontOfSize:11];
        CGSize titleSize = [yTitle sizeWithMaxSize:CGSizeMake(MAXFLOAT, MAXFLOAT) font:yTitleFont];
        CGFloat x=titleSize.width+5;
        CGFloat y=CGRectGetMaxY(self.chartView.frame)-i*seperateH-20;
        CGFloat w=self.frame.size.width-x;
        
        [yTitle drawInRect:CGRectMake(0, y-0.5*titleSize.height, titleSize.width, titleSize.height) withAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor],NSFontAttributeName:yTitleFont}];
        CGContextMoveToPoint(ctx, x, y);
        CGContextAddLineToPoint(ctx, w, y);
    }
    [[UIColor colorWithRed:1 green:1 blue:1 alpha:0.3] setStroke];
    CGContextStrokePath(ctx);
}

-(void)layoutSubviews{
    [super layoutSubviews];
    _scrollView.frame=CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    _chartView.frame=_scrollView.bounds;
    [_scrollView setContentSize:CGSizeMake(CGRectGetMaxX(self.chartView.frame), _scrollView.frame.size.height)];
}

-(void)setChartView:(SRChartDefaultView *)chartView{
    if (_chartView) {
        chartView.lineColors = _chartView.lineColors;
        [_chartView removeFromSuperview];
    }
    _chartView=chartView;
    _chartView.frame=_scrollView.bounds;
    [_scrollView addSubview:_chartView];
    _chartView.delegate=self;
}

-(CADisplayLink *)displayLink{
    if (!_displayLink) {
        _displayLink=[CADisplayLink displayLinkWithTarget:self selector:@selector(doAnimation)];
        [_displayLink setPaused:YES];
        [_displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
    }
    return _displayLink;
}

-(void)showChartWithAnimated:(BOOL)animated{
    [self.chartView hideInfo];
    [self setNeedsDisplay];
    if (animated) {
        [_scrollView setContentOffset:CGPointMake(0, 0)];
        animationStartTime=CACurrentMediaTime();
        self.displayLink.paused=NO;
        
    }else{
        [CATransaction begin];
        [CATransaction setDisableActions:YES];
        CGFloat scale=self.chartView.frame.size.height/self.yMaxValue;
        NSMutableArray *pathList = [NSMutableArray array];
        CGFloat chartViewWidth = 0;
        for (NSArray *yValueArr in self.yValueArrList) {
            UIBezierPath *path=[UIBezierPath bezierPath];
            CGPoint prePoint=CGPointMake(0, 20);
            [path moveToPoint:prePoint];
            for (int i=0; i< yValueArr.count; i++) {
                CGFloat x,y=0;
                x=(i+1)*self.chartView.gap;
                
                //根据图层高度和y轴最大值的比例求出当前遍历点的实际y值
                CGFloat yValue=[yValueArr[i] floatValue];
                y=yValue*scale;
                //绘制点路径
                CGPoint nextPoint=CGPointMake(x, y);
                
                [self.chartView drawWithPath:path index:i prePoint:prePoint nextPoint:nextPoint currentPercent:1 springPercent:0];
                prePoint=nextPoint;
            }
            if ([self.chartView isClosePath]) {
                [path addLineToPoint:CGPointMake(prePoint.x, 20)];
                [path closePath];
            }
            [pathList addObject:path];
            chartViewWidth = fmaxf(chartViewWidth, prePoint.x);
        }
        [self.chartView showWithPathList:pathList];
//        UIBezierPath *path=[UIBezierPath bezierPath];
//        CGPoint prePoint=CGPointMake(0, 20);
//        [path moveToPoint:prePoint];
//        for (int i=0; i<self.yValueArr.count; i++) {
//            CGFloat x,y=0;
//            x=(i+1)*self.chartView.gap;
//
//            //根据图层高度和y轴最大值的比例求出当前遍历点的实际y值
//            CGFloat yValue=[self.yValueArr[i] floatValue];
//            y=yValue*scale;
//            //绘制点路径
//            CGPoint nextPoint=CGPointMake(x, y);
//
//            [self.chartView drawWithPath:path index:i prePoint:prePoint nextPoint:nextPoint currentPercent:1 springPercent:0];
//            prePoint=nextPoint;
//
//        }
//        if ([self.chartView isClosePath]) {
//            [path addLineToPoint:CGPointMake(prePoint.x, 20)];
//            [path closePath];
//        }
//        [self.chartView showWithPath:path];
        [CATransaction commit];
        self.chartView.frame=CGRectMake(0, self.chartView.frame.origin.y, chartViewWidth, self.chartView.frame.size.height);
        [_scrollView setContentSize:CGSizeMake(CGRectGetMaxX(self.chartView.frame), _scrollView.frame.size.height)];
    }
    [self.chartView drawXTitleWithXTitleArr:self.xValueArr];
}

-(void)showChartWithStiffness:(CGFloat)_stiffness{
    stiffness=_stiffness;
    [self showChartWithAnimated:YES];
}

- (void)showChartWithXValueArr:(NSArray *)xValueArr yValueArrList:(NSArray<NSArray *> *)yValueArrList {
    stiffness = 0.8;
    self.xValueArr = xValueArr;
    self.yValueArrList = yValueArrList;
    [self showChartWithAnimated:YES];
}

- (void)showChartWithXValueArr:(NSArray *)xValueArr yValueArrList:(NSArray<NSArray *> *)yValueArrList lineColors:(NSArray<UIColor *> *)lineColors {
    self.chartView.lineColors = lineColors;
    [self showChartWithXValueArr:xValueArr yValueArrList:yValueArrList];
}

- (void)doAnimation {
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    NSTimeInterval usedTime=self.displayLink.timestamp-animationStartTime;
    /*
     因为chartLayer绘图方法内部用了关闭隐式动画的方法，频繁提交动画事务导致CPU占用率太高，
     所以这里用一个判断是否应该让动画结束的标志，当判断动画执行的位置已经超出屏幕边界时，将
     该值设置为YES表示停止逐帧绘图，以优化性能。
     */
    NSMutableArray *pathList = [NSMutableArray array];
    BOOL complete=NO;
    CGFloat scale=self.chartView.frame.size.height/self.yMaxValue;
    NSTimeInterval springTime=2;//弹性效果持续时间
    CGFloat chartViewWidth = 0;
    for (NSArray *yValueArr in self.yValueArrList) {
        UIBezierPath *path=[UIBezierPath bezierPath];
        CGPoint prePoint=CGPointMake(0, 20);
        [path moveToPoint:prePoint];
        for (int i=0; i<yValueArr.count; i++) {
            CGFloat x,y=0;
            x=(1+i)*self.gap;
            
            //根据图层高度和y轴最大值的比例求出当前遍历点的实际y值
            CGFloat yValue=[yValueArr[i] floatValue];
            y=yValue*scale;
            //绘制点路径
            CGPoint nextPoint=CGPointMake(x, y);
            NSTimeInterval currentUsedTime= fmax(0, usedTime-i*self.animationIntervalDuration);
            CGFloat currentPercent=fminf(1, currentUsedTime/self.unitAnimationDuration);
            
            BOOL isOut=i*self.gap>(_scrollView.contentOffset.x+_scrollView.frame.size.width);//判断当前绘制的点是否已经超出屏幕范围
            
            CGFloat springPercent=0;
            if (stiffness>0) {
                CGFloat springX=fmaxf(0,fminf(1,currentUsedTime/(self.unitAnimationDuration+springTime)));
                springPercent=[self getSpringInterpolation: springX stiffness:stiffness];
            }
            BOOL currentAnimationComplete=currentUsedTime>=self.unitAnimationDuration+springTime;//判断当前点的动画是否执行完成
            
            /*
             当最后一个点的动画执行完毕或者
             当同时满足当前绘制点超出屏幕，当前绘制点的弹性动画已经执行完毕时，
             则视为应该停止逐帧绘图，让complete为YES，并暂停displayLink
             */
            if ((isOut&&currentAnimationComplete)||(i==yValueArr.count-1&&currentAnimationComplete)) {
                complete=YES;
                stiffness=0;
                _displayLink.paused=YES;
            }
            
            /*
             当complete为YES时，将点的绘制百分比设为1和弹性因素设为0.
             表示让之后的所有点直接绘制到最终位置
             */
            if (complete) {//
                currentPercent=1;
                springPercent=0;
            }
            
            prePoint=[self.chartView drawWithPath:path index:i prePoint:prePoint nextPoint:nextPoint currentPercent:currentPercent springPercent:springPercent];
            
        }
        if ([self.chartView isClosePath]) {
            [path addLineToPoint:CGPointMake(prePoint.x, 20)];
            [path closePath];
        }
        [pathList addObject:path];
        chartViewWidth = fmaxf(chartViewWidth, prePoint.x);
    }
    [self.chartView showWithPathList:pathList];
    self.chartView.frame=CGRectMake(0, self.chartView.frame.origin.y, chartViewWidth, self.chartView.frame.size.height);
    [_scrollView setContentSize:CGSizeMake(CGRectGetMaxX(self.chartView.frame), _scrollView.frame.size.height)];
    [CATransaction commit];
}

-(NSArray *)xValueArr{
    if (!_xValueArr) {
        _xValueArr=[NSArray array];
    }
    return _xValueArr;
}

-(CGFloat)yMaxValue{
    //    if (_yValueArr.count<1) {
    //        _yMaxValue=1;//保证y轴最大值有值，因为该值在计算中会用作分母，以免造成0作为除数
    //    }
    //    CGFloat yMaxValueInArr=[[self.yValueArr valueForKeyPath:@"@max.floatValue"] floatValue]*2;
    //    if (_yMaxValue==0||_yMaxValue<yMaxValueInArr) {//y轴显示的最大值不能小于数组中实际的最大值
    //        _yMaxValue=yMaxValueInArr;
    //    }
    CGFloat maxValue = 0;
    for (NSArray *yValueArr in self.yValueArrList) {
        maxValue = fmaxf(maxValue, [[yValueArr valueForKeyPath:@"@max.floatValue"] floatValue]*2);
    }
    return maxValue;
}

-(CGFloat)gap{
    if (_gap==0) {
        _gap=50;
    }
    return _gap;
}

-(CGFloat)maxGap{
    if (_maxGap==0) {
        _maxGap=50;
    }
    return _maxGap;
}

-(CGFloat)minGap{
    if (_minGap==0) {
        _minGap=5;
    }
    return _minGap;
}

-(int)seperateLineCount{
    if (_seperateLineCount==0) {
        _seperateLineCount=5;
    }
    return _seperateLineCount;
}

-(NSTimeInterval)unitAnimationDuration{
    if (_unitAnimationDuration==0) {
        _unitAnimationDuration=0.1;
    }
    return _unitAnimationDuration;
}

-(NSTimeInterval)animationIntervalDuration{
    if (_animationIntervalDuration==0) {
        _animationIntervalDuration=0.05;
    }
    return _animationIntervalDuration;
}

/**
 弹性计算公式
 
 @param springX 弹性公式坐标图中的横坐标值，值域为[0,1] 公式来源：https://www.jianshu.com/p/cf9f600a5342
 @return 返回计算后的结果
 */
- (CGFloat)getSpringInterpolation:(CGFloat)springX stiffness:(CGFloat)stiffness{
    return pow(2, -10 * springX) * sin((springX - stiffness / 4) * (2 * M_PI) / stiffness);
}

#pragma mark-SRChartDefaultViewDelegate
- (NSArray<NSString *> *)valueForIndex:(int)index {
    NSMutableArray *valueStrList = [NSMutableArray array];
    for (NSArray *yValueArr in self.yValueArrList) {
        NSString *valueStr = [yValueArr[index] stringValue];
        [valueStrList addObject:valueStr];
    }
    return valueStrList;
}

- (NSString *)xValueStrForIndex:(int)index {
    if (index >= 0 && index < self.xValueArr.count) {
        return [self.xValueArr objectAtIndex:index];
    }
    return @"-";
}

-(CGFloat)yForIndex:(int)index{
    if (index>=0&&index<[self.yValueArrList firstObject].count) {
        CGFloat scale=self.chartView.frame.size.height/self.yMaxValue;
        CGFloat maxYValue = 0;
        for (NSArray *yValueArr in self.yValueArrList) {
            CGFloat yValue=[yValueArr[index] floatValue];
            maxYValue = fmaxf(yValue, maxYValue);
        }
        CGFloat y=maxYValue*scale;
        return self.chartView.frame.size.height-y;
    }
    return 0;
}

@end
