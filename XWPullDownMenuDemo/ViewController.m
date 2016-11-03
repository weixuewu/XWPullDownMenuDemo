//
//  ViewController.m
//  XWPullDownMenuDemo
//
//  Created by weixuewu on 2016/10/28.
//  Copyright © 2016年 weixuewu. All rights reserved.
//

#import "ViewController.h"
#import "XWPullDownMenu.h"

@interface ViewController ()<UITableViewDataSource,UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableview;
@property (strong, nonatomic) XWPullDownMenu *pullMenu;
@property (strong, nonatomic) NSArray *titles;
@property (strong, nonatomic) NSMutableArray *data;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.view.backgroundColor = [UIColor colorWithRed:0.96 green:0.96 blue:0.96 alpha:1.0];
    
    XWMenuModel *model1 = [[XWMenuModel alloc]initWithTitle:@"所在地" Id:@"0"];
    XWMenuModel *model2 = [[XWMenuModel alloc]initWithTitle:@"筛选" Id:@"0"];
    XWMenuModel *model3 = [[XWMenuModel alloc]initWithTitle:@"排序" Id:@"0"];
    self.titles = @[model1,model2,model3];

    NSMutableArray *arr = [NSMutableArray array];
    for (int i=0; i<20; i++) {
        XWMenuModel *model = [[XWMenuModel alloc]initWithTitle:[NSString stringWithFormat:@"北京%d",i] Id:[NSString stringWithFormat:@"%d",i]];
        [arr addObject:model];
    }
    
    XWMenuModel *model11 = [[XWMenuModel alloc]initWithTitle:@"三甲" Id:@"1"];
    XWMenuModel *model12 = [[XWMenuModel alloc]initWithTitle:@"三级" Id:@"2"];
    XWMenuModel *model13 = [[XWMenuModel alloc]initWithTitle:@"二甲" Id:@"3"];
    XWMenuModel *model14 = [[XWMenuModel alloc]initWithTitle:@"二乙" Id:@"4"];
    XWMenuModel *model15 = [[XWMenuModel alloc]initWithTitle:@"其他" Id:@"5"];
    NSMutableArray *arr1 = [NSMutableArray arrayWithObjects:model11,model12,model13,model14,model15, nil];

    XWMenuModel *model21 = [[XWMenuModel alloc]initWithTitle:@"医院等级" Id:@"1"];
    XWMenuModel *model22 = [[XWMenuModel alloc]initWithTitle:@"医院星级" Id:@"2"];
    NSMutableArray *arr2 = [NSMutableArray arrayWithObjects:model21,model22, nil];

    self.data = [NSMutableArray arrayWithArray:@[arr,arr1,arr2]];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        return 50;
    }else{
        return 10;
    }
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    if (section == 0) {
        if (!self.pullMenu) {
            self.pullMenu = [[XWPullDownMenu alloc]initWithTitle:self.titles data:self.data];
        }
        
        [self.pullMenu selectFinishBlock:^(NSInteger column, XWMenuModel *model) {
            
            NSLog(@"%@",model.title);
        }];
        
        return self.pullMenu;
    }else{
        UIView *view = [[UIView alloc]init];
        view.backgroundColor = [UIColor colorWithRed:0.96 green:0.96 blue:0.96 alpha:1.0];
        return view;
    }
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0) {
        return 0;
    }
    return 10;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    
    cell.textLabel.text = [NSString stringWithFormat:@"index: %zd",indexPath.row];
    
    return cell;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
