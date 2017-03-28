//
//  CFLivePushViewController.m
//  CFLive
//
//  Created by 陈峰 on 2017/3/9.
//  Copyright © 2017年 Peak. All rights reserved.
//

#import "CFLivePushViewController.h"
#import "CFLivePushViewController.h"
#import <Foundation/Foundation.h>
#import <TXRTMPSDK/TXLiveSDKTypeDef.h>
#import <sys/types.h>
#import <sys/sysctl.h>
#import <UIKit/UIKit.h>
#import <mach/mach.h>

// 清晰度定义
#define    HD_LEVEL_720P       1  // 1280 * 720
#define    HD_LEVEL_540P       2  //  960 * 540
#define    HD_LEVEL_360P       3  //  640 * 360
#define    HD_LEVEL_360_PLUS   4  //  640 * 360 且开启码率自适应



//#define RTMP_PUBLISH_URL    @"请输入或扫二维码获取播放地址"  //调试期间您可以修改之以避免输入地址的麻烦
#define RTMP_PUBLISH_URL    @"rtmp://live.hkstv.hk.lxdns.com:1935/live/CoderPeak"  //调试期间您可以修改之以避免输入地址的麻烦

void testHookVideoFunc(unsigned char * yuv_buffer, int len_buffer, int width, int height)
{
    NSLog(@"hook video %p %d %d %d", yuv_buffer, len_buffer, width, height);
    
    //    //比如：画面镜像(左右颠倒画面)
    //    unsigned char * des_yuv = (unsigned char*)malloc(len_buffer);
    //
    //    int hw = width / 2;
    //    int hh = height / 2;
    //
    //    int fs = width * height;
    //    int qfs = fs*5/4;
    //
    //    for(int j=0; j<height; ++j)
    //    {
    //        for(int i=0; i<width; ++i)
    //        {
    //            des_yuv[j*width + i] = yuv_buffer[j*width + width - i - 1];
    //
    //            if(i<hw && j<hh)
    //            {
    //                des_yuv[fs + j*hw + i] = yuv_buffer[fs + j*hw + hw - i -1];
    //                des_yuv[qfs + j*hw + i] = yuv_buffer[qfs + j*hw + hw - i -1];
    //            }
    //        }
    //    }
    //
    //    memcpy(yuv_buffer, des_yuv, len_buffer);
    //
    //    free(des_yuv);
}

void testHookAudioFunc(unsigned char * pcm_buffer, int len_buffer, int sample_rate, int channels, int bit_size)
{
    NSLog(@"hook audio %p %d %d %d %d", pcm_buffer, len_buffer, sample_rate, channels, bit_size);
    
    //    // 比如：静音
    //    memset(pcm_buffer, 0, len_buffer);
}


@interface CFLivePushViewController ()<UITextFieldDelegate, TXLivePushListener>

@end

@implementation CFLivePushViewController
{
    BOOL _appIsInterrupt;
    UIView *    preViewContainer;
    UIDeviceOrientation _deviceOrientation;
    NSString *  _pushUrl;
}

- (CFLivePushViewController *)init
{
    self = [super init];
    if (self != nil) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onHandleNavigation:) name:@"HandleNavigation" object:nil];
        _filterArray = [NSMutableArray arrayWithObjects:@"无滤镜", @"浪漫", @"清新", @"唯美", @"粉嫩", @"怀旧", @"蓝调", @"清凉", @"日系", nil];
    }
    
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}



- (void)viewDidLoad {
    [super viewDidLoad];
    _deviceOrientation = UIDeviceOrientationPortrait;
    
    [self initUI];
    TXLivePushConfig* _config = [[TXLivePushConfig alloc] init];
    _config.frontCamera = NO;
    _config.pauseFps = 10;
    _config.pauseTime = 300;
    _config.pauseImg = [UIImage imageNamed:@"pause_publish.jpg"];
    
    _txLivePublisher = [[TXLivePush alloc] initWithConfig:_config];

}

- (void)viewDidDisappear:(BOOL)animated;
{
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
}

- (void)onAppDidEnterBackGround:(NSNotification *)notification
{
    [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        
    }];
    [_txLivePublisher pausePush];
}

