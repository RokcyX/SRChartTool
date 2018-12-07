//
//  SRChartContainerView.h
//  SRChartToolDemo
//
//  Created by 周家民 on 2018/1/2.
//  Copyright © 2018年 starrain. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SRChartCurveView.h"

@interface SRChartContainerView : UIView

@property(nonatomic,strong)SRChartDefaultView *chartView;

@property(nonatomic,strong)NSArray *xValueArr;

@property(nonatomic,strong)NSArray *yValueArr;

/**
 纵坐标最大值
 */
@property(nonatomic,assign)CGFloat yMaxValue;

/**
 坐标点间的间隔，默认为50
 */
@property(nonatomic,assign)CGFloat gap;

/**
 最大间距，默认50
 */
@property(nonatomic,assign)CGFloat maxGap;

/**
 最小间距，默认5
 */
@property(nonatomic,assign)CGFloat minGap;

/**
 分割线数量，默认为5
 */
@property(nonatomic,assign)int seperateLineCount;

/**
 单元动画持续时间，也就是每个值的动画持续时间
 */
@property(nonatomic,assign)NSTimeInterval unitAnimationDuration;

/**
 动画间隙持续时间，即前一个单元动画开始后，animationIntervalDuration秒之后执行后一个动画，以此类推
 */
@property(nonatomic,assign)NSTimeInterval animationIntervalDuration;

/**
 显示图表

 @param animated 是否启用动画
 */
-(void)showChartWithAnimated:(BOOL)animated;

/**
 显示图表

 @param stiffness 刚度系数，此值越大，弹性越小
 */
-(void)showChartWithStiffness:(CGFloat)stiffness;

@end
