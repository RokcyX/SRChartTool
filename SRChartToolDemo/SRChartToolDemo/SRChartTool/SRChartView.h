//
//  SRChartView.h
//  SRChartToolDemo
//
//  Created by 周家民 on 2017/12/27.
//  Copyright © 2017年 starrain. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SRChartLayer:CAShapeLayer

/**
 根据横纵坐标集合绘图

 @param xArr 横坐标集合
 @param yArr 纵坐标集合
 */
-(void)drawWithXArr:(NSArray*)xArr yArr:(NSArray*)yArr gap:(CGFloat)gap maxY:(CGFloat)maxY;

@end

typedef NS_ENUM(NSInteger,SRChartViewType) {
    SRChartViewTypeCurve=0
};

@interface SRChartView : UIScrollView

/**
 图表类型
 */
@property(nonatomic,assign)SRChartViewType chartType;

/**
 横坐标集合
 */
@property(nonatomic,strong)NSArray *xArr;

/**
 纵坐标集合
 */
@property(nonatomic,strong)NSArray *yArr;

/**
 横坐标间隔
 */
@property(nonatomic,assign)CGFloat gap;

/**
 坐标点的颜色，默认白色
 */
@property(nonatomic,strong)UIColor *pointColor;

/**
 单个值执行的动画时间
 */
@property(nonatomic,assign)NSTimeInterval unitDuration;

/**
 动画之间的间隔时间
 */
@property(nonatomic,assign)NSTimeInterval animationIntervalDuration;

/**
 刚度系数，此值越大，弹性越小
 */
@property(nonatomic,assign)CGFloat stiffness;

/**
 分割线数量，默认为5
 */
@property(nonatomic,assign)int seperateLineCount;

/**
 绘制图表

 @param animate 是否显示动画
 */
-(void)drawWithAnimate:(BOOL)animate;

@end