- (void)onAppWillEnterForeground:(NSNotification *)notification
{
    [_txLivePublisher resumePush];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
#if !TARGET_IPHONE_SIMULATOR
    //是否有摄像头权限
    AVAuthorizationStatus statusVideo = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (statusVideo == AVAuthorizationStatusDenied) {
        [self toastTip:@"获取摄像头权限失败，请前往隐私-相机设置里面打开应用权限"];
        return;
    }
    
    //    if (!_isPreviewing) {
    //        [_txLivePublisher startPreview:preViewContainer];
    //        _isPreviewing = YES;
    //    }
#endif
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onAppDidEnterBackGround:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onAppWillEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(statusBarOrientationChanged:) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (void)clearLog {
    _tipsMsg = @"";
    _logMsg = @"";
    [_statusView setText:@""];
    [_logViewEvt setText:@""];
    _startTime = [[NSDate date]timeIntervalSince1970]*1000;
    _lastTime = _startTime;
}

//- (void) customVideoCaptureThread
//{
//    int width = 1280;
//    int height = 720;
//    FILE * fp_video = NULL;
//    if (fp_video == NULL)
//    {
//        NSString *pathDocuments=[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
//        const char * path = [pathDocuments UTF8String];
//
//        char temp[512] = {0};
//        sprintf(temp, "%s/dump_%d_%d.yuv", path, width, height);
//        fp_video = fopen(temp, "rb");
//    }
//
//    int len = width * height * 3 / 2;
//    unsigned char * buffer = (unsigned char *)malloc(len);
//
//    while (true)
//    {
//        if (feof(fp_video))
//        {
//            fseek(fp_video, 0, SEEK_SET);
//        }
//        memset(buffer, 0, len);
//        fread(buffer, len, 1, fp_video);
//        [_txLivePublisher sendCustomYUVData: buffer dataLen:len];
//
//        usleep(50);
//    }
//}


//- (void) customAudioCaptureThread
//{
//    FILE * fp_audio = NULL;
//    if (fp_audio == NULL)
//    {
//        NSString *pathDocuments=[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
//        const char * path = [pathDocuments UTF8String];
//
//        char temp[512] = {0};
//        sprintf(temp, "%s/dump.pcm", path);
//        fp_audio = fopen(temp, "rb");
//    }
//
//    int len = 2048;
//    unsigned char * buffer = (unsigned char *)malloc(len);
//
//    while (true)
//    {
//        if (feof(fp_audio))
//        {
//            fseek(fp_audio, 0, SEEK_SET);
//        }
//        memset(buffer, 0, len);
//        fread(buffer, len, 1, fp_audio);
//        [_txLivePublisher sendCustomPCMData: buffer len:len];
//
//        usleep(30);
//    }
//}

- (BOOL)startRtmp{
    [self clearLog];
    NSString* rtmpUrl = RTMP_PUBLISH_URL;
    if (!([rtmpUrl hasPrefix:@"rtmp://"] )) {
        [self toastTip:@"推流地址不合法，目前支持rtmp推流!"];
        return NO;
    }
    
    //是否有摄像头权限
    AVAuthorizationStatus statusVideo = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (statusVideo == AVAuthorizationStatusDenied) {
        [self toastTip:@"获取摄像头权限失败，请前往隐私-相机设置里面打开应用权限"];
        return NO;
    }
    
    //是否有麦克风权限
    AVAuthorizationStatus statusAudio = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
    if (statusAudio == AVAuthorizationStatusDenied) {
        [self toastTip:@"获取麦克风权限失败，请前往隐私-麦克风设置里面打开应用权限"];
        return NO;
    }
    
    NSArray* ver = [TXLivePush getSDKVersion];
    if ([ver count] >= 3) {
        _logMsg = [NSString stringWithFormat:@"rtmp sdk version: %@.%@.%@",ver[0],ver[1],ver[2]];
        [_logViewEvt setText:_logMsg];
    }
    
    if(_txLivePublisher != nil)
    {
        
        
        
        
        _txLivePublisher.delegate = self;
        if (!_isPreviewing) {
            [_txLivePublisher startPreview:preViewContainer];
            [_txLivePublisher startPush:rtmpUrl];
            _isPreviewing = YES;
        }
        
        if ([_txLivePublisher startPush:rtmpUrl] != 0) {
            NSLog(@"推流器启动失败");
            return NO;
        }
        
        [_txLivePublisher setBeautyFilterDepth:_beauty_level setWhiteningFilterDepth:_whitening_level];
    }
    
    _pushUrl = rtmpUrl;
    
    return YES;
}



- (void)stopRtmp {
    _pushUrl = @"";
    if(_txLivePublisher != nil)
    {
        _txLivePublisher.delegate = nil;
        [_txLivePublisher stopPreview];
        _isPreviewing = NO;
        [_txLivePublisher stopPush];
        
        _sdBeauty.value = 0;
        _sdWhitening.value = 0;
    }
}

// RTMP 推流事件通知
#pragma - TXLivePushListener
-(void) appendLog:(NSString*) evt time:(NSDate*) date mills:(int)mil
{
    NSDateFormatter* format = [[NSDateFormatter alloc] init];
    format.dateFormat = @"hh:mm:ss";
    NSString* time = [format stringFromDate:date];
    NSString* log = [NSString stringWithFormat:@"[%@.%-3.3d] %@", time, mil, evt];
    if (_logMsg == nil) {
        _logMsg = @"";
    }
    _logMsg = [NSString stringWithFormat:@"%@\n%@", _logMsg, log];
    [_logViewEvt setText:_logMsg];
}

-(void) onPushEvent:(int)EvtID withParam:(NSDictionary*)param;
{
    NSDictionary* dict = param;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (EvtID == PUSH_ERR_NET_DISCONNECT) {
            [self clickPublish:_btnPublish];
        }
        else if(EvtID == PUSH_WARNING_HW_ACCELERATION_FAIL){
            _txLivePublisher.config.enableHWAcceleration = false;
            [_btnHardware setImage:[UIImage imageNamed:@"quick2"] forState:UIControlStateNormal];
        }
        else if(EvtID ==  PUSH_ERR_OPEN_CAMERA_FAIL){
            [self stopRtmp];
            [_btnPublish setImage:[UIImage imageNamed:@"start"] forState:UIControlStateNormal];
            _publish_switch = NO;
            [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
            [self toastTip:@"获取摄像头权限失败，请前往隐私-相机设置里面打开应用权限"];
        }
        else if(EvtID ==  PUSH_ERR_OPEN_MIC_FAIL){
            [self stopRtmp];
            [_btnPublish setImage:[UIImage imageNamed:@"start"] forState:UIControlStateNormal];
            _publish_switch = NO;
            [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
            [self toastTip:@"获取麦克风权限失败，请前往隐私-麦克风设置里面打开应用权限"];
        }
        
        //        NSLog(@"evt:%d,%@", EvtID, dict);
        long long time = [(NSNumber*)[dict valueForKey:EVT_TIME] longLongValue];
        int mil = time % 1000;
        NSDate* date = [NSDate dateWithTimeIntervalSince1970:time/1000];
        NSString* Msg = (NSString*)[dict valueForKey:EVT_MSG];
        [self appendLog:Msg time:date mills:mil];
    });
}

-(void) onNetStatus:(NSDictionary*) param
{
    NSDictionary* dict = param;
    
    NSString * streamID = [dict valueForKey:STREAM_ID];
    if ([streamID isEqualToString:_pushUrl] != YES)
    {        return;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        int netspeed  = [(NSNumber*)[dict valueForKey:NET_STATUS_NET_SPEED] intValue];
        int vbitrate  = [(NSNumber*)[dict valueForKey:NET_STATUS_VIDEO_BITRATE] intValue];
        int abitrate  = [(NSNumber*)[dict valueForKey:NET_STATUS_AUDIO_BITRATE] intValue];
        int cachesize = [(NSNumber*)[dict valueForKey:NET_STATUS_CACHE_SIZE] intValue];
        int dropsize  = [(NSNumber*)[dict valueForKey:NET_STATUS_DROP_SIZE] intValue];
        int jitter    = [(NSNumber*)[dict valueForKey:NET_STATUS_NET_JITTER] intValue];
        int fps       = [(NSNumber*)[dict valueForKey:NET_STATUS_VIDEO_FPS] intValue];
        int width     = [(NSNumber*)[dict valueForKey:NET_STATUS_VIDEO_WIDTH] intValue];
        int height    = [(NSNumber*)[dict valueForKey:NET_STATUS_VIDEO_HEIGHT] intValue];
        float cpu_usage = [(NSNumber*)[dict valueForKey:NET_STATUS_CPU_USAGE] floatValue];
        float cpu_usage_ = [(NSNumber*)[dict valueForKey:NET_STATUS_CPU_USAGE_D] floatValue];
        int codecCacheSize = [(NSNumber*)[dict valueForKey:NET_STATUS_CODEC_CACHE] intValue];
        int nCodecDropCnt = [(NSNumber*)[dict valueForKey:NET_STATUS_CODEC_DROP_CNT] intValue];
        NSString *serverIP = [dict valueForKey:NET_STATUS_SERVER_IP];
        int nSetVideoBitrate = [(NSNumber*)[dict valueForKey:NET_STATUS_SET_VIDEO_BITRATE] intValue];
        NSString* log = [NSString stringWithFormat:@"CPU:%.1f%%|%.1f%%\tRES:%d*%d\tSPD:%dkb/s\nJITT:%d\tFPS:%d\tARA:%dkb/s\nQUE:%d|%d\tDRP:%d|%d\tVRA:%dkb/s\nAVRA:%dkb/s\tSVR:%@",
                         cpu_usage_*100,
                         cpu_usage*100,
                         width,
                         height,
                         netspeed,
                         jitter,
                         fps,
                         abitrate,
                         codecCacheSize,
                         cachesize,
                         nCodecDropCnt,
                         dropsize,
                         vbitrate,
                         nSetVideoBitrate,
                         serverIP];
        [_statusView setText:log];
      
        
    });
}


