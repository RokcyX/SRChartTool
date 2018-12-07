//
//  SRChartView.m
//  SRChartToolDemo
//
//  Created by 周家民 on 2017/12/27.
//  Copyright © 2017年 starrain. All rights reserved.
//

#import "SRChartView.h"

@interface SRChartLayer()

@property(nonatomic,strong)NSMutableArray *xTextLayers;

@property(nonatomic,strong)NSMutableArray *pointLayers;

@end

/**
 根据提供的最大尺寸及字体计算字符串实际的尺寸
 
 @param str 字符串
 @param maxSize 允许的最大尺寸
 @param font 字体
 @return 返回计算过后的字符串实际尺寸
 */
CGSize sizeWithString(NSString *str,CGSize maxSize,UIFont *font){
    CGSize textSize=CGSizeZero;
    NSStringDrawingOptions opts = NSStringDrawingUsesLineFragmentOrigin |
    NSStringDrawingUsesFontLeading;
    
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    [style setLineBreakMode:NSLineBreakByCharWrapping];
    
    NSDictionary *attributes = @{ NSFontAttributeName : font, NSParagraphStyleAttributeName : style };
    
    CGRect rect = [str boundingRectWithSize:maxSize
                                    options:opts
                                 attributes:attributes
                                    context:nil];
    textSize = rect.size;
    return textSize;
}

@implementation SRChartLayer{
    NSArray *_xArr;
    NSArray *_yArr;
    CGFloat _gap;//值间间距
}

-(instancetype)init{
    if (self=[super init]) {
        self.transform=CATransform3DMakeRotation(M_PI, 1, 0, 0);//纵向翻转，因为y轴的正方向是向下的，所以绘图的时候是颠倒的需要翻转
    }
    return self;
}

-(void)drawWithXArr:(NSArray *)xArr yArr:(NSArray *)yArr gap:(CGFloat)gap maxY:(CGFloat)maxY{
    _gap=gap;
    _xArr=xArr;
    _yArr=yArr;
    
    if (maxY<=0) {
        return;
    }
    
    CGFloat yScale=self.frame.size.height/maxY;//chartLayer高度与最大y值的比例
    UIBezierPath *path=[UIBezierPath bezierPath];
    CGPoint lastPoint=CGPointMake(0, 0);
    [path moveToPoint:lastPoint];
    CGFloat radius=10;
    for(int i=0;i<yArr.count;i++){
        id value=yArr[i];
        if (![value isKindOfClass:[NSNumber class]]) return;
        CGFloat yValue=[value floatValue]*yScale;
        CGFloat xValue=(i+1)*gap;
        CGPoint toPoint=CGPointMake(xValue, yValue);
        CGFloat controlPointX=0.5*(toPoint.x-lastPoint.x)+lastPoint.x;
        CGPoint cp1=CGPointMake(controlPointX, lastPoint.y);
        CGPoint cp2=CGPointMake(controlPointX, toPoint.y);
        [path addCurveToPoint:toPoint controlPoint1:cp1 controlPoint2:cp2];//绘制三次贝塞尔曲线
        //        [path addArcWithCenter:toPoint radius:radius startAngle:0 endAngle:M_PI*2 clockwise:YES];
        //        [path addLineToPoint:toPoint];
        CALayer *pointLayer;
        if (self.pointLayers.count<=i) {
            pointLayer=[CALayer layer];
            [self addSublayer:pointLayer];
            [self.pointLayers addObject:pointLayer];
            pointLayer.frame=CGRectMake(0, 0, radius, radius);
            [pointLayer setCornerRadius:0.5*radius];
            [pointLayer setBackgroundColor:[UIColor whiteColor].CGColor];
        }else
            pointLayer=self.pointLayers[i];
        [CATransaction begin];
        [CATransaction setDisableActions:YES];//关闭CALayer的隐式动画，否则原点没有根据弹性公式计算的弹性效果
        pointLayer.position=toPoint;
        [CATransaction commit];
        
        lastPoint=toPoint;
    }
    //闭合
    [path addLineToPoint:CGPointMake(lastPoint.x, 0)];
    [path closePath];
    self.fillColor=[[UIColor colorWithRed:1 green:1 blue:1 alpha:0.3] CGColor];
//    self.strokeColor=[UIColor whiteColor].CGColor;
    self.lineWidth=2;
    self.path=path.CGPath;
    self.frame=CGRectMake(self.frame.origin.x, self.frame.origin.y, lastPoint.x, self.frame.size.height);//设置chartLayer的宽度随内容自增长
}

