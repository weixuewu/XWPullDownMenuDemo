//
//  XWPullDownMenu.m
//  XWPullDownMenuDemo
//
//  Created by weixuewu on 2016/10/28.
//  Copyright © 2016年 weixuewu. All rights reserved.
//

#import "XWPullDownMenu.h"

#define BackColor [UIColor whiteColor]
// 选中颜色加深
#define SelectColor [UIColor whiteColor]


@interface XWPullDownMenuCell : UITableViewCell
@property (nonatomic, strong) UILabel *line;
@end

@implementation XWPullDownMenuCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        [self setupView];
    }
    return self;
}

-(void)setupView{
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    self.line = [[UILabel alloc]init];
    self.line.backgroundColor = [UIColor lightGrayColor];
    self.line.frame = CGRectMake(15, CGRectGetMaxY(self.frame)-0.5, CGRectGetWidth(self.frame), 0.5);
    [self.contentView addSubview:self.line];
    self.line.translatesAutoresizingMaskIntoConstraints = NO;
    //子view的高度为0.5
    NSLayoutConstraint *contraint1 = [NSLayoutConstraint constraintWithItem:self.line attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationGreaterThanOrEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:0.5];
    //子view的左边缘离父view的左边缘15个像素
    NSLayoutConstraint *contraint2 = [NSLayoutConstraint constraintWithItem:self.line attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeLeft multiplier:1.0 constant:15.0];
    //子view的下边缘离父view的下边缘0个像素
    NSLayoutConstraint *contraint3 = [NSLayoutConstraint constraintWithItem:self.line attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0];
    //子view的右边缘离父view的右边缘0个像素
    NSLayoutConstraint *contraint4 = [NSLayoutConstraint constraintWithItem:self.line attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeRight multiplier:1.0 constant:0.0];
    //把约束添加到父视图上
    NSArray *array = [NSArray arrayWithObjects:contraint1, contraint2, contraint3, contraint4, nil];
    [self.contentView addConstraints:array];
    
}


@end

@interface XWPullDownMenu ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) NSMutableArray *titleArray;
@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, assign) NSInteger numMenu;

//layers array
@property (nonatomic, copy) NSArray *titleLayers;
@property (nonatomic, copy) NSArray *indicatorLayers;
@property (nonatomic, copy) NSArray *backgroundLayers;


@property (nonatomic, assign) NSInteger currentSelectedMenudIndex;
@property (nonatomic, assign) BOOL show;
@property (nonatomic, assign) BOOL hadSelected;
@property (nonatomic, assign) CGPoint origin;
@property (nonatomic, strong) UIView *backGroundView;
@property (nonatomic, strong) UIView *bottomShadow;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) CAShapeLayer *cursorLayer;

@property (nonatomic, copy) DidSelectedSuccess selectedComplition;

@end

@implementation XWPullDownMenu

-(instancetype)initWithTitle:(NSArray *)titles data:(NSArray *)data{
    
    self = [super initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 50)];
    if (self) {
        
        self.backgroundColor = [UIColor whiteColor];
        self.titleArray = [NSMutableArray arrayWithArray:titles];
        self.dataArray = [NSMutableArray arrayWithArray:data];
        
        [self setupView];
    }
    return self;
}

#pragma mark - getter
- (UIColor *)indicatorColor {
    if (!_indicatorColor) {
        _indicatorColor = [UIColor colorWithRed:0.60 green:0.60 blue:0.60 alpha:1.0];
    }
    return _indicatorColor;
}

- (UIColor *)textColor {
    if (!_textColor) {
        _textColor = [UIColor colorWithRed:0.20 green:0.20 blue:0.20 alpha:1.0];
    }
    return _textColor;
}

-(UIColor *)seletedTextColor{
    if (!_seletedTextColor) {
        _seletedTextColor = [UIColor colorWithRed:1.00 green:0.49 blue:0.55 alpha:1.0];
    }
    return _seletedTextColor;
}

- (UIColor *)separatorColor {
    if (!_separatorColor) {
        _separatorColor = [UIColor colorWithRed:0.93 green:0.93 blue:0.93 alpha:1.0];
    }
    return _separatorColor;
}

-(UIColor *)tableViewCellSeparatorColor{
    if (!_tableViewCellSeparatorColor) {
        _tableViewCellSeparatorColor = [UIColor colorWithRed:0.93 green:0.93 blue:0.93 alpha:1.0];
    }
    return _tableViewCellSeparatorColor;
}

