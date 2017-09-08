//
//  ViewController.m
//  ScrollScroll
//
//  Created by 美融城 on 2017/9/7.
//  Copyright © 2017年 美融城. All rights reserved.
//

#import "ViewController.h"
#import "YYGestureRecognizer.h"
#import "ScrollTableViewCell.h"
#define ScreenWidth [UIScreen mainScreen].bounds.size.width
#define ScreenHeight [UIScreen mainScreen].bounds.size.height
//虚假的悬浮效果
static CGFloat floatViewHeight = 30.0;

static CGFloat navHeitht = 64;
// 这个系数根据自己喜好设置大小，=屏幕视图滑动距离/手指滑动距离
#define  moveScale 2


@interface ViewController ()<UITableViewDelegate,UITableViewDataSource,UIGestureRecognizerDelegate>
@property (nonatomic,weak)UIScrollView *scroll;
@property (nonatomic, strong) NSArray *titles;
@property (nonatomic,weak)UITableView *insetTableView;
@property (nonatomic,assign)CGFloat tableY;
@property (nonatomic,assign)CGFloat tableStartY;
@property (nonatomic,assign)CGFloat scrollY;
@property (nonatomic,assign)CGFloat scrollStartY;

//tableview 的y值 在scrollview中的位置
@property (nonatomic,assign)CGFloat tableFrameY;
@end

@implementation ViewController

- (void)viewDidLoad {

    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"ScrollScroll";
// 有导航最上部视图是scrollview 内部空间位置会下移，设置这个属性后不下移。
    if ([self respondsToSelector:@selector(setAutomaticallyAdjustsScrollViewInsets:)]) {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }

    UIScrollView  *scroll = [[UIScrollView alloc]initWithFrame:CGRectMake(0,navHeitht, ScreenWidth, ScreenHeight-navHeitht)];
    scroll.backgroundColor = [UIColor colorWithRed:0.4 green:0.3 blue:0.2 alpha:1.0];;
   

    [self.view addSubview:scroll];
    self.scroll = scroll;
    
   
    //根据需求设置tableview的y值 暂写scroll高的2分之一
     self.tableFrameY = self.scroll.frame.size.height/2;
    
    UIImageView *headImage = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, self.tableFrameY-floatViewHeight)];
    headImage.image = [UIImage imageNamed:@"scrollHead"];
    headImage.contentMode = UIViewContentModeScaleAspectFill;
    [self.scroll addSubview:headImage];
    
    NSArray *titles = @[@"ICO详情",@"央行放大招",@"比特币会涨",@"神秘中本村"];
    self.titles = titles;
     UISegmentedControl *segment = [[UISegmentedControl alloc] initWithFrame:CGRectMake(5, scroll.bounds.size.height/2-30, self.scroll.bounds.size.width - 10, 30)];
     [segment addTarget:self action:@selector(segmentValueChanged:) forControlEvents:UIControlEventValueChanged];
    for (NSString *title in _titles) {
        [segment insertSegmentWithTitle:title atIndex:segment.numberOfSegments animated:false];
    }
    segment.selectedSegmentIndex = 0;
    [self.scroll addSubview:segment];
    
    UITableView *insetTable = [[UITableView alloc]initWithFrame:CGRectMake(0,self.tableFrameY, self.view.bounds.size.width, ScreenHeight-navHeitht-floatViewHeight)];
    insetTable.backgroundColor = [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1.0];
    
    insetTable.dataSource = self;
    insetTable.delegate = self;
    
  
    [self.scroll addSubview:insetTable];
    self.insetTableView = insetTable;
    
//github搜索 yykit 或yytext 里面有 yygestureRecognizer这个类，这个类需要做一些修改，    // 在yygesture中所有触摸事件方法里 加上super的方法，原文件里没有，否则响应链条终端，scroll或tablew的按钮点击事件不执行。
    //这个类原文件继承于UIGestureRecognizer， 改为继承于UIPanGestureRecognizer 否则点击事件不执行。
    //运行效果详见我的demo

    YYGestureRecognizer *yyges = [YYGestureRecognizer new];
    yyges.action = ^(YYGestureRecognizer *gesture, YYGestureRecognizerState state){
        if (state != YYGestureRecognizerStateMoved) return ;
        
        if (CGRectContainsPoint(self.insetTableView.frame, gesture.startPoint)) {
          
          //滑动tableview
            [self tableScrollWithGesture:gesture];
           
           
  
        }else{
            
            //滑动scrollview
            [self scrollScrollWithGesture:gesture];
            
        }
  
    };
    //必须给scroll 加上手势  不要给view加，不然滑动tablew的时候会错误判断去滑动scroll。
    [self.scroll addGestureRecognizer:yyges];
    
    //实现手势代理，解决交互冲突
    yyges.delegate = self;
     scroll.contentSize = CGSizeMake(self.view.bounds.size.width, self.tableFrameY+self.insetTableView.frame.size.height);

}
//解决手势按钮冲突
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    //如果是 segment或scroll上的其他按钮，取消手势
    if([NSStringFromClass(touch.view.superclass) isEqualToString:@"UIControl"]){
        return NO;
    }


    //
        return YES;
        }