#pragma - ui util
-(void) initUI
{
    //主界面排版
    self.wantsFullScreenLayout = YES;
    
    UIColor* bgColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bgImage"]];
    [self.view setBackgroundColor:bgColor];
    
    CGSize size = [[UIScreen mainScreen] bounds].size;
    int ICON_SIZE = size.width / 10;
    
    _cover = [[UIView alloc]init];
    _cover.frame  = CGRectMake(10.0f, 55 + 2*ICON_SIZE, size.width - 20, size.height - 75 - 3 * ICON_SIZE);
    _cover.backgroundColor = [UIColor whiteColor];
    _cover.alpha  = 0.5;
    _cover.hidden = YES;
    [self.view addSubview:_cover];
    
    int logheadH = 65;
    _statusView = [[UITextView alloc] initWithFrame:CGRectMake(10.0f, 55 + 2*ICON_SIZE, size.width - 20,  logheadH)];
    _statusView.backgroundColor = [UIColor clearColor];
    _statusView.alpha = 1;
    _statusView.textColor = [UIColor blackColor];
    _statusView.editable = NO;
    _statusView.hidden = YES;
    [self.view addSubview:_statusView];
    
    _logViewEvt = [[UITextView alloc] initWithFrame:CGRectMake(10.0f, 55 + 2*ICON_SIZE + logheadH, size.width - 20, size.height - 75 - 3 * ICON_SIZE - logheadH)];
    _logViewEvt.backgroundColor = [UIColor clearColor];
    _logViewEvt.alpha = 1;
    _logViewEvt.textColor = [UIColor blackColor];
    _logViewEvt.editable = NO;
    _logViewEvt.hidden = YES;
    [self.view addSubview:_logViewEvt];
    
   
    
    [self.txtRtmpUrl setBorderStyle:UITextBorderStyleRoundedRect];
//    self.txtRtmpUrl = [[UITextField alloc] initWithFrame:CGRectMake(10, 40 + ICON_SIZE + 10, size.width- 25 - ICON_SIZE, ICON_SIZE)];
    self.txtRtmpUrl = [[UITextField alloc] initWithFrame:CGRectMake(10, 40 + ICON_SIZE + 10, size.width- 20, ICON_SIZE)];
    self.txtRtmpUrl.placeholder = RTMP_PUBLISH_URL;
    self.txtRtmpUrl.background = [UIImage imageNamed:@"Input_box"];
    self.txtRtmpUrl.alpha = 0.5;
    self.txtRtmpUrl.autocapitalizationType = UITextAutocorrectionTypeNo;
    self.txtRtmpUrl.delegate = self;
    self.txtRtmpUrl.text = @"";
    [self.view addSubview:self.txtRtmpUrl];
    
    UIButton* btnScan = [UIButton buttonWithType:UIButtonTypeCustom];
    btnScan.frame = CGRectMake(size.width - 10 - ICON_SIZE , 40 + ICON_SIZE + 10, ICON_SIZE, ICON_SIZE);
    [btnScan setImage:[UIImage imageNamed:@"QR_code"] forState:UIControlStateNormal];
    [btnScan addTarget:self action:@selector(clickScan:) forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:btnScan];
    
    float startSpace = 12;
    float centerInterVal = (size.width - 2*startSpace - ICON_SIZE)/7;
    float iconY = size.height - ICON_SIZE/2 - 10;
    
    //start or stop 按钮
    _publish_switch = NO;
    _btnPublish = [UIButton buttonWithType:UIButtonTypeCustom];
    _btnPublish.center = CGPointMake(startSpace + ICON_SIZE/2, iconY);
    _btnPublish.bounds = CGRectMake(0, 0, ICON_SIZE, ICON_SIZE);
    [_btnPublish setImage:[UIImage imageNamed:@"start"] forState:UIControlStateNormal];
    [_btnPublish addTarget:self action:@selector(clickPublish:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_btnPublish];
    
    
    //前置后置摄像头切换
    _camera_switch = NO;
    _btnCamera = [UIButton buttonWithType:UIButtonTypeCustom];
    _btnCamera.center = CGPointMake(startSpace + ICON_SIZE/2 + centerInterVal, iconY);
    _btnCamera.bounds = CGRectMake(0, 0, ICON_SIZE, ICON_SIZE);
    [_btnCamera setImage:[UIImage imageNamed:@"camera"] forState:UIControlStateNormal];
    [_btnCamera addTarget:self action:@selector(clickCamera:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_btnCamera];
    
    //美颜开关按钮
    _beauty_level = 6.3;
    _whitening_level = 2.7;
    _btnBeauty = [UIButton buttonWithType:UIButtonTypeCustom];
    _btnBeauty.center = CGPointMake(startSpace + ICON_SIZE/2 + centerInterVal*2, iconY);
    _btnBeauty.bounds = CGRectMake(0, 0, ICON_SIZE, ICON_SIZE);
    [_btnBeauty setImage:[UIImage imageNamed:@"beauty"] forState:UIControlStateNormal];
    [_btnBeauty addTarget:self action:@selector(clickBeauty:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_btnBeauty];
    
    //硬件加速
    _hardware_switch = NO;
    _btnHardware = [UIButton buttonWithType:UIButtonTypeCustom];
    _btnHardware.center = CGPointMake(startSpace + ICON_SIZE/2 + centerInterVal*3, iconY);
    _btnHardware.bounds = CGRectMake(0, 0, ICON_SIZE, ICON_SIZE);
    [_btnHardware setImage:[UIImage imageNamed:@"quick"] forState:UIControlStateNormal];
    [_btnHardware addTarget:self action:@selector(clickHardware:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_btnHardware];
    
    //开启横屏推流
    _screenPortrait = NO;
    _btnScreenOrientation = [UIButton buttonWithType:UIButtonTypeCustom];
    _btnScreenOrientation.center = CGPointMake(startSpace + ICON_SIZE/2 + centerInterVal*4, iconY);
    _btnScreenOrientation.bounds = CGRectMake(0, 0, ICON_SIZE, ICON_SIZE);
    [_btnScreenOrientation setImage:[UIImage imageNamed:@"portrait"] forState:UIControlStateNormal];
    [_btnScreenOrientation addTarget:self action:@selector(clickScreenOrientation:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_btnScreenOrientation];
    
    //log显示或隐藏
    _log_switch = NO;
    _btnLog = [UIButton buttonWithType:UIButtonTypeCustom];
    _btnLog.center = CGPointMake(startSpace + ICON_SIZE/2 + centerInterVal*5, iconY);
    _btnLog.bounds = CGRectMake(0, 0, ICON_SIZE, ICON_SIZE);
    [_btnLog setImage:[UIImage imageNamed:@"log"] forState:UIControlStateNormal];
    [_btnLog addTarget:self action:@selector(clickLog:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_btnLog];
    
    //清晰度按钮
    _btnResolution = [UIButton buttonWithType:UIButtonTypeCustom];
    _btnResolution.center = CGPointMake(startSpace + ICON_SIZE/2 + centerInterVal*6, iconY);
    _btnResolution.bounds = CGRectMake(0, 0, ICON_SIZE, ICON_SIZE);
    [_btnResolution setImage:[UIImage imageNamed:@"SD"] forState:UIControlStateNormal];
    [_btnResolution addTarget:self action:@selector(clickHD:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_btnResolution];
    
    //镜像按钮
    _isMirror = NO;
    _btnMirror = [UIButton buttonWithType:UIButtonTypeCustom];
    _btnMirror.center = CGPointMake(startSpace + ICON_SIZE/2 + centerInterVal*7, iconY);
    _btnMirror.bounds = CGRectMake(0, 0, ICON_SIZE, ICON_SIZE);
    [_btnMirror setTitle:@"镜像" forState:UIControlStateNormal];
    _btnMirror.titleLabel.font = [UIFont systemFontOfSize:15];
    [_btnMirror setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_btnMirror setBackgroundColor:[UIColor whiteColor]];
    _btnMirror.layer.cornerRadius = _btnMirror.frame.size.width/2;
    [_btnMirror setAlpha:0.5];
    [_btnMirror addTarget:self action:@selector(clickMirror:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_btnMirror];
    
    
    //美颜拉杆浮层
    _vBeauty = [[UIControl  alloc] init];
    _vBeauty.frame = CGRectMake(0, size.height-160, size.width, 160);
    [_vBeauty setBackgroundColor:[UIColor whiteColor]];
    
    UILabel* txtBeauty = [[UILabel alloc]init];
    txtBeauty.frame = CGRectMake(20, 25, 150, 150);
    [txtBeauty setText:@"美颜效果"];
    [txtBeauty setFont:[UIFont fontWithName:@"" size:14]];
    [txtBeauty sizeToFit];
    
    _sdBeauty = [[UISlider alloc] init];
    _sdBeauty.frame = CGRectMake(txtBeauty.frame.origin.x + txtBeauty.frame.size.width + 10, 0, size.width - txtBeauty.frame.origin.x - txtBeauty.frame.size.width - 40, 60);
    _sdBeauty.minimumValue = 0;
    _sdBeauty.maximumValue = 9;
    _sdBeauty.value = 6.3;
    _sdBeauty.center = CGPointMake(_sdBeauty.center.x, txtBeauty.center.y);
    
    [_sdBeauty setThumbImage:[UIImage imageNamed:@"circle"] forState:UIControlStateNormal];
    [_sdBeauty setMinimumTrackTintColor:[UIColor blackColor]];
    [_sdBeauty setMaximumTrackTintColor:[UIColor blackColor]];
    [_sdBeauty addTarget:self action:@selector(sliderValueChange:) forControlEvents:UIControlEventValueChanged];
    _sdBeauty.tag = 0;
    
    UILabel* txtWhitening = [[UILabel alloc] init];
    txtWhitening.frame = CGRectMake(20, txtBeauty.frame.origin.y + txtBeauty.frame.size.height + 25, 150, 150);
    [txtWhitening setText:@"美白效果"];
    [txtWhitening setFont:[UIFont fontWithName:@"" size:14]];
    [txtWhitening sizeToFit];
    
    _sdWhitening = [[UISlider alloc] init];
    _sdWhitening.frame = CGRectMake(txtWhitening.frame.origin.x + txtWhitening.frame.size.width + 10, 0, size.width - txtWhitening.frame.origin.x - txtWhitening.frame.size.width - 40, 60);
    _sdWhitening.minimumValue = 0;
    _sdWhitening.maximumValue = 9;
    _sdWhitening.value = 2.7;
    _sdWhitening.center = CGPointMake(_sdWhitening.center.x, txtWhitening.center.y);
    
    [_sdWhitening setThumbImage:[UIImage imageNamed:@"circle"] forState:UIControlStateNormal];
    [_sdWhitening setMinimumTrackTintColor:[UIColor blackColor]];
    [_sdWhitening setMaximumTrackTintColor:[UIColor blackColor]];
    [_sdWhitening addTarget:self action:@selector(sliderValueChange:) forControlEvents:UIControlEventValueChanged];
    _sdWhitening.tag = 1;
    
    _vhPickerView = [[V8HorizontalPickerView alloc] initWithFrame:CGRectMake(50,  txtWhitening.frame.origin.y + txtWhitening.frame.size.height + 5, size.width - 100, 50)];
    _vhPickerView.selectedTextColor = [UIColor blackColor];
    _vhPickerView.textColor = [UIColor grayColor];
    _vhPickerView.elementFont = [UIFont fontWithName:@"" size:14];
    _vhPickerView.delegate = self;
    _vhPickerView.dataSource = self;
    _filterType = 0;
    
    [_vBeauty addSubview:txtBeauty];
    [_vBeauty addSubview:_sdBeauty];
    [_vBeauty addSubview:txtWhitening];
    [_vBeauty addSubview:_sdWhitening];
    [_vBeauty  addSubview:_vhPickerView];
    
    _vBeauty.hidden = YES;
    [self.view addSubview: _vBeauty];
    
    // 清晰度选项: 720p - 640 - 640+ (此处使用了三个普通按钮来模拟单选框, 目的是跟android demo 保持界面风格一致)
    _vHD = [[UIControl alloc]init];
    _vHD.frame = CGRectMake(0, size.height-120, size.width, 120);
    [_vHD setBackgroundColor:[UIColor whiteColor]];
    
    UILabel* txtHD= [[UILabel alloc]init];
    txtHD.frame = CGRectMake(0, 0, size.width, 50);
    [txtHD setText:@"清晰度"];
    txtHD.textAlignment = UITextAlignmentCenter;
    [txtHD setFont:[UIFont fontWithName:@"" size:14]];
    
    [_vHD addSubview:txtHD];
    
    int gap = 30;
    int width = (size.width - gap*3 - 20) / 4;
    _radioBtnHD = [UIButton buttonWithType:UIButtonTypeCustom];
    _radioBtnHD.frame = CGRectMake(10, 60, width, 40);
    [_radioBtnHD setTitle:@"720p" forState:UIControlStateNormal];
    [_radioBtnHD addTarget:self action:@selector(changeHD:) forControlEvents:UIControlEventTouchUpInside];
    
    _radioBtnHD2 = [UIButton buttonWithType:UIButtonTypeCustom];
    _radioBtnHD2.frame = CGRectMake(10 + gap + width, 60, width, 40);
    [_radioBtnHD2 setTitle:@"540p" forState:UIControlStateNormal];
    [_radioBtnHD2 addTarget:self action:@selector(changeHD:) forControlEvents:UIControlEventTouchUpInside];
    
    _radioBtnSD = [UIButton buttonWithType:UIButtonTypeCustom];
    _radioBtnSD.frame = CGRectMake(10 + (gap + width)*2, 60, width, 40);
    [_radioBtnSD setTitle:@"360p" forState:UIControlStateNormal];
    [_radioBtnSD addTarget:self action:@selector(changeHD:) forControlEvents:UIControlEventTouchUpInside];
    
    _radioBtnAUTO = [UIButton buttonWithType:UIButtonTypeCustom];
    _radioBtnAUTO.frame = CGRectMake(size.width - 10 - width, 60, width, 40);
    [_radioBtnAUTO setTitle:@"360+" forState:UIControlStateNormal];
    [_radioBtnAUTO addTarget:self action:@selector(changeHD:) forControlEvents:UIControlEventTouchUpInside];
    
    [_vHD addSubview:_radioBtnHD];
    [_vHD addSubview:_radioBtnHD2];
    [_vHD addSubview:_radioBtnSD];
    [_vHD addSubview:_radioBtnAUTO];
    
    _vHD.hidden = YES;
    [self.view addSubview: _vHD];
    
    // DEMO 默认采用 640 * 360 分辨率, 避免在4S等机型上出现编码不足
    _hd_level =  HD_LEVEL_360P;
    [self setHDUI:_hd_level];
    
#if TARGET_IPHONE_SIMULATOR
    [self toastTip:@"iOS模拟器不支持推流和播放，请使用真机体验"];
#endif
    
    CGRect previewFrame = self.view.bounds;
    preViewContainer = [[UIView alloc] initWithFrame:previewFrame];
    
    [self.view insertSubview:preViewContainer atIndex:0];
    preViewContainer.center = self.view.center;
}

#pragma mark - HorizontalPickerView DataSource Methods
- (NSInteger)numberOfElementsInHorizontalPickerView:(V8HorizontalPickerView *)picker {
    return [_filterArray count];
}

#pragma mark - HorizontalPickerView Delegate Methods
- (NSString *)horizontalPickerView:(V8HorizontalPickerView *)picker titleForElementAtIndex:(NSInteger)index {
    return [_filterArray objectAtIndex:index];
}

- (NSInteger) horizontalPickerView:(V8HorizontalPickerView *)picker widthForElementAtIndex:(NSInteger)index {
    CGSize constrainedSize = CGSizeMake(MAXFLOAT, MAXFLOAT);
    NSString *text = [_filterArray objectAtIndex:index];
    CGSize textSize = [text sizeWithFont:[UIFont boldSystemFontOfSize:14.0f]
                       constrainedToSize:constrainedSize
                           lineBreakMode:UILineBreakModeWordWrap];
    return textSize.width + 40.0f; // 20px padding on each side
}

- (void)horizontalPickerView:(V8HorizontalPickerView *)picker didSelectElementAtIndex:(NSInteger)index {
    _filterType = index;
    [self setFilter:index];
}

- (void)setFilter:(int) index
{
    NSString* lookupFileName = @"";
    
    switch (index) {
        case FilterType_None:
            break;
        case FilterType_langman:
            lookupFileName = @"langman.png";
            break;
        case FilterType_qingxin:
            lookupFileName = @"qingxin.png";
            break;
        case FilterType_weimei:
            lookupFileName = @"weimei.png";
            break;
        case FilterType_fennen:
            lookupFileName = @"fennen.png";
            break;
        case FilterType_huaijiu:
            lookupFileName = @"huaijiu.png";
            break;
        case FilterType_landiao:
            lookupFileName = @"landiao.png";
            break;
        case FilterType_qingliang:
            lookupFileName = @"qingliang.png";
            break;
        case FilterType_rixi:
            lookupFileName = @"rixi.png";
            break;
        default:
            break;
    }
    NSString * path = [[NSBundle mainBundle] pathForResource:@"FilterResource" ofType:@"bundle"];
    if (path != nil && index != FilterType_None && _txLivePublisher != nil) {
        path = [path stringByAppendingPathComponent:lookupFileName];
        UIImage *image = [UIImage imageWithContentsOfFile:path];
        [_txLivePublisher setFilter:image];
    } else if(_txLivePublisher != nil) {
        [_txLivePublisher setFilter:nil];
    }
}

-(void) setHDUI:(int) level
{
    switch (level) {
        case HD_LEVEL_720P:
            [_radioBtnHD setBackgroundImage:[UIImage imageNamed:@"black"] forState:UIControlStateNormal];
            [_radioBtnHD2 setBackgroundImage:[UIImage imageNamed:@"white"] forState:UIControlStateNormal];
            [_radioBtnSD setBackgroundImage:[UIImage imageNamed:@"white"] forState:UIControlStateNormal];
            [_radioBtnAUTO setBackgroundImage:[UIImage imageNamed:@"white"] forState:UIControlStateNormal];
            [_radioBtnHD setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [_radioBtnHD2 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [_radioBtnSD setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [_radioBtnAUTO setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [_btnResolution setImage:[UIImage imageNamed:@"HD"] forState:UIControlStateNormal];
            break;
        case HD_LEVEL_540P:
            [_radioBtnHD setBackgroundImage:[UIImage imageNamed:@"white"] forState:UIControlStateNormal];
            [_radioBtnHD2 setBackgroundImage:[UIImage imageNamed:@"black"] forState:UIControlStateNormal];
            [_radioBtnSD setBackgroundImage:[UIImage imageNamed:@"white"] forState:UIControlStateNormal];
            [_radioBtnAUTO setBackgroundImage:[UIImage imageNamed:@"white"] forState:UIControlStateNormal];
            [_radioBtnHD setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [_radioBtnHD2 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [_radioBtnSD setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [_radioBtnAUTO setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [_btnResolution setImage:[UIImage imageNamed:@"HD"] forState:UIControlStateNormal];
            break;
        case HD_LEVEL_360P:
            [_radioBtnHD setBackgroundImage:[UIImage imageNamed:@"white"] forState:UIControlStateNormal];
            [_radioBtnHD2 setBackgroundImage:[UIImage imageNamed:@"white"] forState:UIControlStateNormal];
            [_radioBtnSD setBackgroundImage:[UIImage imageNamed:@"black"] forState:UIControlStateNormal];
            [_radioBtnAUTO setBackgroundImage:[UIImage imageNamed:@"white"] forState:UIControlStateNormal];
            [_radioBtnHD setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [_radioBtnHD2 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [_radioBtnSD setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [_radioBtnAUTO setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [_btnResolution setImage:[UIImage imageNamed:@"SD"] forState:UIControlStateNormal];
            
            break;
        case HD_LEVEL_360_PLUS:
            [_radioBtnHD setBackgroundImage:[UIImage imageNamed:@"white"] forState:UIControlStateNormal];
            [_radioBtnHD2 setBackgroundImage:[UIImage imageNamed:@"white"] forState:UIControlStateNormal];
            [_radioBtnSD setBackgroundImage:[UIImage imageNamed:@"white"] forState:UIControlStateNormal];
            [_radioBtnAUTO setBackgroundImage:[UIImage imageNamed:@"black"] forState:UIControlStateNormal];
            [_radioBtnHD setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [_radioBtnHD2 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [_radioBtnSD setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [_radioBtnAUTO setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [_btnResolution setImage:[UIImage imageNamed:@"PU"] forState:UIControlStateNormal];
        default:
            break;
    }
}

#pragma - 事件处理

-(void) clickScan:(UIButton*) btn
{
    [_btnPublish setImage:[UIImage imageNamed:@"start"] forState:UIControlStateNormal];
    _publish_switch = NO;
    [self stopRtmp];
//    ScanQRController* vc = [[ScanQRController alloc] init];
//    vc.pvc = self;
//    [self.navigationController pushViewController:vc animated:NO];
}

-(void) clickPublish:(UIButton*) btn
{
    //-[UIApplication setIdleTimerDisabled:]用于控制自动锁屏，SDK内部并无修改系统锁屏的逻辑
    if (_publish_switch == YES) {
        [self stopRtmp];
        [_btnPublish setImage:[UIImage imageNamed:@"start"] forState:UIControlStateNormal];
        _publish_switch = NO;
        [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
    }
    else
    {
        if(![self startRtmp])
        {
            return;
        }
        [_btnPublish setImage:[UIImage imageNamed:@"suspend"] forState:UIControlStateNormal];
        _publish_switch = YES;
        [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    }
}


-(void) clickCamera:(UIButton*) btn
{
    _camera_switch = !_camera_switch;
    
    [btn setImage:[UIImage imageNamed:(_camera_switch? @"camera2" : @"camera")] forState:UIControlStateNormal];
    [_txLivePublisher switchCamera];
}

-(void) clickBeauty:(UIButton*) btn
{
    _sdBeauty.value = _beauty_level;
    _sdWhitening.value = _whitening_level;
    _vBeauty.hidden = NO;
    [_vhPickerView scrollToElement:_filterType animated:NO];
}

/**
 @method 获取指定宽度width的字符串在UITextView上的高度
 @param textView 待计算的UITextView
 @param Width 限制字符串显示区域的宽度
 @result float 返回的高度
 */
- (float) heightForString:(UITextView *)textView andWidth:(float)width{
    CGSize sizeToFit = [textView sizeThatFits:CGSizeMake(width, MAXFLOAT)];
    return sizeToFit.height;
}
- (void) toastTip:(NSString*)toastInfo
{
    CGRect frameRC = [[UIScreen mainScreen] bounds];
    frameRC.origin.y = frameRC.size.height - 110;
    frameRC.size.height -= 110;
    __block UITextView * toastView = [[UITextView alloc] init];
    
    toastView.editable = NO;
    toastView.selectable = NO;
    
    frameRC.size.height = [self heightForString:toastView andWidth:frameRC.size.width];
    
    toastView.frame = frameRC;
    
    toastView.text = toastInfo;
    toastView.backgroundColor = [UIColor whiteColor];
    toastView.alpha = 0.5;
    
    [self.view addSubview:toastView];
    
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 2 * NSEC_PER_SEC);
    
    dispatch_after(popTime, dispatch_get_main_queue(), ^(){
        [toastView removeFromSuperview];
        toastView = nil;
    });
}

-(void) clickHardware:(UIButton*) btn
{
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 8.0) {
        [self toastTip:@"iOS 版本低于8.0，不支持硬件加速."];
        return;
    }
    
    if(_txLivePublisher != nil) {
        TXLivePushConfig * configTmp = _txLivePublisher.config;
        if (configTmp.enableHWAcceleration == NO)
        {
            NSString* strTip = @"iOS SDK启用硬件加速.";
            if (_publish_switch == YES)
            {
                strTip = @"iOS SDK启用硬件加速，切换后会重新开始推流";
            }
            
            [self toastTip:strTip];
            configTmp.enableHWAcceleration = YES;
            [btn setImage:[UIImage imageNamed:@"quick"] forState:UIControlStateNormal];
        }
        else
        {
            NSString* strTip = @"iOS SDK停止硬件加速.";
            if (_publish_switch == YES)
            {
                strTip = @"iOS SDK停止硬件加速，切换后会重新开始推流";
            }
            
            [self toastTip:strTip];
            configTmp.enableHWAcceleration = NO;
            [btn setImage:[UIImage imageNamed:@"quick2"] forState:UIControlStateNormal];
        }
        _txLivePublisher.config = configTmp;
    }
}

-(void) clickMirror:(UIButton *)btn{
    _isMirror = ! _isMirror;
    [_txLivePublisher setMirror:_isMirror];
    
    if (_isMirror) {
        [_btnMirror setAlpha:1];
    }else{
        [_btnMirror setAlpha:0.5];
    }
}

-(void) clickLog:(UIButton*) btn
{
    if (_log_switch == YES)
    {
        _statusView.hidden = YES;
        _logViewEvt.hidden = YES;
        [btn setImage:[UIImage imageNamed:@"log"] forState:UIControlStateNormal];
        _cover.hidden = YES;
        _log_switch = NO;
    }
    else
    {
        _statusView.hidden = NO;
        _logViewEvt.hidden = NO;
        [btn setImage:[UIImage imageNamed:@"log2"] forState:UIControlStateNormal];
        _cover.hidden = NO;
        _log_switch = YES;
    }
    
}

-(void) clickScreenOrientation:(UIButton*) btn
{
    _screenPortrait = !_screenPortrait;
    
    if (_screenPortrait) {
        //activity竖屏模式，home在右横屏推流
        [btn setImage:[UIImage imageNamed:@"landscape"] forState:UIControlStateNormal];
        TXLivePushConfig* _config = _txLivePublisher.config;
        _config.homeOrientation = HOME_ORIENTATION_RIGHT;
        [_txLivePublisher setConfig:_config];
        [_txLivePublisher setRenderRotation:90];
        
        //activity竖屏模式，home在左横屏推流
        //        [btn setImage:[UIImage imageNamed:@"landscape"] forState:UIControlStateNormal];
        //        TXLivePushConfig* _config = _txLivePublisher.config;
        //        _config.homeOrientation = HOME_ORIENTATION_LEFT;
        //        [_txLivePublisher setConfig:_config];
        //        [_txLivePublisher setRenderRotation:270];
        
    } else {
        //activity竖屏模式，竖屏推流
        [btn setImage:[UIImage imageNamed:@"portrait"] forState:UIControlStateNormal];
        TXLivePushConfig* _config = _txLivePublisher.config;
        _config.homeOrientation = HOME_ORIENTATION_DOWN;
        [_txLivePublisher setConfig:_config];
        [_txLivePublisher setRenderRotation:0];
    }
}



- (void)statusBarOrientationChanged:(NSNotification *)note  {
    switch ([[UIDevice currentDevice] orientation]) {
        case UIDeviceOrientationPortrait:        //activity竖屏模式，竖屏推流
        {
            if (_deviceOrientation != UIDeviceOrientationPortrait) {
                TXLivePushConfig* _config = _txLivePublisher.config;
                _config.homeOrientation = HOME_ORIENTATION_DOWN;
                [_txLivePublisher setConfig:_config];
                [_txLivePublisher setRenderRotation:0];
                _deviceOrientation = UIDeviceOrientationPortrait;
            }
        }
            break;
        case UIDeviceOrientationLandscapeLeft:   //activity横屏模式，home在右横屏推流 注意：渲染view（demo里面是：preViewContainer）要跟着activity旋转
        {
            if (_deviceOrientation != UIDeviceOrientationLandscapeLeft) {
                TXLivePushConfig* _config = _txLivePublisher.config;
                _config.homeOrientation = HOME_ORIENTATION_RIGHT;
                [_txLivePublisher setConfig:_config];
                [_txLivePublisher setRenderRotation:0];
                _deviceOrientation = UIDeviceOrientationLandscapeLeft;
            }
            
        }
            break;
        case UIDeviceOrientationLandscapeRight:   //activity横屏模式，home在左横屏推流 注意：渲染view（demo里面是：preViewContainer）要跟着activity旋转
        {
            if (_deviceOrientation != UIDeviceOrientationLandscapeRight) {
                TXLivePushConfig* _config = _txLivePublisher.config;
                _config.homeOrientation = HOME_ORIENTATION_LEFT;
                [_txLivePublisher setConfig:_config];
                [_txLivePublisher setRenderRotation:0];
                _deviceOrientation = UIDeviceOrientationLandscapeRight;
            }
        }
            break;
        default:
            break;
    }
}

-(void) clickHD:(UIButton*) btn
{
    _vHD.hidden = NO;
}

-(void) changeHD:(UIButton*) btn
{
    if ([btn.titleLabel.text isEqualToString:@"720p"] && NO == [self isSuitableMachine:7]) {
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle: @"直播推流"
                                                         message: @"iphone 6 及以上机型适合开启720p!"
                                                        delegate: nil
                                               cancelButtonTitle: @"确认"
                                               otherButtonTitles: nil];
        [alert show];
        return;
    }
    
    if ([btn.titleLabel.text isEqualToString:@"540p"] && NO == [self isSuitableMachine:5]) {
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle: @"直播推流"
                                                         message: @"iphone 5 及以上机型适合开启540p!"
                                                        delegate: nil
                                               cancelButtonTitle: @"确认"
                                               otherButtonTitles: nil];
        [alert show];
        return;
    }
    
    if (_txLivePublisher == nil) return;
    
    //    if (_publish_switch == YES) {
    //        [self stopRtmp];
    //    }
    
    if ([btn.titleLabel.text isEqualToString:@"720p"]) {
        _hd_level                 = HD_LEVEL_720P;
        
        //        TXLivePushConfig* _config = _txLivePublisher.config;
        //        _config.videoBitratePIN   = 1500;
        //        _config.videoResolution   = [self isSuitableMachine:7 ] ? VIDEO_RESOLUTION_TYPE_720_1280 : VIDEO_RESOLUTION_TYPE_540_960;
        //        _config.enableAutoBitrate = NO;
        //        [_txLivePublisher setConfig:_config];
        [_txLivePublisher setVideoQuality:VIDEO_QUALITY_SUPER_DEFINITION];
    }else if ([btn.titleLabel.text isEqualToString:@"540p"]) {
        _hd_level                 = HD_LEVEL_540P;
        
        //        TXLivePushConfig* _config = _txLivePublisher.config;
        //        _config.videoBitratePIN   = 1000;
        //        _config.videoResolution   = [self isSuitableMachine:5 ] ? VIDEO_RESOLUTION_TYPE_540_960 : VIDEO_RESOLUTION_TYPE_360_640;
        //        _config.enableAutoBitrate = NO;
        //        [_txLivePublisher setConfig:_config];
        [_txLivePublisher setVideoQuality:VIDEO_QUALITY_HIGH_DEFINITION];
    }else if ([btn.titleLabel.text isEqualToString:@"360p"]) {
        _hd_level                 = HD_LEVEL_360P;
        
        [_txLivePublisher setVideoQuality:VIDEO_QUALITY_STANDARD_DEFINITION];
        //标清默认开启了码率自适应，需要关闭码率自适应
        TXLivePushConfig* _config = _txLivePublisher.config;
        _config.videoBitratePIN   = 700;
        //_config.videoResolution   = VIDEO_RESOLUTION_TYPE_360_640;
        _config.enableAutoBitrate = NO;
        [_txLivePublisher setConfig:_config];
        
        
    } else if ([btn.titleLabel.text isEqualToString:@"360+"]) {
        _hd_level                 = HD_LEVEL_360_PLUS;
        
        [_txLivePublisher setVideoQuality:VIDEO_QUALITY_STANDARD_DEFINITION];
        //        TXLivePushConfig* _config = _txLivePublisher.config;
        //        _config.videoBitrateMin   = 400;
        //        _config.videoBitrateMax   = 1000;
        //        _config.enableAutoBitrate = YES;
        //        _config.autoAdjustStrategy= AUTO_ADJUST_BITRATE_STRATEGY_1;
        //        [_txLivePublisher setConfig:_config]; // 此模式下设置bitrate无效
        //        _config.videoBitratePIN	= 700;
        //        _config.videoResolution   = VIDEO_RESOLUTION_TYPE_360_640;
        
        
    }
    
    TXLivePushConfig * configTmp = _txLivePublisher.config;
    if (configTmp.enableHWAcceleration == NO) {
        [_btnHardware setImage:[UIImage imageNamed:@"quick2"] forState:UIControlStateNormal];
    }
    else {
        [_btnHardware setImage:[UIImage imageNamed:@"quick"] forState:UIControlStateNormal];
    }
    
    [self setHDUI:_hd_level];
    _vHD.hidden = YES;
    
    //    if (_publish_switch == YES) {
    //        [self startRtmp];
    //    }
    
}

-(void) sliderValueChange:(UISlider*) obj
{
    // todo
    if (obj.tag == 0) { //美颜
        _beauty_level = obj.value;
    } else if (obj.tag == 1) { //美白
        _whitening_level = obj.value;
    }
    [_txLivePublisher setBeautyFilterDepth:_beauty_level setWhiteningFilterDepth:_whitening_level];
}


// iphone 6 及以上机型适合开启720p, 否则20帧的帧率可能无法达到, 这种"流畅不足,清晰有余"的效果并不好
-(BOOL) isSuitableMachine:(int)targetPlatNum
{
    int mib[2] = {CTL_HW, HW_MACHINE};
    size_t len = 0;
    char* machine;
    
    sysctl(mib, 2, NULL, &len, NULL, 0);
    
    machine = (char*)malloc(len);
    sysctl(mib, 2, machine, &len, NULL, 0);
    
    NSString* platform = [NSString stringWithCString:machine encoding:NSASCIIStringEncoding];
    free(machine);
    if ([platform length] > 6) {
        NSString * platNum = [NSString stringWithFormat:@"%C", [platform characterAtIndex: 6]];
        return ([platNum intValue] >= targetPlatNum);
    } else {
        return NO;
    }
    
}



#pragma -- UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (void) touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.txtRtmpUrl resignFirstResponder];
    _vHD.hidden = YES;
    _vBeauty.hidden = YES;
}
@end