-(void)drawInContext:(CGContextRef)ctx{
    [super drawInContext:ctx];
    for (CATextLayer *textLayer in self.xTextLayers) {
        [textLayer removeFromSuperlayer];
    }
    [_xTextLayers removeAllObjects];
    for(int i=0;i<_xArr.count;i++) {
        NSString *xValue=_xArr[i];
        CGSize strSize=[self sizeWithString:xValue maxSize:CGSizeMake(MAXFLOAT, MAXFLOAT) font:[UIFont systemFontOfSize:15]];
        CGFloat x=(i+1)*_gap;//值的x坐标，需要根据x的字符串长度做偏移
        CGRect strFrame=CGRectMake(x, -strSize.height, strSize.width, strSize.height);
        CATextLayer *textLayer=[CATextLayer layer];
        textLayer.string=xValue;
        textLayer.frame=strFrame;
        textLayer.position=CGPointMake(strFrame.origin.x, strFrame.origin.y);
        textLayer.fontSize=11;
        textLayer.foregroundColor=[UIColor whiteColor].CGColor;
        textLayer.contentsScale=[UIScreen mainScreen].scale;
        textLayer.transform=CATransform3DMakeRotation(M_PI, 1, 0, 0 );
        [self addSublayer:textLayer];
        [self.xTextLayers addObject:textLayer];
    }
}

-(NSMutableArray *)xTextLayers{
    if (!_xTextLayers) {
        _xTextLayers=[NSMutableArray array];
    }
    return _xTextLayers;
}

-(NSMutableArray *)pointLayers{
    if (!_pointLayers) {
        _pointLayers=[NSMutableArray array];
    }
    return _pointLayers;
}

/**
 根据提供的最大尺寸及字体计算字符串实际的尺寸
 
 @param str 字符串
 @param maxSize 允许的最大尺寸
 @param font 字体
 @return 返回计算过后的字符串实际尺寸
 */
-(CGSize)sizeWithString:(NSString*)str maxSize:(CGSize)maxSize font:(UIFont*)font{
    CGSize textSize=CGSizeZero;
    NSStringDrawingOptions opts = NSStringDrawingUsesLineFragmentOrigin |
    NSStringDrawingUsesFontLeading;
    
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    [style setLineBreakMode:NSLineBreakByCharWrapping];
    
    NSDictionary *attributes = @{ NSFontAttributeName : font, NSParagraphStyleAttributeName : style };
    
    CGRect rect = [str boundingRectWithSize:maxSize
                                    options:opts
                                 attributes:attributes
                                    context:nil];
    textSize = rect.size;
    return textSize;
}

@end

@interface SRChartView()

/**
 求最大y值的计算属性
 */
@property(nonatomic,assign)CGFloat maxY;

@property(nonatomic,strong)NSMutableArray *yTitleLayers;

@end

@implementation SRChartView{
    SRChartLayer *_chartLayer;
    CADisplayLink *_displayLink;
    NSTimeInterval _startTime;
}

