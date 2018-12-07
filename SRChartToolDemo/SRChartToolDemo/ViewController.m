//
//  ViewController.m
//  SRChartToolDemo
//
//  Created by 周家民 on 2017/12/27.
//  Copyright © 2017年 starrain. All rights reserved.
//

#import "ViewController.h"
#import "SRChartView.h"
#import "SRChartDefaultView.h"
#import "SRChartContainerView.h"
#import "SRChartBarView.h"
@interface ViewController ()

@end

@implementation ViewController{
    
    SRChartContainerView *containerView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor grayColor]];
    
    containerView=[[SRChartContainerView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 200)];
    [self.view addSubview:containerView];
    
    SRChartCurveView *chartView=[[SRChartCurveView alloc] init];
    containerView.chartView=chartView;
    
}
- (IBAction)generate:(UIButton *)sender {
    
    NSMutableArray *xValueArr=[NSMutableArray array];
    NSMutableArray *yValueArr=[NSMutableArray array];
    
    for(int i=1;i<100;i++){
        [xValueArr addObject:[NSString stringWithFormat:@"%d",i]];
        [yValueArr addObject:[NSNumber numberWithInt:arc4random()%100]];
    }
    
    containerView.xValueArr=xValueArr;
    containerView.yValueArr=yValueArr;
    [containerView showChartWithStiffness:0.4];
}
    
- (IBAction)typeChange:(UISegmentedControl *)sender {
    switch ([sender selectedSegmentIndex]) {
        case 0:
        containerView.chartView=[[SRChartDefaultView alloc] init];
        break;
        case 1:
        containerView.chartView=[[SRChartCurveView alloc] init];
        break;
        default:
        containerView.chartView=[[SRChartBarView alloc] init];
        break;
    }
}
    
@end
