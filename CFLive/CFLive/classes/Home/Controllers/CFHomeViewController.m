//
//  CFHomeViewController.m
//  CFMediaPlayer
//
//  Created by Peak on 17/3/7.
//  Copyright © 2017年 Peak. All rights reserved.
//

#import "CFHomeViewController.h"
#import "CFPlayerViewController.h"
#import "CFLivePushViewController.h"
#import "LFLiveViewController.h"
#import "UIDevice+SLExtension.h"



@interface CFHomeViewController ()

@end

@implementation CFHomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"首页";
    
    UIImageView *bgImgV = [[UIImageView alloc] initWithFrame:self.view.bounds];
    bgImgV.image = [UIImage imageNamed:@"home"];
    [self.view addSubview:bgImgV];
    
    
    UILabel *titleL = [[UILabel alloc] initWithFrame:CGRectMake(0, 100, self.view.cf_width, 50)];
    titleL.numberOfLines = 0;
    titleL.textAlignment = NSTextAlignmentCenter;
    titleL.textColor = CFRandomColor;
    titleL.text = @"交流QQ 545486205\n个人github网址:https://github.com/CoderPeak";
    [self.view addSubview:titleL];
    
    
    UIButton *btn0 = [UIButton buttonWithType:UIButtonTypeCustom];
    NSString *str0 = @"点此进入--> 直播推流(主播端) >>>";
    btn0.titleLabel.numberOfLines = 0;
    [btn0 setTitle:str0 forState:UIControlStateNormal];
    [btn0 addTarget:self action:@selector(toVC0) forControlEvents:UIControlEventTouchUpInside];
    btn0.frame = CGRectMake(0, 180, self.view.cf_width, 80);
    [btn0 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    btn0.backgroundColor = [UIColor colorWithRed:153.0/255 green:204.0/255 blue:1 alpha:0.8];
    [self.view addSubview:btn0];
    
    UIButton *btn1 = [UIButton buttonWithType:UIButtonTypeCustom];
    NSString *str1 = @"点此进入--> 直播播放(粉丝端) \n目前支持rtmp、flv、hls、mp4>>>";
    btn1.titleLabel.numberOfLines = 0;
    [btn1 setTitle:str1 forState:UIControlStateNormal];
    [btn1 addTarget:self action:@selector(toVC1) forControlEvents:UIControlEventTouchUpInside];
    btn1.frame = CGRectMake(0, 280, self.view.cf_width, 80);
    [btn1 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    btn1.backgroundColor = [UIColor colorWithRed:153.0/255 green:204.0/255 blue:1 alpha:0.8];;
    [self.view addSubview:btn1];
    
    
    UIButton *btn2 = [UIButton buttonWithType:UIButtonTypeCustom];
    NSString *str2 = @"点此进入--> 点播播放 界面\n目前支持rtmp、flv、hls、mp4>>>";
    btn2.titleLabel.numberOfLines = 0;
    [btn2 setTitle:str2 forState:UIControlStateNormal];
    [btn2 addTarget:self action:@selector(toVC2) forControlEvents:UIControlEventTouchUpInside];
    btn2.frame = CGRectMake(0, 380, self.view.cf_width, 80);
    
    btn2.backgroundColor = [UIColor colorWithRed:153.0/255 green:204.0/255 blue:1 alpha:0.8];
//    [self.view addSubview:btn2];
    

}

// 是否在模拟器上运行
- (BOOL)isSimulator
{
    // 判断是否是模拟器
    if ([[UIDevice deviceVersion] isEqualToString:@"iPhone Simulator"]) {
        [[[UIAlertView alloc] initWithTitle:@"Peak友情提示" message:@"请用真机进行测试, 此模块不支持模拟器测试" delegate:nil cancelButtonTitle:@"好的" otherButtonTitles:nil, nil] show];
        return YES;
    } else {
    
        // 判断是否有摄像头
        if(![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
            [[[UIAlertView alloc] initWithTitle:@"Peak友情提示" message:@"您的设备没有摄像头或者相关的驱动, 不能进行直播" delegate:nil cancelButtonTitle:@"好的" otherButtonTitles:nil, nil] show];
        }
        
        // 判断是否有摄像头权限
        AVAuthorizationStatus  authorizationStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
        if (authorizationStatus == AVAuthorizationStatusRestricted|| authorizationStatus == AVAuthorizationStatusDenied) {
            [[[UIAlertView alloc] initWithTitle:@"Peak友情提示" message:@"app需要访问您的摄像头。\n请启用摄像头-设置/隐私/摄像头" delegate:nil cancelButtonTitle:@"好的" otherButtonTitles:nil, nil] show];
            
        }
        
        // 开启麦克风权限
        AVAudioSession *audioSession = [AVAudioSession sharedInstance];
        if ([audioSession respondsToSelector:@selector(requestRecordPermission:)]) {
            [audioSession performSelector:@selector(requestRecordPermission:) withObject:^(BOOL granted) {
                if (!granted) {
                    
                    [[[UIAlertView alloc] initWithTitle:@"Peak友情提示" message:@"app需要访问您的麦克风。\n请启用麦克风-设置/隐私/麦克风" delegate:nil cancelButtonTitle:@"好的" otherButtonTitles:nil, nil] show];
                }
                
            }];
        }
        return NO;
    }
    
}

- (void)toVC0
{
//    CFLivePushViewController *vc = [[CFLivePushViewController alloc] init];
    if (![self isSimulator]) {
        LFLiveViewController *vc = [[UIStoryboard storyboardWithName:@"LFLiveViewController" bundle:nil] instantiateInitialViewController];
        vc.title = @"直播(推流/主播端)";
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (void)toVC1
{
    CFPlayerViewController *vc = [[CFPlayerViewController alloc] init];
    vc.title = @"直播播放(拉流/粉丝端)";
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)toVC2
{
    CFPlayerViewController *vc = [[CFPlayerViewController alloc] init];
    vc.title = @"点播播放";
    [self.navigationController pushViewController:vc animated:YES];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