-(UIColor *)selectedTableViewCellSeparatorColor{
    if (!_selectedTableViewCellSeparatorColor) {
        _selectedTableViewCellSeparatorColor = [UIColor colorWithRed:1.00 green:0.49 blue:0.55 alpha:1.0];
    }
    return _selectedTableViewCellSeparatorColor;
}

-(void)setupView{
    
    //顶部边框
    CAShapeLayer *borderShapeLayer = [CAShapeLayer new];
    borderShapeLayer.strokeColor = self.tableViewCellSeparatorColor.CGColor;
    borderShapeLayer.lineWidth = 1.0;
    UIBezierPath *bezierPath = [UIBezierPath new];
    [bezierPath moveToPoint:CGPointMake(0, 0)];
    [bezierPath addLineToPoint:CGPointMake(CGRectGetWidth(self.frame), 0)];
    borderShapeLayer.path = bezierPath.CGPath;
    [self.layer addSublayer:borderShapeLayer];
   
    
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    _currentSelectedMenudIndex = -1;
    _show = NO;
    _hadSelected = NO;
    self.numMenu = self.titleArray.count;
    CGFloat interval = self.frame.size.width / self.numMenu;

    NSMutableArray *backgounds = [NSMutableArray array];
    NSMutableArray *indicators = [NSMutableArray array];
    NSMutableArray *titles = [NSMutableArray array];

    for (int i=0; i<self.numMenu; i++) {
        
        //backgroundLayer
        CGPoint bgLayerPosition = CGPointMake((i+0.5)*interval, self.frame.size.height/2);
        CALayer *bgLayer = [self createBgLayerWithColor:self.backgroundColor andPosition:bgLayerPosition];
        [self.layer addSublayer:bgLayer];
        [backgounds addObject:bgLayer];
        
        //title
        CGPoint titlePosition = CGPointMake( (i + 0.5) * interval , self.frame.size.height / 2);
        NSString *titleString = self.titleArray[i];
        CATextLayer *title = [self createTextLayerWithNSString:titleString withColor:self.textColor andPosition:titlePosition];
        [self.layer addSublayer:title];
        [titles addObject:title];
        
        //indicator
        CAShapeLayer *indicator = [self createIndicatorWithColor:self.indicatorColor andPosition:CGPointMake(titlePosition.x + title.bounds.size.width / 2 + 8, self.frame.size.height / 2 + 2)];
        [self.layer addSublayer:indicator];
        [indicators addObject:indicator];
        
        //separator
        if (i != self.numMenu - 1) {
            CGPoint separatorPosition = CGPointMake((i + 1) * interval, self.frame.size.height/2);
            CAShapeLayer *separator = [self createSeparatorLineWithColor:self.separatorColor andPosition:separatorPosition];
            [self.layer addSublayer:separator];
        }
    }
    
    self.titleLayers = [titles copy];
    self.indicatorLayers = [indicators copy];
    self.backgroundLayers = [backgounds copy];

    //self tapped
    self.backgroundColor = [UIColor whiteColor];
    UIGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(menuTapped:)];
    [self addGestureRecognizer:tapGesture];
    
    //background init and tapped
    _backGroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenSize.width, screenSize.height)];
    _backGroundView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.6];
    _backGroundView.opaque = NO;
    UIGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backgroundTapped:)];
    [_backGroundView addGestureRecognizer:gesture];
    
    //tableView init
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0 + self.frame.size.height, 0, 0) style:UITableViewStyleGrouped];
    self.tableView.rowHeight = 45;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
}


- (CALayer *)createBgLayerWithColor:(UIColor *)color andPosition:(CGPoint)position {
    CALayer *layer = [CALayer layer];
    
    layer.position = position;
    layer.bounds = CGRectMake(0, 0, self.frame.size.width/self.numMenu, self.frame.size.height-1);
    layer.backgroundColor = color.CGColor;
    
    return layer;
}

- (CATextLayer *)createTextLayerWithNSString:(NSString *)string withColor:(UIColor *)color andPosition:(CGPoint)point {
    
    CGFloat fontSize = 14.0;
    NSDictionary *dic = @{NSFontAttributeName: [UIFont systemFontOfSize:fontSize]};
    CGSize size = [string boundingRectWithSize:CGSizeMake(280, 0) options:NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:dic context:nil].size;

    
    CATextLayer *layer = [CATextLayer new];
    CGFloat sizeWidth = (size.width < (self.frame.size.width / self.numMenu) - 25) ? size.width : self.frame.size.width / self.numMenu - 25;
    layer.bounds = CGRectMake(0, 0, sizeWidth, size.height);
    layer.string = string;
    layer.fontSize = 14.0;
    layer.alignmentMode = kCAAlignmentCenter;
    layer.foregroundColor = color.CGColor;
    
    layer.contentsScale = [[UIScreen mainScreen] scale];
    
    layer.position = point;
    
    return layer;
}

