#ifndef __TX_LIVE_SDK_TYPE_DEF_H__
#define __TX_LIVE_SDK_TYPE_DEF_H__

#include "TXLiveSDKEventDef.h"

typedef NS_ENUM(NSInteger, TX_Enum_Type_LogLevel) {
    LOGLEVEL_NULL = 0,      // 不输出任何sdk log
    LOGLEVEL_ERROR = 1,     // 只输出ERROR的log
    LOGLEVEL_WARN = 2,      // 只输出ERROR 和 WARNNING的log
    LOGLEVEL_INFO = 3,      // 输出 INFO，WARNNING 和 ERROR 级别的log
    LOGLEVEL_DEBUG = 4     // 输出 DEBUG，INFO，WARNING和ERROR 级别的log
};


typedef NS_ENUM(NSInteger, TX_Enum_Type_HomeOrientation) {
    HOME_ORIENTATION_RIGHT  = 0,        // home在右边
    HOME_ORIENTATION_DOWN,              // home在下面
    HOME_ORIENTATION_LEFT,              // home在左边
    HOME_ORIENTATION_UP,                // home在上面
};

typedef NS_ENUM(NSInteger, TX_Enum_Type_RenderMode) {
    RENDER_MODE_FILL_SCREEN  = 0,    // 图像铺满屏幕
    RENDER_MODE_FILL_EDGE            // 图像长边填满屏幕
};

typedef NS_ENUM(NSInteger, TX_Enum_Type_BeautyFilterDepth) {
    BEAUTY_FILTER_DEPTH_CLOSE   = 0,    // 关闭美颜
    // 1 ~ 9
    BEAUTY_FILTER_DEPTH_MAX     = 9,    // 最大美颜强度
};

//说明：SDK的视频采集模块只支持前3种分辨率，即：360*640 540*960 720*1280
//     如果厂商自己负责视频采集，向SDK填充YUV数据，可以使用全部6种分辨率
typedef NS_ENUM(NSInteger, TX_Enum_Type_VideoResolution) {
    VIDEO_RESOLUTION_TYPE_360_640 = 0,
    VIDEO_RESOLUTION_TYPE_540_960,
    VIDEO_RESOLUTION_TYPE_720_1280,
    VIDEO_RESOLUTION_TYPE_640_360,
    VIDEO_RESOLUTION_TYPE_960_540,
    VIDEO_RESOLUTION_TYPE_1280_720,
    VIDEO_RESOLUTION_TYPE_320_480,  
};

/**
*  \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\  推流的画面质量选项  \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
* 
*  - 1.9.1 版本开始引入推流画质接口 setVideoQuality 用于傻瓜化的选择推流画质效果。
*  - TXLivePush::setVideoQuality 内部通过 TXLivePushConfig 实现几种不同场景和风格的推流质量
*  - 目前支持的几种画质选项如下：
*
*  （1）标清 - 采用 360 * 640 级别分辨率，码率会在 400kbps - 800kbps 之间自适应，如果主播的网络条件不理想，
*              直播的画质会偏模糊，但总体卡顿率不会太高。
*              Android平台下这一档我们会选择采用软编码，软编码虽然更加耗电，但在运动画面的表现要由于硬编码。
*
*  （2）高清 - 采用 540 * 960 级别分辨率，码率会锁定在 1000kbps，如果主播的网络条件不理想，直播画质不会有变化，
*              但这段时间内会出现频繁的卡顿和跳帧。 两个平台下，这一档我们都会采用硬编码。
*
*  （3）超清 - 采用 720 * 1280 级别分辨率，码率会锁定在 1500kbps，对主播的上行带宽要求比较高，适合观看端是大屏的业务场景。
*   
*  （4）大主播 - 顾名思义，连麦中大主播使用，因为是观众的主画面，追求清晰一些的效果，所以分辨率会优先选择 540 * 960。
*
*  （5）小主播 - 顾名思义，连麦中小主播使用，因为是小画面，画面追求流畅，分辨率采用 320 * 480， 码率 350kbps 固定。
*              
* 【特别说明】
*  1. 如果是秀场直播，iOS 和 Android 都推荐使用[高清]，虽说“马上看壮士，月下观美人”是有这么一说，但是看完某椒就知道清晰有多么重要了。
*  2. 使用 setVideoQuality 之后，依然可以使用 TXLivePushConfig 设置画质，以最后一次的设置为准。
*  3. 如果您是手机端观看，那么一般不推荐使用【超清】选项，我们做过多组的画质主观评测，尤其是iOS平台，在小屏幕上观看几乎看不出差别。
*
*/


typedef NS_ENUM(NSInteger, TX_Enum_Type_VideoQuality) {
    VIDEO_QUALITY_STANDARD_DEFINITION       = 1,      //标清：建议追求流畅性的客户使用该选项
    VIDEO_QUALITY_HIGH_DEFINITION           = 2,      //高清：建议对清晰度有要求的客户使用该选项
    VIDEO_QUALITY_SUPER_DEFINITION          = 3,      //超清：如果不是大屏观看，不推荐使用
    VIDEO_QUALITY_LINKMIC_MAIN_PUBLISHER    = 4,      //连麦大主播
    VIDEO_QUALITY_LINKMIC_SUB_PUBLISHER     = 5,      //连麦小主播
};