-(instancetype)initWithFrame:(CGRect)frame{
    if (self=[super initWithFrame:frame]) {
        _displayLink=[CADisplayLink displayLinkWithTarget:self selector:@selector(doAnimation)];
        _displayLink.paused=YES;
        [_displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
        _chartLayer=[SRChartLayer layer];
        [self.layer addSublayer:_chartLayer];
        
    }
    return self;
}

-(void)layoutSubviews{
    [super layoutSubviews];
    
    [self setBackgroundColor:[UIColor blueColor]];
    
    //根据最大的Y值字符串长度重新指定chartLayer的尺寸
    UIFont *yValueFont=[UIFont systemFontOfSize:11];
    NSString *maxYStr=[NSString stringWithFormat:@"%f",self.maxY];
    CGSize maxYSize=sizeWithString(maxYStr, CGSizeMake(MAXFLOAT, MAXFLOAT),yValueFont);
    _chartLayer.frame=CGRectMake(maxYSize.width, 0, _chartLayer.frame.size.width, self.frame.size.height-50);
    [self setContentSize:CGSizeMake(_chartLayer.frame.size.width+maxYSize.width, self.frame.size.height)];
}

-(void)drawRect:(CGRect)rect{
    [super drawRect:rect];
    CGContextRef ctx=UIGraphicsGetCurrentContext();
    
    //清楚y轴标题
    for (CATextLayer *yTitleLayer in self.yTitleLayers) {
        [yTitleLayer removeFromSuperlayer];
    }
    [self.yTitleLayers removeAllObjects];
    
    //绘制分割线
    CGFloat unitY=self.maxY/self.seperateLineCount;
    CGFloat unitH=_chartLayer.frame.size.height/self.seperateLineCount;
    for (int i=0; i<self.seperateLineCount; i++) {
        CGContextMoveToPoint(ctx, 0,  CGRectGetMaxY(_chartLayer.frame)-i*unitH);
        CGContextAddLineToPoint(ctx, self.frame.size.width, CGRectGetMaxY(_chartLayer.frame)-i*unitH);
        
        //添加y轴标题
        UIFont *titleFont=[UIFont systemFontOfSize:11];
        NSString *yValueStr=[NSString stringWithFormat:@"%.2f",i*unitY];
        CGSize strSize=sizeWithString(yValueStr, CGSizeMake(MAXFLOAT, MAXFLOAT), titleFont);
        CGRect strFrame=CGRectMake(0,CGRectGetMaxY(_chartLayer.frame)-i*unitH-0.5*(strSize.height), strSize.width, strSize.height);
        
        [yValueStr drawInRect:strFrame withAttributes:@{NSFontAttributeName:titleFont,NSForegroundColorAttributeName:[UIColor whiteColor]}];
    }
    [[UIColor colorWithRed:1 green:1 blue:1 alpha:0.3] setStroke];
    CGContextStrokePath(ctx);
    
}

-(void)drawWithAnimate:(BOOL)animate{
    if (animate) {
        _startTime=CACurrentMediaTime();
        [_displayLink setPaused:NO];
        [_chartLayer setNeedsDisplay];
    }else{
        //        [_chartLayer drawWithXArr:_xArr yArr:_yArr gap:100];
    }
}

-(void)doAnimation{
    //计算动画进行百分比
    NSTimeInterval useTime=_displayLink.timestamp-_startTime;
    NSMutableArray *newYarr=[NSMutableArray array];
    /*
     因为chartLayer绘图方法内部用了关闭隐式动画的方法，频繁提交动画事务导致CPU占用率太高，
     所以这里用一个判断是否应该让动画结束的标志，当判断动画执行的位置已经超出屏幕边界时，将
     该值设置为YES表示停止逐帧绘图，以优化性能。
     */
    BOOL complete=NO;
    for (int i=0; i<_yArr.count; i++) {
        NSTimeInterval curValueUseTime=fmaxf(0,useTime-i*self.animationIntervalDuration);
        CGFloat percent=fminf(1,curValueUseTime/self.unitDuration);
        
        NSTimeInterval springTime=2;
        CGFloat x=fmaxf(0,fminf(1,curValueUseTime/(self.unitDuration+springTime)));
        CGFloat factor=[self getSpringInterpolation: x];
        
        BOOL isOut=i*self.gap>(self.contentOffset.x+self.frame.size.width);//判断当前绘制的点是否已经超出屏幕范围
//        if (i==_yArr.count-1&&curValueUseTime>=self.unitDuration+springTime) {
//            _displayLink.paused=YES;
//        }
        BOOL springComplete=curValueUseTime>=self.unitDuration+springTime;//判断当前点的弹性动画是否执行完成
        
        /*
         当同时满足当前绘制点超出屏幕，当前绘制点的弹性动画已经执行完毕时，
         则视为应该停止逐帧绘图，让complete为YES，并暂停displayLink
         */
        if (isOut&&springComplete) {
            complete=YES;
            _displayLink.paused=YES;
        }
        
        /*
         当complete为YES时，将点的绘制百分比设为1和弹性因素设为0.
         表示让之后的所有点直接绘制到最终位置
         */
        if (complete) {//
            percent=1;
            factor=0;
        }
        CGFloat yValue=[_yArr[i] floatValue];
        yValue*=percent;
        yValue+=factor*5;
        yValue=fmaxf(0,yValue);
        [newYarr addObject:[NSNumber numberWithFloat:yValue]];
    }
    [_chartLayer drawWithXArr:_xArr yArr:newYarr gap:50 maxY:self.maxY*2];
}

/**
 弹性计算公式
 
 @param x 弹性公式坐标图中的横坐标值，值域为[0,1] 公式来源：https://www.jianshu.com/p/cf9f600a5342
 @return 返回计算后的结果
 */
- (CGFloat)getSpringInterpolation:(CGFloat)x{
    return pow(2, -10 * x) * sin((x - self.stiffness / 4) * (2 * M_PI) / self.stiffness);
}

-(CGFloat)gap{
    if (_gap==0) {
        _gap=50;
    }
    return _gap;
}

-(UIColor *)pointColor{
    if (!_pointColor) {
        _pointColor=[UIColor whiteColor];
    }
    return _pointColor;
}

-(NSTimeInterval)unitDuration{
    if (_unitDuration==0) {
        _unitDuration=0.5;
    }
    return _unitDuration;
}

-(NSTimeInterval)animationIntervalDuration{
    if (_animationIntervalDuration==0) {
        _animationIntervalDuration=0.1;
    }
    return _animationIntervalDuration;
}

-(CGFloat)stiffness{
    if (_stiffness==0) {
        _stiffness=0.4;
    }
    return _stiffness;
}

-(int)seperateLineCount{
    if (_seperateLineCount==0) {
        _seperateLineCount=5;
    }
    return _seperateLineCount;
}

-(CGFloat)maxY{
    if (_maxY==0) {
        _maxY=[[_yArr valueForKeyPath:@"@max.floatValue"] floatValue];
    }
    return _maxY;
}

-(NSMutableArray *)yTitleLayers{
    if (!_yTitleLayers) {
        _yTitleLayers=[NSMutableArray array];
    }
    return _yTitleLayers;
}

@end