//构造三角箭头图标
- (CAShapeLayer *)createIndicatorWithColor:(UIColor *)color andPosition:(CGPoint)point {
    CAShapeLayer *layer = [CAShapeLayer new];
    
    UIBezierPath *path = [UIBezierPath new];
    [path moveToPoint:CGPointMake(0, 0)];
    [path addLineToPoint:CGPointMake(4, 5)];
    [path addLineToPoint:CGPointMake(8, 0)];
    [path closePath];
    
    
    layer.path = path.CGPath;
    layer.lineWidth = 1.0;
    layer.fillColor = [UIColor clearColor].CGColor;//color.CGColor;
    
    layer.strokeColor = color.CGColor;
    layer.strokeEnd   = 0.64;
    
    CGPathRef bound = CGPathCreateCopyByStrokingPath(layer.path, nil, layer.lineWidth, kCGLineCapButt, kCGLineJoinMiter, layer.miterLimit);
    layer.bounds = CGPathGetBoundingBox(bound);
    
    CGPathRelease(bound);
    
    layer.position = point;
    
    return layer;
}

//竖条分割线
- (CAShapeLayer *)createSeparatorLineWithColor:(UIColor *)color andPosition:(CGPoint)point {
    CAShapeLayer *layer = [CAShapeLayer new];
    
    UIBezierPath *path = [UIBezierPath new];
    [path moveToPoint:CGPointMake(1,self.frame.size.height/4)];
    [path addLineToPoint:CGPointMake(1, self.frame.size.height*3/4)];
    
    layer.path = path.CGPath;
    layer.lineWidth = 1.0;
    layer.strokeColor = color.CGColor;
    
    CGPathRef bound = CGPathCreateCopyByStrokingPath(layer.path, nil, layer.lineWidth, kCGLineCapButt, kCGLineJoinMiter, layer.miterLimit);
    layer.bounds = CGPathGetBoundingBox(bound);
    
    CGPathRelease(bound);
    
    layer.position = point;
    
    return layer;
}

//构造下标箭头指示符 类似游标

- (CAShapeLayer *)createCursorWithIndex:(NSInteger)index color:(UIColor *)color {
    
    CAShapeLayer *layer = [CAShapeLayer new];
    
    UIBezierPath *path = [UIBezierPath new];
    [path moveToPoint:CGPointMake(0, 0)];
    [path addLineToPoint:CGPointMake((CGRectGetWidth(self.frame)*(2*index +1)/(2*self.numMenu)) - 4, 0)];
    [path addLineToPoint:CGPointMake((CGRectGetWidth(self.frame)*(2*index +1)/(2*self.numMenu)), -5)];
    [path addLineToPoint:CGPointMake((CGRectGetWidth(self.frame)*(2*index +1)/(2*self.numMenu)) + 4, 0)];
    [path addLineToPoint:CGPointMake(CGRectGetWidth(self.frame), 0)];
    
    layer.path = path.CGPath;
    layer.lineWidth = 0.5;
    layer.fillColor = [UIColor clearColor].CGColor;//color.CGColor;
    layer.strokeColor = color.CGColor;
    
    CGPathRef bound = CGPathCreateCopyByStrokingPath(layer.path, nil, layer.lineWidth, kCGLineCapButt, kCGLineJoinMiter, layer.miterLimit);
    layer.bounds = CGPathGetBoundingBox(bound);
    
    CGPathRelease(bound);
    
    CGPoint point = CGPointMake(CGRectGetWidth(self.frame)/2.0, CGRectGetHeight(self.frame) - 2.5);
    layer.position = point;
    
    return layer;
}

