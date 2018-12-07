//
//  SRChartBarView.m
//  SRChartToolDemo
//
//  Created by 周家民 on 2018/1/8.
//  Copyright © 2018年 starrain. All rights reserved.
//

#import "SRChartBarView.h"

@implementation SRChartBarView

-(CGFloat)barWidth{
    if (_barWidth==0) {
        _barWidth=10;
    }
    return _barWidth;
}

-(CGPoint)drawWithPath:(UIBezierPath *)path index:(int)index prePoint:(CGPoint)prePoint nextPoint:(CGPoint)nextPoint currentPercent:(CGFloat)currentPercent springPercent:(CGFloat)springPercent{
    CGPoint startPoint=CGPointMake(nextPoint.x-0.5*self.barWidth, 20);
    CGFloat y=fmaxf(20,nextPoint.y*currentPercent+springPercent*nextPoint.y);
    [path moveToPoint:startPoint];
    [path addLineToPoint:CGPointMake(startPoint.x, y)];
    [path addLineToPoint:CGPointMake(startPoint.x+self.barWidth, y)];
    [path addLineToPoint:CGPointMake(startPoint.x+self.barWidth, 20)];
    [path addLineToPoint:startPoint];
    return CGPointMake(prePoint.x, y);
}

@end
