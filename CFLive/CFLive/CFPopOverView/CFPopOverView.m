//
//  CFPopOverView.m
//  CFLive
//
//  Created by 陈峰 on 2017/3/9.
//  Copyright © 2017年 Peak. All rights reserved.
//

#import "CFPopOverView.h"

#define kArrowHeight 10.f
//#define kArrowHeight 0.f
#define kArrowCurvature 6.f
#define SPACE 2.f
//#define ROW_HEIGHT 44.f
CGFloat ROW_HEIGHT = 44.f;

#define KRaudius 5
#define TITLE_FONT [UIFont systemFontOfSize:16]
//#define RGB(r, g, b)    [UIColor colorWithRed:(r)/255.f green:(g)/255.f blue:(b)/255.f alpha:1.f]

@interface CFPopOverView ()<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *titleArray;
@property (nonatomic, strong) NSArray *imageArray;
@property (nonatomic) CGPoint showOrigin;

@property (nonatomic, strong) UIButton *handerView;

@property (nonatomic,strong )  UIImageView *aApplyIcon;

@end

@implementation CFPopOverView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.borderColor = [UIColor blueColor];
        self.backgroundColor = [UIColor clearColor];
        //  self.layer.cornerRadius = 5;
        //  self.clipsToBounds = YES;
        self.isShowIcon = NO;
        
        
    }
    return self;
}

-(id)initWithOrigin:(CGPoint)origin titles:(NSArray *)titles images:(NSArray *)images
{
    self = [super init];
    if (self) {
        self.showOrigin = origin;
        self.titleArray = titles;
        self.imageArray = images;
        
        self.backgroundColor = [UIColor lightGrayColor];
        
        self.frame = [self getViewFrame];
        
        [self addSubview:self.tableView];
        
        
        self.layer.cornerRadius = 3;
        [self setClipsToBounds:YES];
    }
    return self;
}


// 计算字符串宽 - 可写为分类
- (CGFloat)stringWidthOfString:(NSString *)str WithLimitHeight:(CGFloat)height fontSize:(CGFloat)fontSize
                otherAttributes:(NSDictionary *)otherAttributes
{
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithDictionary:@{NSFontAttributeName:[UIFont systemFontOfSize:fontSize]}];
    if (otherAttributes) {
        for (NSString *aKey in otherAttributes.allKeys) {
            id aValue = [otherAttributes objectForKey:aKey];
            [dictionary setObject:aValue forKey:aKey];
        }
    }
    CGRect rect = [str boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, height) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:dictionary context:nil];
    return rect.size.width;
}

-(CGRect)getViewFrame
{
    CGFloat maxW = 0;
    
    for (NSString *str in self.titleArray) {
        [self stringWidthOfString:str WithLimitHeight:ROW_HEIGHT fontSize:14 otherAttributes:nil];
        CGFloat w = [self stringWidthOfString:str WithLimitHeight:ROW_HEIGHT fontSize:14 otherAttributes:nil];
        if (w > maxW) {
            maxW = w;
        }
    }
    CGFloat x = self.showOrigin.x;
    CGFloat y = self.showOrigin.y;
    CGFloat h = [self.titleArray count] * ROW_HEIGHT;
    
  
    
    if ([self.titleArray count] == [self.imageArray count]) {
        maxW = 10 + 25 + 10 + maxW + 30;
    }else{
        maxW += 40;
    }
    
    maxW = MIN(maxW, [UIScreen mainScreen].bounds.size.width-2*_showOrigin.x);
    
    CGFloat maxH = 0;
    maxH = MIN(h, ROW_HEIGHT*6);
    
    CGRect frame = CGRectMake(x, y, maxW, maxH);
    
    
    return frame;
}


