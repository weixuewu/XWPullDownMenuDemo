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
    self.titles = @[@"所在地",@"筛选",@"排序"];
    self.data = [NSMutableArray arrayWithArray:@[@[@"北京1",@"北京2",@"北京3",@"北京4",@"北京5",@"北京6",@"北京7"],@[@"一甲",@"二甲",@"三甲",@"四甲"],@[@"等级",@"星级"]]];
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
        
        [self.pullMenu selectFinishBlock:^(NSInteger column, NSInteger row) {
            NSLog(@"%@",self.data[column][row]);
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