typedef NS_ENUM(NSInteger, TX_Enum_Type_AutoAdjustStrategy) {
    AUTO_ADJUST_BITRATE_STRATEGY_1  = 0,
    AUTO_ADJUST_BITRATE_RESOLUTION_STRATEGY_1,
    AUTO_ADJUST_BITRATE_STRATEGY_2,
    AUTO_ADJUST_BITRATE_RESOLUTION_STRATEGY_2,
};

typedef NS_ENUM(NSInteger, TX_Enum_Type_AudioSampleRate) {
    AUDIO_SAMPLE_RATE_8000 = 0,
    AUDIO_SAMPLE_RATE_16000,
    AUDIO_SAMPLE_RATE_32000,
    AUDIO_SAMPLE_RATE_44100,
    AUDIO_SAMPLE_RATE_48000,
};

typedef NS_ENUM(NSInteger, TXVideoType) {
    VIDEO_TYPE_420SP       = 1,    // Android 视频采集格式   PixelFormat.YCbCr_420_SP 17
    VIDEO_TYPE_420YpCbCr   = 2,    // iOS 视频采集格式       kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange
    VIDEO_TYPE_420P        = 3,    // yuv420p格式           厂商自己负责视频采集，直接向SDK填充YUV数据
    VIDEO_TYPE_BGRA8888    = 4,    //
    VIDEO_TYPE_RGBA8888    = 5,    //
    VIDEO_TYPE_NV12        = 6,    // 
};


// 状态键名定义
#define NET_STATUS_CPU_USAGE         @"CPU_USAGE"        // cpu使用率
#define NET_STATUS_CPU_USAGE_D       @"CPU_USAGE_DEVICE" // 设备总CPU占用
#define NET_STATUS_VIDEO_BITRATE     @"VIDEO_BITRATE"    // 当前视频编码器输出的比特率，也就是编码器每秒生产了多少视频数据，单位 kbps
#define NET_STATUS_AUDIO_BITRATE     @"AUDIO_BITRATE"    // 当前音频编码器输出的比特率，也就是编码器每秒生产了多少音频数据，单位 kbps
#define NET_STATUS_VIDEO_FPS         @"VIDEO_FPS"        // 当前视频帧率，也就是视频编码器每条生产了多少帧画面
#define NET_STATUS_NET_SPEED         @"NET_SPEED"        // 当前的发送速度
#define NET_STATUS_NET_JITTER        @"NET_JITTER"       // 网络抖动情况，抖动越大，网络越不稳定
#define NET_STATUS_CACHE_SIZE        @"CACHE_SIZE"       // 缓冲区大小，缓冲区越大，说明当前上行带宽不足以消费掉已经生产的视频数据
#define NET_STATUS_DROP_SIZE         @"DROP_SIZE"
#define NET_STATUS_VIDEO_WIDTH       @"VIDEO_WIDTH"
#define NET_STATUS_VIDEO_HEIGHT      @"VIDEO_HEIGHT"
#define NET_STATUS_SERVER_IP         @"SERVER_IP"
#define NET_STATUS_CODEC_CACHE       @"CODEC_CACHE"      //编解码缓冲大小
#define NET_STATUS_CODEC_DROP_CNT    @"CODEC_DROP_CNT"   //编解码队列DROPCNT
#define NET_STATUS_SET_VIDEO_BITRATE @"SET_VIDEO_BITRATE"

#define EVT_MSG                      @"EVT_MSG"
#define EVT_TIME                     @"EVT_TIME"
#define EVT_PARAM1					 @"EVT_PARAM1"
#define EVT_PARAM2					 @"EVT_PARAM2"
#define EVT_PLAY_PROGRESS            @"EVT_PLAY_PROGRESS"
#define EVT_PLAY_DURATION            @"EVT_PLAY_DURATION"
#define EVT_REPORT_TOKEN             @"EVT_REPORT_TOKEN"

#define STREAM_ID                    @"STREAM_ID"

/* @brief 客户自定义的视频预处理函数原型
 * @param yuv_buffer：视频YUV数据，格式固定是YUV420 Planar
 * @param len_buffer：数据长度
 * @param width：     视频width
 * @param height：    视频height
 * @return
 * @remark （1）该函数会被SDK同步调用，故您需要同步返回预处理后的数据
 *         （2）处理后的数据长度必须和处理前保持一致
 *         （3）您或者直接处理yuv_buffer，或者将处理后的数据memcpy到yuv_buffer所指的内存区域，
 *             这块内存的生命期由SDK负责管理（也就是释放）
 */
typedef void (*PVideoProcessHookFunc)(unsigned char * yuv_buffer, int len_buffer, int width, int height);

/* @brief 客户自定义的音频预处理函数原型
 * @param pcm_buffer：   音频PCM数据
 * @param len_buffer：   数据长度
 * @param sample_rate：  采样频率
 * @param channels：     声道数
 * @param bit_size：     采样位宽
 * @return
 * @remark （1）该函数会被SDK同步调用，故您需要同步返回预处理后的数据
 *         （2）处理后的数据长度必须和处理前保持一致
 *         （3）您或者直接处理pcm_buffer，或者将处理后的数据memcpy到pcm_buffer所指的内存区域，
 *             这块内存的生命期由SDK负责管理（也就是释放）
 */
typedef void (*PAudioProcessHookFunc)(unsigned char * pcm_buffer, int len_buffer, int sample_rate, int channels, int bit_size);

#endif // __TX_LIVE_SDK_TYPE_DEF_H__
