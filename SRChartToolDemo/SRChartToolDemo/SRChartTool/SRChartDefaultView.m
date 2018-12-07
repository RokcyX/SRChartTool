//
//  SRChartDefaultView.m
//  SRChartToolDemo
//
//  Created by 周家民 on 2017/12/29.
//  Copyright © 2017年 starrain. All rights reserved.
//

#import "SRChartDefaultView.h"

@interface SRChartDefaultView()



@end

@implementation SRChartDefaultView{
    NSArray *_xTitleArr;
}

-(void)showWithPath:(UIBezierPath *)path{
    _chartLayer.path=path.CGPath;
    _chartLayer.fillColor=self.fillColor.CGColor;
}

+(CGSize)sizeWithString:(NSString *)str maxSize:(CGSize)maxSize font:(UIFont *)font{
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

-(instancetype)initWithFrame:(CGRect)frame{
    if (self=[super initWithFrame:frame]) {
        _chartLayer=[CAShapeLayer layer];
        [self.layer addSublayer:_chartLayer];
        [self setBackgroundColor:[UIColor clearColor]];
        _chartLayer.transform=CATransform3DMakeRotation(M_PI, 1, 0, 0);//纵向翻转，因为y轴的正方向是向下的，所以绘图的时候是颠倒的需要翻转
    }
    return self;
}

-(void)layoutSubviews{
    [super layoutSubviews];
    _chartLayer.frame=CGRectMake(0, 20, self.frame.size.width, self.frame.size.height-20);
}

-(CGPoint)drawWithPath:(UIBezierPath*)path index:(int)index prePoint:(CGPoint)prePoint nextPoint:(CGPoint)nextPoint currentPercent:(CGFloat)currentPercent springPercent:(CGFloat)springPercent{
    [path moveToPoint:nextPoint];
    CGFloat radius=self.pointRadius*currentPercent+self.pointRadius*springPercent;
    radius=fmaxf(0, radius);
    [path addArcWithCenter:nextPoint radius:radius startAngle:0 endAngle:M_PI*2 clockwise:YES];
    return nextPoint;
}

-(void)didClickWithPoint:(CGPoint)point valueStr:(NSString *)valueStr{
    self.showValueView.hidden=NO;
    CGSize size=[SRChartDefaultView sizeWithString:valueStr maxSize:CGSizeMake(MAXFLOAT, MAXFLOAT) font:self.showValueView.font];
    size=CGSizeMake(fmaxf(40,size.width+10), size.height+5);
    CGPoint position=CGPointMake(point.x+5, point.y-size.height-5);
    self.showValueView.frame=CGRectMake(position.x, position.y, size.width, size.height);
    self.showValueView.text=valueStr;
    CGAffineTransform transform=CGAffineTransformMakeRotation(M_PI_4);
    self.showValueView.transform=transform;
    [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:0.5 initialSpringVelocity:0.5 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.showValueView.transform=CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
        
    }];
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    CGPoint touchPoint=[[touches anyObject] locationInView:self];
    int index=(touchPoint.x/self.gap)-1;
    if (index>=0&&self.delegate) {
        NSString *valueStr=[self.delegate valueForIndex:index];
        CGFloat y=[self.delegate yForIndex:index];
        [self didClickWithPoint:CGPointMake((index+1)*self.gap, y) valueStr:valueStr];
    }
}

-(void)drawXTitleWithXTitleArr:(NSArray *)xTitleArr{
    _xTitleArr=xTitleArr;
    [self setNeedsDisplay];
}

-(void)drawRect:(CGRect)rect{
    [super drawRect:rect];
    
    CGFloat lastMaxX=0;
    for (int i=0;i<_xTitleArr.count;i++){
        NSString *xTitle=_xTitleArr[i];
        CGSize titleSize=[SRChartDefaultView sizeWithString:xTitle maxSize:CGSizeMake(MAXFLOAT, MAXFLOAT) font:self.xTitleFont];
        CGFloat x=(i+1)*self.gap-0.5*titleSize.width;//值的x坐标，需要根据x的字符串长度做偏移
        CGPoint titlePosition=CGPointMake(x, self.frame.size.height-titleSize.height);
        CGRect strFrame=CGRectMake(titlePosition.x, titlePosition.y, titleSize.width, titleSize.height);
        
        if (i!=0&&(lastMaxX+3)>strFrame.origin.x) {
            continue;
        }
        lastMaxX=CGRectGetMaxX(strFrame);
        
        [xTitle drawInRect:strFrame withAttributes:@{NSForegroundColorAttributeName:self.xTitleColor,NSFontAttributeName:self.xTitleFont}];
    }
}

-(UILabel *)showValueView{
    if (!_showValueView) {
        _showValueView=[[UILabel alloc] init];
        _showValueView.layer.anchorPoint=CGPointMake(0, 1);
        _showValueView.backgroundColor=[UIColor orangeColor];
        _showValueView.textColor=[UIColor whiteColor];
        _showValueView.layer.cornerRadius=5;
        _showValueView.layer.masksToBounds=YES;
        _showValueView.textAlignment=NSTextAlignmentCenter;
        [self addSubview:_showValueView];
    }
    return _showValueView;
}

-(CGFloat)pointRadius{
    if (_pointRadius==0) {
        _pointRadius=5;
    }
    return _pointRadius;
}

-(UIColor *)pointColor{
    if (!_pointColor) {
        _pointColor=[UIColor whiteColor];
    }
    return _pointColor;
}

-(UIColor *)fillColor{
    if (!_fillColor) {
        _fillColor=[UIColor whiteColor];
    }
    return _fillColor;
}

-(UIColor *)xTitleColor{
    if (!_xTitleColor) {
        _xTitleColor=[UIColor whiteColor];
    }
    return _xTitleColor;
}

-(UIFont *)xTitleFont{
    if(!_xTitleFont){
        _xTitleFont=[UIFont systemFontOfSize:11];
    }
    return _xTitleFont;
}

-(CGFloat)gap{
    if (_gap==0) {
        _gap=50;
    }
    return _gap;
}





@end


