//
//  XWPullDownMenu.h
//  XWPullDownMenuDemo
//
//  Created by weixuewu on 2016/10/28.
//  Copyright © 2016年 weixuewu. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^DidSelectedSuccess)(NSInteger column, NSInteger row);

@interface XWPullDownMenu : UIView

@property (nonatomic, strong) UIColor *indicatorColor;
@property (nonatomic, strong) UIColor *textColor;
@property (nonatomic, strong) UIColor *seletedTextColor;
@property (nonatomic, strong) UIColor *separatorColor;
@property (nonatomic, strong) UIColor *tableViewCellSeparatorColor;
@property (nonatomic, strong) UIColor *selectedTableViewCellSeparatorColor;

-(instancetype)initWithTitle:(NSArray *)titles data:(NSArray *)data;

-(void)selectFinishBlock:(DidSelectedSuccess)block;

@end
