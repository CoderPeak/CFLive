//
//  CFPlayerViewController.m
//  CFMediaPlayer
//
//  Created by Peak on 17/3/17.
//  Copyright © 2017年 Peak. All rights reserved.
//

#import "LFLiveViewController.h"
#import <LFLiveKit.h>
#import <LFLiveKit/LFLiveKit.h>
#import "UIView+CFFrame.h"


@interface LFLiveViewController () <LFLiveSessionDelegate>
{
    UISlider*    _sdBeauty;
    UISlider*    _sdWhitening;
    
    float  _beauty_level;
    float  _whitening_level;
}
@property (weak, nonatomic) IBOutlet UIButton *beautifulBtn;
@property (weak, nonatomic) IBOutlet UIButton *livingBtn;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UIButton *beautifulLevelBtn;


/* 美颜程度 */
@property (nonatomic, strong) UIView *beautifulLevelView;
/*  */
@property (nonatomic, strong) UIButton *bgBtn;

/** RTMP地址 */
@property (nonatomic, copy) NSString *rtmpUrl;
@property (nonatomic, strong) LFLiveSession *session;
@property (nonatomic, weak) UIView *livingPreView;
@end


#define kBeautifulLevelViewH 80

@implementation LFLiveViewController
- (UIView *)livingPreView
{
    if (!_livingPreView) {
        UIView *livingPreView = [[UIView alloc] initWithFrame:self.view.bounds];
        livingPreView.backgroundColor = [UIColor clearColor];
        livingPreView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self.view insertSubview:livingPreView atIndex:0];
        _livingPreView = livingPreView;
    }
    return _livingPreView;
}
- (LFLiveSession*)session{
    if(!_session){
        /***   默认分辨率368 ＊ 640  音频：44.1 iphone6以上48  双声道  方向竖屏 ***/
        _session = [[LFLiveSession alloc] initWithAudioConfiguration:[LFLiveAudioConfiguration defaultConfiguration] videoConfiguration:[LFLiveVideoConfiguration defaultConfigurationForQuality:LFLiveVideoQuality_Medium2]];
//        _session = [[LFLiveSession alloc] initWithAudioConfiguration:[LFLiveAudioConfiguration defaultConfiguration] videoConfiguration:[LFLiveVideoConfiguration defaultConfigurationForQuality:LFLiveVideoQuality_Medium2] liveType:LFLiveRTMP];
    
        /**    自己定制高质量音频128K 分辨率设置为720*1280 方向竖屏 */
        /*
         LFLiveAudioConfiguration *audioConfiguration = [LFLiveAudioConfiguration new];
         audioConfiguration.numberOfChannels = 2;
         audioConfiguration.audioBitrate = LFLiveAudioBitRate_128Kbps;
         audioConfiguration.audioSampleRate = LFLiveAudioSampleRate_44100Hz;
         
         LFLiveVideoConfiguration *videoConfiguration = [LFLiveVideoConfiguration new];
         videoConfiguration.videoSize = CGSizeMake(720, 1280);
         videoConfiguration.videoBitRate = 800*1024;
         videoConfiguration.videoMaxBitRate = 1000*1024;
         videoConfiguration.videoMinBitRate = 500*1024;
         videoConfiguration.videoFrameRate = 15;
         videoConfiguration.videoMaxKeyframeInterval = 30;
         videoConfiguration.orientation = UIInterfaceOrientationPortrait;
         videoConfiguration.sessionPreset = LFCaptureSessionPreset720x1280;
         
         _session = [[LFLiveSession alloc] initWithAudioConfiguration:audioConfiguration videoConfiguration:videoConfiguration liveType:LFLiveRTMP];
         */
        
        // 设置代理
        _session.delegate = self;
        _session.running = YES;
        _session.preView = self.livingPreView;
    }
    return _session;
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBarHidden = YES;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.navigationController.navigationBarHidden = NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setup];
}

