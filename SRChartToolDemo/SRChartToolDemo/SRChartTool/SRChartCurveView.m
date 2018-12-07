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

@end

@implementation SRChartCurveView

-(BOOL)isClosePath{
    return YES;
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
    
    CALayer *pointLayer;
    if (self.pointLayers.count<=index) {
        pointLayer=[self createPointLayer];
        [self.chartLayer addSublayer:pointLayer];
        [self.pointLayers addObject:pointLayer];
    }
    pointLayer=[self.pointLayers objectAtIndex:index];

    pointLayer.position=nextPoint;
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
