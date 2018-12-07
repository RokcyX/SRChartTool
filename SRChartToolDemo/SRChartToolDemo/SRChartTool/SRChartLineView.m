//
//  SRChartLineView.m
//  SRChartToolDemo
//
//  Created by 周家民 on 2018/12/7.
//  Copyright © 2018 starrain. All rights reserved.
//

#import "SRChartLineView.h"

@implementation SRChartLineView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.lineWidth = 2;
    }
    return self;
}

-(CGPoint)drawWithPath:(UIBezierPath *)path index:(int)index prePoint:(CGPoint)prePoint nextPoint:(CGPoint)nextPoint currentPercent:(CGFloat)currentPercent springPercent:(CGFloat)springPercent{
    
    CGFloat nextPointY=nextPoint.y;
    nextPointY*=currentPercent;
    nextPointY+=springPercent*(nextPoint.y);
    nextPointY=fmaxf(20,nextPointY);
    nextPoint=CGPointMake(nextPoint.x, nextPointY);
    [path addLineToPoint:nextPoint];
    return nextPoint;
}

@end