- (void)setup{
    self.beautifulBtn.layer.cornerRadius = self.beautifulBtn.cf_height * 0.5;
    self.beautifulBtn.layer.masksToBounds = YES;
    
    self.beautifulLevelBtn.layer.cornerRadius = self.beautifulLevelBtn.cf_height * 0.5;
    self.beautifulLevelBtn.layer.masksToBounds = YES;
    
    self.livingBtn.backgroundColor = [UIColor blueColor];
    self.livingBtn.layer.cornerRadius = self.livingBtn.cf_height * 0.5;
    self.livingBtn.layer.masksToBounds = YES;
    
    self.statusLabel.numberOfLines = 3;
    self.statusLabel.cf_height = 120;
    
    // 默认开启后置摄像头
    self.session.captureDevicePosition = AVCaptureDevicePositionBack;
}
// 关闭直播
- (IBAction)close {
    if (self.session.state == LFLivePending || self.session.state == LFLiveStart){
        [self.session stopLive];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

// 开启/关闭美颜相机
- (IBAction)beautiful:(UIButton *)sender {
    
    if (sender.selected) {
        self.beautifulLevelBtn.hidden = NO;
        self.session.beautyLevel = _beauty_level;
        self.session.brightLevel = _whitening_level;
    } else {
        self.beautifulLevelBtn.hidden = YES;
        self.session.beautyLevel = 0;
        self.session.brightLevel = 0;
    }
    
    sender.selected = !sender.selected;
    
    
    // 默认是开启了美颜功能的
//    self.session.beautyFace = !self.session.beautyFace;
    
    
    
    
}
- (IBAction)beautifulLevel:(UIButton *)sender {

    self.bgBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_bgBtn setFrame:[UIScreen mainScreen].bounds];
    [_bgBtn setBackgroundColor:[UIColor clearColor]];
    [_bgBtn addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
    [_bgBtn addSubview:self.beautifulLevelView];
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    
    [window addSubview:_bgBtn];
   
}

- (void)dismiss
{
    
    [_bgBtn removeFromSuperview];
    
}

/* 美颜程度 */
- (UIView *)beautifulLevelView
{
    if (!_beautifulLevelView) {
        _beautifulLevelView = [[UIView alloc] initWithFrame:CGRectMake(0, _beautifulLevelBtn.cf_maxY+10, CFScreenWidth, kBeautifulLevelViewH)];
        _beautifulLevelView.backgroundColor = [UIColor whiteColor];
        
        UILabel* txtBeauty = [[UILabel alloc]init];
        txtBeauty.frame = CGRectMake(10, 0, 80, kBeautifulLevelViewH/2);
        [txtBeauty setText:@"美颜效果"];
        [txtBeauty setFont:[UIFont fontWithName:@"" size:14]];
//        [txtBeauty sizeToFit];
        
        _sdBeauty = [[UISlider alloc] init];
        _sdBeauty.frame = CGRectMake(txtBeauty.cf_maxX + 10, 0, _beautifulLevelView.cf_width - (txtBeauty.cf_maxX + 20), kBeautifulLevelViewH/2);
        _sdBeauty.minimumValue = 0.0;
        _sdBeauty.maximumValue = 1.0;
        _sdBeauty.value = 0.5;
        
        [_sdBeauty setThumbImage:[UIImage imageNamed:@"circle"] forState:UIControlStateNormal];
        [_sdBeauty setMinimumTrackTintColor:[UIColor blackColor]];
        [_sdBeauty setMaximumTrackTintColor:[UIColor blackColor]];
        [_sdBeauty addTarget:self action:@selector(sliderValueChange:) forControlEvents:UIControlEventValueChanged];
        _sdBeauty.tag = 0;
        
        UILabel* txtWhitening = [[UILabel alloc] init];
        txtWhitening.frame = CGRectMake(10, kBeautifulLevelViewH/2, 80, kBeautifulLevelViewH/2);
        [txtWhitening setText:@"美白效果"];
        [txtWhitening setFont:[UIFont fontWithName:@"" size:14]];
//        [txtWhitening sizeToFit];
        
        _sdWhitening = [[UISlider alloc] init];
        _sdWhitening.frame = CGRectMake(txtWhitening.cf_maxX + 10, kBeautifulLevelViewH/2, _beautifulLevelView.cf_width - (txtWhitening.cf_maxX + 20), kBeautifulLevelViewH/2);
        _sdWhitening.minimumValue = 0.0;
        _sdWhitening.maximumValue = 1.0;
        _sdWhitening.value = 0.5;
        
        
        [_sdWhitening setThumbImage:[UIImage imageNamed:@"circle"] forState:UIControlStateNormal];
        [_sdWhitening setMinimumTrackTintColor:[UIColor blackColor]];
        [_sdWhitening setMaximumTrackTintColor:[UIColor blackColor]];
        [_sdWhitening addTarget:self action:@selector(sliderValueChange:) forControlEvents:UIControlEventValueChanged];
        _sdWhitening.tag = 1;

        [_beautifulLevelView addSubview:txtBeauty];
        [_beautifulLevelView addSubview:_sdBeauty];
        [_beautifulLevelView addSubview:txtWhitening];
        [_beautifulLevelView addSubview:_sdWhitening];
    }
    return _beautifulLevelView;
}

-(void) sliderValueChange:(UISlider*) obj
{
    // todo
    if (obj.tag == 0) { //美颜
        _beauty_level = obj.value;
    } else if (obj.tag == 1) { //美白
        _whitening_level = obj.value;
    }
    self.session.beautyLevel = _beauty_level;
    self.session.brightLevel = _whitening_level;
}


// 切换前置/后置摄像头
- (IBAction)switchCamare:(UIButton *)sender {
    AVCaptureDevicePosition devicePositon = self.session.captureDevicePosition;
    self.session.captureDevicePosition = (devicePositon == AVCaptureDevicePositionBack) ? AVCaptureDevicePositionFront : AVCaptureDevicePositionBack;
    NSLog(@"切换前置/后置摄像头");
}

- (IBAction)living:(UIButton *)sender {
    sender.selected = !sender.selected;
    if (sender.selected) { // 开始直播
        LFLiveStreamInfo *stream = [LFLiveStreamInfo new];
        // 填写自己电脑的IP地址
        // 本地服务器  ip地址为
        // stream.url = @"rtmp://ip:1935/rtmplive/CoderPeak";
        stream.url = @"rtmp://live.hkstv.hk.lxdns.com:1935/live/CoderPeak";
        self.rtmpUrl = stream.url;
        [self.session startLive:stream];
    }else{ // 结束直播
        [self.session stopLive];
        self.statusLabel.text = [NSString stringWithFormat:@"状态: 直播被关闭\n  %@", self.rtmpUrl];
    }
}

#pragma mark -- LFStreamingSessionDelegate
/** live status changed will callback */
- (void)liveSession:(nullable LFLiveSession *)session liveStateDidChange:(LFLiveState)state{
    NSString *tempStatus;
    switch (state) {
        case LFLiveReady:
            tempStatus = @"准备中";
            break;
        case LFLivePending:
            tempStatus = @"连接中";
            break;
        case LFLiveStart:
            tempStatus = @"已连接";
            break;
        case LFLiveStop:
            tempStatus = @"已断开";
            break;
        case LFLiveError:
            tempStatus = @"连接出错";
            break;
        default:
            break;
    }
    self.statusLabel.text = [NSString stringWithFormat:@"状态: %@\n  %@", tempStatus, self.rtmpUrl];
    
}

/** live debug info callback */
- (void)liveSession:(nullable LFLiveSession *)session debugInfo:(nullable LFLiveDebug*)debugInfo{
    
}

/** callback socket errorcode */
- (void)liveSession:(nullable LFLiveSession*)session errorCode:(LFLiveSocketErrorCode)errorCode{
    
}

@end

#pragma mark - 未继承前的代码
//#define h264outputWidth 1280
//#define h264outputHeight 720
//
//@interface LFLiveViewController () <GPUImageVideoCameraDelegate>
//{
//    ALinH264Encoder *_h264Encoder;
//}
//@property (nonatomic, strong) GPUImageVideoCamera *videoCamera;
//@property (nonatomic, strong) GPUImageView *filterView;
//@property (weak, nonatomic) IBOutlet UIButton *beautifulBtn;
//@property (nonatomic, strong) GPUImageMovieWriter *writer;
//@end
//
//@implementation LFLiveViewController
//
//- (void)viewDidLoad {
//    [super viewDidLoad];
//    
//    [self setup];
//}
//
//- (void)setup{
//    self.beautifulBtn.layer.cornerRadius = self.beautifulBtn.height * 0.5;
//    self.beautifulBtn.layer.masksToBounds = YES;
//    
//    // 开启前置摄像头的720
//    self.videoCamera = [[GPUImageVideoCamera alloc] initWithSessionPreset:AVCaptureSessionPreset1280x720 cameraPosition:AVCaptureDevicePositionFront];
//    self.videoCamera.outputImageOrientation = UIInterfaceOrientationPortrait;
//    self.videoCamera.delegate = self;
//    // 设置前置的时候不是镜像
//    self.videoCamera.horizontallyMirrorRearFacingCamera = YES;
//    [self.videoCamera addAudioInputsAndOutputs]; // 添加麦克风/声音的输出输入设备
//    self.filterView = [[GPUImageView alloc] initWithFrame:self.view.bounds];
//    self.filterView.center = self.view.center;
//    [self.view insertSubview:self.filterView atIndex:0];
//    [self.videoCamera addTarget:self.filterView];
//    [self.videoCamera startCameraCapture];
//    
//    // 默认开启美颜效果
//    [self openBeautiful];
//    
//    _h264Encoder = [ALinH264Encoder alloc];
//    [_h264Encoder initWithConfiguration];
//    [_h264Encoder initEncode:h264outputWidth height:h264outputHeight];
//}
//// 关闭直播
//- (IBAction)close {
//    [self dismissViewControllerAnimated:YES completion:nil];
//}
//
//// 开启/关闭美颜相机
//- (IBAction)beautiful:(UIButton *)sender {
//    sender.selected = !sender.selected;
//    if (!sender.selected) { // 开启了美图过滤
//        [self openBeautiful];
//    }else{ // 关闭美图过滤
//        [self.videoCamera removeAllTargets];
//        [self.videoCamera addTarget:self.filterView];
//    }
//}
//
//// 开启美颜效果
//- (void)openBeautiful
//{
//    [self.videoCamera removeAllTargets];
//    ALinGPUBeautifyFilter *beautifyFilter = [[ALinGPUBeautifyFilter alloc] init];
//    [self.videoCamera addTarget:beautifyFilter];
//    [beautifyFilter addTarget:self.filterView];
//}
//
//// 切换前置/后置摄像头
//- (IBAction)switchCamare:(UIButton *)sender {
//    [self.videoCamera rotateCamera];
//    NSLog(@"切换前置/后置摄像头");
//}
//
//#pragma mark - <GPUImageVideoCameraDelegate>
//- (void)willOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer
//{
//    // 获取当前的信息
//    CVPixelBufferRef bufferRef = CMSampleBufferGetImageBuffer(sampleBuffer);
//    // 获取视频宽度
//    size_t width =  CVPixelBufferGetWidth(bufferRef);
//    size_t height = CVPixelBufferGetHeight(bufferRef);
//    NSLog(@"%ld %ld", width, height);
//    NSLog(@"%@", [self.videoCamera videoCaptureConnection].audioChannels);
//    [_h264Encoder encode:sampleBuffer];
//}
//
//@end