- (void)show
{
    
    
    if (self.isShowIcon) {
        
        self.aApplyIcon.alpha = 1;
    }else{
        
        self.aApplyIcon.alpha = 0;
    }
    
    
    
    self.handerView = [UIButton buttonWithType:UIButtonTypeCustom];
    [_handerView setFrame:[UIScreen mainScreen].bounds];
    [_handerView setBackgroundColor:[UIColor clearColor]];
    [_handerView addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
    [_handerView addSubview:self];
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    
    [window addSubview:_handerView];
    
    CGPoint arrowPoint = [self convertPoint:self.showOrigin fromView:_handerView];
    self.layer.anchorPoint = CGPointMake(arrowPoint.x / self.frame.size.width, arrowPoint.y / self.frame.size.height);
    self.frame = [self getViewFrame];
    
    self.alpha = 0.f;
    self.transform = CGAffineTransformMakeScale(0.1f, 0.1f);
    [UIView animateWithDuration:0.2f delay:0.f options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.transform = CGAffineTransformMakeScale(1.05f, 1.05f);
        self.alpha = 1.f;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.08f delay:0.f options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.transform = CGAffineTransformIdentity;
        } completion:nil];
    }];
    
    
}

-(void)dismiss
{
    [self dismiss:YES];
}

-(void)dismiss:(BOOL)animate
{
    if (!animate) {
        [_handerView removeFromSuperview];
        return;
    }
    
    [UIView animateWithDuration:0.3f animations:^{
        self.transform = CGAffineTransformMakeScale(0.1f, 0.1f);
        self.alpha = 0.f;
    } completion:^(BOOL finished) {
        [_handerView removeFromSuperview];
    }];
    
}


#pragma mark - UITableView

-(UITableView *)tableView
{
    if (_tableView != nil) {
        return _tableView;
    }
    
    
    CGRect rect = self.bounds;
    rect.origin.x += 1 ;
    rect.origin.y += 1;
    rect.size.width -= 2*1;
    rect.size.height -= 2*1;
    self.tableView = [[UITableView alloc] initWithFrame:rect style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.alwaysBounceHorizontal = NO;
    _tableView.alwaysBounceVertical = NO;
    _tableView.showsHorizontalScrollIndicator = NO;
    _tableView.showsVerticalScrollIndicator = YES;
    _tableView.scrollEnabled = YES;
    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.separatorColor = [UIColor lightGrayColor];
    _tableView.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);
    
    
    return _tableView;
}



#pragma mark -- getter ---
- (UIImageView *)aApplyIcon{
    
    if (!_aApplyIcon) {
        
        _aApplyIcon = [[UIImageView alloc] initWithFrame:CGRectMake(4, 19, 6, 6)];
        _aApplyIcon.image = [UIImage imageNamed:@"消息红点"];
    }
    return _aApplyIcon;
    
}

#pragma mark - UITableView DataSource

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_titleArray count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"popCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        
        if (indexPath.row == 3) {
            
            [cell addSubview:self.aApplyIcon];
        }
    }
    
    cell.backgroundView = [[UIView alloc] init];
    cell.backgroundView.backgroundColor = [UIColor clearColor];//RGB(57 , 56, 60);
    cell.selectedBackgroundView = [[UIView alloc] initWithFrame:cell.bounds];
    //    cell.selectedBackgroundView.backgroundColor = UIColorFromHex(0x3d3d3f);
    
    if ([_imageArray count] == [_titleArray count]) {
        cell.imageView.image = [UIImage imageNamed:[_imageArray objectAtIndex:indexPath.row]];
    }
    NSString *text = [_titleArray objectAtIndex:indexPath.row];
    cell.textLabel.text = text;
    if ([self.selectedTitle isEqualToString:text]) {
        cell.textLabel.textColor = [UIColor blueColor];
        cell.textLabel.font = [UIFont boldSystemFontOfSize:14];
    } else {
        cell.textLabel.textColor = [UIColor blackColor];
        cell.textLabel.font = [UIFont systemFontOfSize:14];
    }
    cell.textLabel.textAlignment = NSTextAlignmentCenter;
    
    cell.backgroundColor = [UIColor whiteColor];
    
    
    return cell;
}

#pragma mark - UITableView Delegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
//    [self excuteBlockWithTarget:self CompletedBlock:^(id target, NSInteger index) {
//        
//    }];
    if (self.selectRowAtIndex) {
        self.selectRowAtIndex(indexPath.row);
    }
    [self dismiss:YES];
}

- (void)excuteBlockWithTarget:(id)target CompletedBlock:(void (^)(id, NSInteger))completedBlock
{
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return ROW_HEIGHT;
}





@end

