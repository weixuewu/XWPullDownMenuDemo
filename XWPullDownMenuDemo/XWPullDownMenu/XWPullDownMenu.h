//
//  XWPullDownMenu.h
//  XWPullDownMenuDemo
//
//  Created by weixuewu on 2016/10/28.
//  Copyright © 2016年 weixuewu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface XWMenuModel : NSObject

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *Id;

-(instancetype)initWithTitle:(NSString *)title Id:(NSString *)Id;

@end

typedef void(^DidSelectedSuccess)(NSInteger column, XWMenuModel *model);

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
