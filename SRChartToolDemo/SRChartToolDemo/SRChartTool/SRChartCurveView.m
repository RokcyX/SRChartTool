//
//  SRChartCurveView.m
//  SRChartToolDemo
//
//  Created by 周家民 on 2018/1/2.
//  Copyright © 2018年 starrain. All rights reserved.
//

#import "SRChartCurveView.h"

@interface SRChartCurveView()

@property(nonatomic,strong)NSMutableArray *pointLayers;

@property (nonatomic,strong) CAShapeLayer *pointContainerLayer;

@property (nonatomic,strong) UIBezierPath *pointPath;

@property (nonatomic,assign) NSInteger pointCount;

@end

@implementation SRChartCurveView

-(BOOL)isClosePath{
    return YES;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.pointContainerLayer = [CAShapeLayer layer];
        [self.layer addSublayer:self.pointContainerLayer];
        self.pointContainerLayer.transform=CATransform3DMakeRotation(M_PI, 1, 0, 0);
        self.pointContainerLayer.fillColor = self.pointColor.CGColor;
        self.pointPath = [UIBezierPath bezierPath];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.pointContainerLayer.frame = [[self.chartLayerList firstObject] frame];
   
}

- (void)showWithPathList:(NSArray<UIBezierPath *> *)pathList {
    [super showWithPathList:pathList];
    self.pointContainerLayer.path = self.pointPath.CGPath;
    self.pointPath = [UIBezierPath bezierPath];
}

-(CGPoint)drawWithPath:(UIBezierPath *)path index:(int)index prePoint:(CGPoint)prePoint nextPoint:(CGPoint)nextPoint currentPercent:(CGFloat)currentPercent springPercent:(CGFloat)springPercent{
    
    CGFloat nextPointY=nextPoint.y;
    
    nextPointY*=currentPercent;
    nextPointY+=springPercent*(nextPoint.y) ;
    nextPointY=fmaxf(20,nextPointY);
    nextPoint=CGPointMake(nextPoint.x, nextPointY);
    CGFloat controlPointX=0.5*(nextPoint.x-prePoint.x)+prePoint.x;
    CGPoint cp1=CGPointMake(controlPointX, prePoint.y);
    CGPoint cp2=CGPointMake(controlPointX, nextPoint.y);
    [path addCurveToPoint:nextPoint controlPoint1:cp1 controlPoint2:cp2];
    [self.pointPath moveToPoint: nextPoint];
    [self.pointPath addArcWithCenter:nextPoint radius:self.pointRadius startAngle:0 endAngle:2 * M_PI clockwise:YES];
    return nextPoint;
}

-(NSMutableArray *)pointLayers{
    if (!_pointLayers) {
        _pointLayers=[NSMutableArray array];
    }
    return _pointLayers;
}

-(CALayer*)createPointLayer{
    CALayer *pointLayer=[CALayer layer];
    pointLayer.backgroundColor=self.pointColor.CGColor;
    pointLayer.cornerRadius=self.pointRadius;
    pointLayer.frame=CGRectMake(0, 0, self.pointRadius, self.pointRadius);
    return pointLayer;
}

@end
