//
//  ViewController.m
//  SRChartToolDemo
//
//  Created by 周家民 on 2017/12/27.
//  Copyright © 2017年 starrain. All rights reserved.
//

#import "ViewController.h"
#import "SRChartDefaultView.h"
#import "SRChartContainerView.h"
#import "SRChartBarView.h"
#import "SRChartLineView.h"
@interface ViewController ()

@end

@implementation ViewController{
    
    SRChartContainerView *containerView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    containerView=[[SRChartContainerView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 200)];
    [self.view addSubview:containerView];
    
    SRChartCurveView *chartView=[[SRChartCurveView alloc] init];
    containerView.chartView=chartView;
    
}



- (IBAction)generate:(UIButton *)sender {
    
    NSMutableArray *xValueArr=[NSMutableArray array];
    
    for(int i=1;i<100;i++){
        [xValueArr addObject:[NSString stringWithFormat:@"%d月%d日",i,i]];
    }
    NSMutableArray *datas = [NSMutableArray array];
    for (int i = 0; i < 2; i++) {
        NSMutableArray *yValueArr = [NSMutableArray array];
        for (int i = 1; i < 100 ; i ++) {
            [yValueArr addObject:[NSNumber numberWithInt:arc4random()%10]];
        }
        [datas addObject:[yValueArr copy]];
    }
    containerView.chartView.fillColor = [UIColor clearColor];
    [containerView showChartWithXValueArr:xValueArr yValueArrList:[datas copy] lineColors:@[[UIColor colorWithRed:24/255.0 green:144/255.0 blue:255/255 alpha:1],[UIColor colorWithRed:47/255.0 green:194/255.0 blue:91/255.0 alpha:1]]];
}
    
- (IBAction)typeChange:(UISegmentedControl *)sender {
    switch ([sender selectedSegmentIndex]) {
        case 0:
        containerView.chartView=[[SRChartLineView alloc] init];
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