#pragma mark - gesture handle
- (void)menuTapped:(UITapGestureRecognizer *)paramSender {
    CGPoint touchPoint = [paramSender locationInView:self];
    //calculate index
    NSInteger tapIndex = touchPoint.x / (self.frame.size.width / self.numMenu);
    
    for (int i = 0; i < self.numMenu; i++) {
        if (i != tapIndex) {
            [self animateIndicator:self.indicatorLayers[i] Forward:NO complete:^{
                [self animateTitle:self.titleLayers[i] show:NO complete:^{
                    
                }];
            }];
            [(CALayer *)self.backgroundLayers[i] setBackgroundColor:BackColor.CGColor];
        }
    }
    
    if (tapIndex == _currentSelectedMenudIndex && _show) {
        
        [self animateIdicator:_indicatorLayers[_currentSelectedMenudIndex] background:_backGroundView tableView:_tableView  title:_titleLayers[_currentSelectedMenudIndex] forward:NO complecte:^{
            _currentSelectedMenudIndex = tapIndex;
            _show = NO;
            [self.cursorLayer removeFromSuperlayer];
            self.cursorLayer = nil;
        }];
        
        [(CALayer *)self.backgroundLayers[tapIndex] setBackgroundColor:BackColor.CGColor];
    } else {
        
        _hadSelected = NO;
        _currentSelectedMenudIndex = tapIndex;
        
        [_tableView reloadData];
        
        if (_tableView) {
            
            _tableView.frame = CGRectMake(_tableView.frame.origin.x, self.frame.origin.y + self.frame.size.height, self.frame.size.width, 0);
        }
        
        if (_currentSelectedMenudIndex != -1) {
            
            [self animateIdicator:_indicatorLayers[tapIndex] background:_backGroundView tableView:_tableView title:_titleLayers[tapIndex] forward:YES complecte:^{
                _show = YES;
            }];
        }else{
            [self animateIdicator:_indicatorLayers[tapIndex] background:_backGroundView tableView:_tableView title:_titleLayers[tapIndex] forward:YES complecte:^{
                _show = YES;
            }];
        }
        [(CALayer *)self.backgroundLayers[tapIndex] setBackgroundColor:SelectColor.CGColor];
        
        if (!self.cursorLayer) {
            self.cursorLayer = [self createCursorWithIndex:tapIndex color:self.indicatorColor];
            [self.layer addSublayer:self.cursorLayer];
        }else{
            [self animateCursor:self.cursorLayer index:tapIndex];
        }
        
    }
}

- (void)backgroundTapped:(UITapGestureRecognizer *)paramSender
{
    [self animateIdicator:_indicatorLayers[_currentSelectedMenudIndex] background:_backGroundView tableView:self.tableView title:_titleLayers[_currentSelectedMenudIndex] forward:NO complecte:^{
        _show = NO;
        if (self.cursorLayer) {
            [self.cursorLayer removeFromSuperlayer];
            self.cursorLayer = nil;
        }
        
    }];
    
    [(CALayer *)self.backgroundLayers[_currentSelectedMenudIndex] setBackgroundColor:BackColor.CGColor];
    
    
}

#pragma mark - animation method
- (void)animateIndicator:(CAShapeLayer *)indicator Forward:(BOOL)forward complete:(void(^)())complete {
    [CATransaction begin];
    [CATransaction setAnimationDuration:0.25];
    [CATransaction setAnimationTimingFunction:[CAMediaTimingFunction functionWithControlPoints:0.4 :0.0 :0.2 :1.0]];
    
    CAKeyframeAnimation *anim = [CAKeyframeAnimation animationWithKeyPath:@"transform.rotation"];
    anim.values = forward ? @[ @0, @(M_PI) ] : @[ @(M_PI), @0 ];
    
    if (!anim.removedOnCompletion) {
        [indicator addAnimation:anim forKey:anim.keyPath];
    } else {
        [indicator addAnimation:anim forKey:anim.keyPath];
        [indicator setValue:anim.values.lastObject forKeyPath:anim.keyPath];
    }
    
    [CATransaction commit];
    
    complete();
}

- (void)animateTitle:(CATextLayer *)title show:(BOOL)show complete:(void(^)())complete {
    CGFloat fontSize = 14.0;
    NSDictionary *dic = @{NSFontAttributeName: [UIFont systemFontOfSize:fontSize]};
    CGSize size = [title.string boundingRectWithSize:CGSizeMake(280, 0) options:NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:dic context:nil].size;

    CGFloat sizeWidth = (size.width < (self.frame.size.width / self.numMenu) - 25) ? size.width : self.frame.size.width / self.numMenu - 25;
    title.bounds = CGRectMake(0, 0, sizeWidth, size.height);
    complete();
}

- (void)animateBackGroundView:(UIView *)view show:(BOOL)show complete:(void(^)())complete {
    if (show) {
        [self.superview addSubview:view];
        [view.superview addSubview:self];
        
        [UIView animateWithDuration:0.2 animations:^{
            view.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.3];
        }];
    } else {
        [UIView animateWithDuration:0.2 animations:^{
            view.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.0];
        } completion:^(BOOL finished) {
            [view removeFromSuperview];
        }];
    }
    complete();
}