//
- (void)segmentValueChanged:(UISegmentedControl *)segment {
//scroll 到底部
    CGFloat offset = self.scroll.contentSize.height - self.insetTableView.bounds.size.height-floatViewHeight;
    if (offset > 0)
    {
        self.scrollY = offset;
        [self.scroll setContentOffset:CGPointMake(0, offset) animated:YES];
    }
    //TableView到顶部
    self.tableY = 0;
    [self.insetTableView setContentOffset:CGPointMake(0, self.tableY) animated:YES];
}
- (void)tableScrollWithGesture:(YYGestureRecognizer *)gesture{
    CGFloat scrolly;
    
    if (self.tableStartY != gesture.startPoint.y) {
        scrolly = -(gesture.currentPoint.y-gesture.startPoint.y) ;
    }else{
        scrolly =  -(gesture.currentPoint.y-gesture.lastPoint.y) ;
    }
    self.tableStartY = gesture.startPoint.y;
    
    self.tableY += scrolly*moveScale;
    
    //为了显示底部超出屏幕的tableview那部分 滑动scrollview 此时tablewview已经滑动到了底部
    if (self.tableY> self.insetTableView.contentSize.height-self.insetTableView.bounds.size.height){
        self.scrollY += self.tableY-(self.insetTableView.contentSize.height-self.insetTableView.bounds.size.height);
        
        //tablewview滑动到底部就不要滑了
        self.tableY = self.insetTableView.contentSize.height-self.insetTableView.bounds.size.height;
        
    //scrollview 滑动到了底部就不要滑动了
        if (self.scrollY> self.scroll.contentSize.height-self.insetTableView.bounds.size.height-floatViewHeight){
            self.scrollY = self.scroll.contentSize.height-self.insetTableView.bounds.size.height-floatViewHeight;
            //如果scrollview意外的contentsize 小于自己的大小，scrollview就不要滑了
            if (self.scrollY<0) {
                self.scrollY = 0;
            }
            
        }
        [self.scroll setContentOffset:CGPointMake(0, self.scrollY) animated:YES];
        
        //如果tablewview的cell过少或行高过少致使其contentsize 小于自己的大小，tableview就不要滑了
        if (self.tableY<0) {
            self.tableY = 0;
        }
        
    }
    
    
    //如果滑到了tableview的最上部，停止滑动tablewview,  如果此时scrollview 没有在最上部就滑动scrollview到最上部
    if (self.tableY<0){
        self.scrollY += self.tableY;
        
       //scroll已经在最上部了，scroll就不滑了
        if (self.scrollY<0) {
            self.scrollY = 0;
        }
        
        NSLog(@"scroll  %lf",self.scrollY);
        [self.scroll setContentOffset:CGPointMake(0, self.scrollY) animated:YES];
        
         //停止滑动tablewview
        self.tableY = 0;
        
    }
    NSLog(@"table  %lf",self.tableY);
    
    
    [self.insetTableView setContentOffset:CGPointMake(0, self.tableY) animated:YES];
}
- (void)scrollScrollWithGesture:(YYGestureRecognizer *)gesture{
    CGFloat scrolly;
    
    if (self.scrollStartY != gesture.startPoint.y) {
        scrolly = -(gesture.currentPoint.y-gesture.startPoint.y) ;
    }else{
        scrolly =  -(gesture.currentPoint.y-gesture.lastPoint.y) ;
    }
    self.scrollStartY = gesture.startPoint.y;
    
    self.scrollY += scrolly*moveScale;
    
    //如果滑到了scroll的底部就不要滑了
    if (self.scrollY> self.scroll.contentSize.height-self.insetTableView.bounds.size.height-floatViewHeight){
        self.scrollY = self.scroll.contentSize.height-self.insetTableView.bounds.size.height-floatViewHeight;
        //如果scrollview意外的contentsize 小于自己的大小，scrollview就不要滑了
        if (self.scrollY<0) {
            self.scrollY = 0;
        }
    }
    //如果滑到了scroll顶部就不要滑了
    if (self.scrollY<0){
        self.scrollY = 0;
    }
    NSLog(@"scroll  %lf",self.scrollY);
    
    
    [self.scroll setContentOffset:CGPointMake(0, self.scrollY) animated:YES];
    
}


#pragma mark - 展示tableview的代理

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 70;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 10;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    ScrollTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"ScrollTableViewCell"];
    if (!cell)
    {
        [tableView registerNib:[UINib nibWithNibName:@"ScrollTableViewCell" bundle:nil] forCellReuseIdentifier:@"ScrollTableViewCell"];
        cell = [tableView dequeueReusableCellWithIdentifier:@"ScrollTableViewCell"];
    }
    
        cell.backgroundColor = [UIColor clearColor];
      
  
   
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.Titletext.text = [NSString stringWithFormat:@"\t第%zd行",indexPath.row];
    cell.detailText.text = @"滑屏呀滑屏呀划呀";
    cell.detailText.textColor = self.navigationController.navigationBar.tintColor;
    cell.indexPath = indexPath;
    
    cell.selectCellBlock = ^(NSIndexPath *indexPath) {
        NSLog(@"点击了第%ld组%ld行",indexPath.section,indexPath.row);
    };
    
    return cell;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return 3;
}
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *v = [[UIView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, 50)];
    v.backgroundColor = [UIColor orangeColor];
    UILabel *l = [[UILabel alloc]initWithFrame:v.bounds];
    l.text =[NSString stringWithFormat:@"tableview的组头%ld",section];
    l.textColor = [UIColor whiteColor];
    l.textAlignment = NSTextAlignmentCenter;
    [v addSubview:l];
    return v;
}
//组头高
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    
    return 50;
    
    
}
//这个方法不可用了，除非点击了cellcontenview之外的区域 只能同过加按钮的方式接受点击事件
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"点击了第%ld行",indexPath.row);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
