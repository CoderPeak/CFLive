#import <Foundation/NSObject.h>
#import <UIKit/UIKit.h>
#import "TXLiveSDKTypeDef.h"


#define CUSTOM_MODE_AUDIO_CAPTURE                   0X001   //厂商自定义音频采集
#define CUSTOM_MODE_VIDEO_CAPTURE                   0X002   //厂商自定义视频采集
#define CUSTOM_MODE_AUDIO_PREPROCESS                0X004   //厂商自定义音频预处理逻辑
#define CUSTOM_MODE_VIDEO_PREPROCESS                0X008   //厂商自定义视频预处理逻辑


#define TXRTMPSDK_LINKMIC_STREAMTYPE_MAIN           1       //连麦模式下主播的流
#define TXRTMPSDK_LINKMIC_STREAMTYPE_SUB            2       //连麦模式下连麦观众的流


@interface TXLivePushConfig : NSObject

// 厂商自定义模式
@property (nonatomic, assign)   int                     customModeType;

// 美颜强度 0 ~ 9
@property (nonatomic, assign)   float                   beautyFilterDepth;

// 美白强度:0 ~ 9
@property (nonatomic, assign)   float                   whiteningFilterDepth;

// 开启硬件加速
@property (nonatomic, assign)   BOOL                    enableHWAcceleration;

 /* home键所在方向，用来切换横竖屏推流（tips：此参数的设置可能会改变推流端本地视频流方向，此参数设置后，请调用TXLivePush 里的setRenderRotation 来修正推流端本地视频流方向，具体请参考demo设置 ）
 * 1,homeOrientation=HOME_ORIENTATION_RIGHT Home键在下竖屏推流
 * 2,homeOrientation=HOME_ORIENTATION_RIGHT Home键在右横屏推流
 * 3.homeOrientation=HOME_ORIENTATION_LEFT  Home键在左横屏推流
 */
@property (nonatomic, assign)   int                     homeOrientation;

// 视频采集帧率
@property (nonatomic, assign)   int                     videoFPS;

// 视频分辨率
@property (nonatomic, assign)   int                     videoResolution;

// 视频固定码率，
@property (nonatomic, assign)   int                     videoBitratePIN;

// 视频编码GOP，单位second 秒
@property (nonatomic, assign)   int                     videoEncodeGop;

// 音频采样率
@property (nonatomic, assign)   int                     audioSampleRate;

// 音频声道数
@property (nonatomic, assign)   int                     audioChannels;

// 码率自适应: SDK会根据网络情况自动调节视频码率, 调节范围在 (videoBitrateMin - videoBitrateMax)
@property (nonatomic, assign)   BOOL                    enableAutoBitrate;
//

// 码率自适应: SDK会根据网络情况自动调节视频码率，同时自动调整分辨率
@property (nonatomic, assign)	int                     autoAdjustStrategy;

// 视频最大码率，仅当enableAutoBitrate = YES时有效
@property (nonatomic, assign)   int                     videoBitrateMax;

// 视频最小码率，仅当enableAutoBitrate = YES时有效
@property (nonatomic, assign)   int                     videoBitrateMin;

// 噪音抑制
@property (nonatomic, assign)   BOOL                    enableNAS;

// 是否前置camera
@property (nonatomic, assign)   BOOL                    frontCamera;

//推流器连接重试次数 : 最小值为 1， 最大值为 10, 默认值为 3
@property (nonatomic, assign) int                       connectRetryCount;

//推流器连接重试间隔 : 单位秒，最小值为 3, 最大值为 30， 默认值为 3
@property (nonatomic, assign) int                       connectRetryInterval;

//设置水印图片. 设为nil等同于关闭水印
@property (nonatomic, retain) UIImage                   *watermark;

//设置水印图片位置
@property (nonatomic, assign) CGPoint                   watermarkPos;

/**
 *  视频预处理Hook
 */
@property (nonatomic, assign) PVideoProcessHookFunc     pVideoFuncPtr;

/**
 *  音频预处理Hook
 */
@property (nonatomic, assign) PAudioProcessHookFunc     pAudioFuncPtr;

/**
 * 发送自定义CMSampleBuffer的输出分辨率
 * 当设置此属性时，videoResolution自动失效
 *
 * @warn 调用sendVideoSampleBuffer必须设置此值，或者设置autoSampleBufferSize＝YES
 */
@property (assign) CGSize                               sampleBufferSize;

/**
 * 设置YES时，调用sendVideoSampleBuffer输出分辨率等于输入分辨率
 */
@property BOOL                                          autoSampleBufferSize;

// 开启音频硬件加速
@property (nonatomic, assign)   BOOL                    enableAudioAcceleration;

/**
 *  后台推流时长，单位秒，默认300秒
 */
@property (nonatomic, assign) int                       pauseTime;
/**
 *  后台推流帧率，最小值为5，最大值为20，默认10
 */
@property (nonatomic, assign) int                       pauseFps;
/**
 *  后台推流图片,图片最大尺寸不能超过1920*1920
 */
@property (nonatomic, retain) UIImage                   *pauseImg;

/**
 *  是否开启回声消除
 */
@property (nonatomic, assign) BOOL                      enableAEC;

/**
 *  是否开启耳返
 */
@property (nonatomic, assign) BOOL                      enableAudioPreview;

@end