- (void)animateTableView:(UITableView *)tableView show:(BOOL)show complete:(void(^)())complete {
    
    if (show) {
        
        CGFloat tableViewHeight = 0;
        
        if (tableView) {
            
            tableView.frame = CGRectMake(0, self.frame.origin.y + self.frame.size.height, self.frame.size.width, 0);
            [self.superview addSubview:tableView];
            
            tableViewHeight = ([tableView numberOfRowsInSection:0] > 5) ? (5 * tableView.rowHeight) : ([tableView numberOfRowsInSection:0] * tableView.rowHeight);
            
        }
        
        
        [UIView animateWithDuration:0.2 animations:^{
            if (tableView) {
                tableView.frame = CGRectMake(0, self.frame.origin.y + self.frame.size.height, self.frame.size.width, tableViewHeight);
            }
        }];
    } else {
        [UIView animateWithDuration:0.2 animations:^{
            
            if (tableView) {
                tableView.frame = CGRectMake(0, self.frame.origin.y + self.frame.size.height, self.frame.size.width, 0);
            }
            
        } completion:^(BOOL finished) {
            
            if (tableView) {
                [tableView removeFromSuperview];
            }
        }];
    }
    complete();
}


- (void)animateIdicator:(CAShapeLayer *)indicator background:(UIView *)background tableView:(UITableView *)tableView title:(CATextLayer *)title forward:(BOOL)forward complecte:(void(^)())complete{
    
    [self animateIndicator:indicator Forward:forward complete:^{
        [self animateTitle:title show:forward complete:^{
            [self animateBackGroundView:background show:forward complete:^{
                [self animateTableView:tableView show:forward complete:^{
                }];
            }];
        }];
    }];
    
    complete();
}

- (void)animateCursor:(CAShapeLayer *)cursor index:(NSInteger)index{
    
    [UIView animateWithDuration:0.2 animations:^{
        UIBezierPath *path = [UIBezierPath new];
        [path moveToPoint:CGPointMake(0, 0)];
        [path addLineToPoint:CGPointMake((CGRectGetWidth(self.frame)*(2*index +1)/(2*self.numMenu)) - 4, 0)];
        [path addLineToPoint:CGPointMake((CGRectGetWidth(self.frame)*(2*index +1)/(2*self.numMenu)), -5)];
        [path addLineToPoint:CGPointMake((CGRectGetWidth(self.frame)*(2*index +1)/(2*self.numMenu)) + 4, 0)];
        [path addLineToPoint:CGPointMake(CGRectGetWidth(self.frame), 0)];
        cursor.path = path.CGPath;
    }];
    
}

#pragma mark - table datasource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return  [self.dataArray[self.currentSelectedMenudIndex] count];
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0.1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"DropDownMenuCell";
    XWPullDownMenuCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[XWPullDownMenuCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        cell.textLabel.font = [UIFont systemFontOfSize:14.0];
    }
    cell.textLabel.text = self.dataArray[self.currentSelectedMenudIndex][indexPath.row];
    
    if ([cell.textLabel.text isEqualToString:[(CATextLayer *)[_titleLayers objectAtIndex:_currentSelectedMenudIndex] string]]) {
        cell.line.backgroundColor = self.selectedTableViewCellSeparatorColor;
        cell.textLabel.textColor = self.seletedTextColor;
    }else{
        cell.line.backgroundColor = self.tableViewCellSeparatorColor;
        cell.textLabel.textColor = self.textColor;
    }
    
    return cell;
}


#pragma mark - tableview delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    [self confiMenuWithSelectRow:indexPath.row];
    XWPullDownMenuCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.line.backgroundColor = self.selectedTableViewCellSeparatorColor;
    cell.textLabel.textColor = self.seletedTextColor;
    
    self.selectedComplition(self.currentSelectedMenudIndex, indexPath.row);
    
}

- (void)confiMenuWithSelectRow:(NSInteger)row{
    CATextLayer *title = (CATextLayer *)self.titleLayers[_currentSelectedMenudIndex];
    title.string = self.dataArray[self.currentSelectedMenudIndex][row];
    
    [self animateIdicator:_indicatorLayers[_currentSelectedMenudIndex] background:_backGroundView tableView:_tableView title:_titleLayers[_currentSelectedMenudIndex] forward:NO complecte:^{
        _show = NO;
        if (self.cursorLayer) {
            [self.cursorLayer removeFromSuperlayer];
            self.cursorLayer = nil;
        }
    }];
    [(CALayer *)self.backgroundLayers[_currentSelectedMenudIndex] setBackgroundColor:BackColor.CGColor];
    
    CAShapeLayer *indicator = (CAShapeLayer *)_indicatorLayers[_currentSelectedMenudIndex];
    indicator.position = CGPointMake(title.position.x + title.frame.size.width / 2 + 8, indicator.position.y);
}

-(void)selectFinishBlock:(DidSelectedSuccess)block{
    self.selectedComplition = block;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
