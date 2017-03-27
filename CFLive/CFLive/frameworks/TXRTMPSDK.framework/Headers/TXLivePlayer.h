#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "TXLivePlayListener.h"
#import "TXLivePlayConfig.h"


typedef NS_ENUM(NSInteger, TX_Enum_PlayType){
    PLAY_TYPE_LIVE_RTMP = 0,          //RTMP直播
    PLAY_TYPE_LIVE_FLV,               //FLV直播
    PLAY_TYPE_VOD_FLV,                //FLV点播
    PLAY_TYPE_VOD_HLS,                //HLS点播
    PLAY_TYPE_VOD_MP4,                //MP4点播
    PLAY_TYPE_LIVE_RTMP_ACC,          //RTMP直播加速播放
};

@interface TXLivePlayer : NSObject

@property (nonatomic, weak)   id<TXLivePlayListener>  delegate;

@property (nonatomic, assign)  BOOL            enableHWAcceleration;

@property (nonatomic, copy)    TXLivePlayConfig *      config;

/* setupVideoWidget 创建Video渲染Widget,该控件承载着视频内容的展示。
 * 参数:
 *      frame : Widget在父view中的rc
 *      view  : 父view
 *      idx   : Widget在父view上的层级位置
 * 变更历史：1.5.2版本将参数frame废弃，设置此参数无效，控件大小与参数view的大小保持一致，如需修改控件的大小及位置，请调整父view的大小及位置
 * 参考文档：https://www.qcloud.com/doc/api/258/4736#step-3.3A-.E7.BB.91.E5.AE.9A.E6.B8.B2.E6.9F.93.E7.95.8C.E9.9D.A2
 */
- (void)setupVideoWidget:(CGRect)frame containView:(UIView*)view insertIndex:(unsigned int)idx;

/* 修改VideoWidget frame
 * 变更历史：1.5.2版本将此方法废弃，调用此方法无效，如需修改控件的大小及位置，请调整父view的大小及位置
 * 参考文档：https://www.qcloud.com/doc/api/258/4736#step-3.3A-.E7.BB.91.E5.AE.9A.E6.B8.B2.E6.9F.93.E7.95.8C.E9.9D.A2
 */
//- (void)resetVideoWidgetFrame:(CGRect)frame;

/* removeVideoWidget 移除Video渲染Widget
 */
- (void)removeVideoWidget;


/* startPlay 启动从指定URL播放RTMP音视频流
 * 参数:
 *      url : 完整的URL
 *      playType: 播放类型
 * 返回: 0 = OK
 */
- (int)startPlay:(NSString*)url type:(TX_Enum_PlayType)playType;

/* stopPlay 停止播放音视频流
 * 返回: 0 = OK
 */
- (int)stopPlay;

/* isPlaying 是否正在播放
 * 返回： YES 拉流中，NO 没有拉流
 */
- (bool)isPlaying;

/* pause 暂停播放，适用于点播，直播（此接口会暂停数据拉流，不会销毁播放器，暂停后，播放器会显示最后一帧数据图像）
 *
 */
- (void)pause;

/* resume 继续播放，适用于点播，直播
 *
 */
- (void)resume;

/*
 seek 播放跳转到音视频流某个时间
 * time: 流时间，单位为秒
 * 返回: 0 = OK
 */
- (int)seek:(float)time;


/*
* setRenderRotation 设置画面的方向
 * 参数：
 *       rotation : 详见 TX_Enum_Type_HomeOrientation 的定义.
 */
- (void)setRenderRotation:(int)rotation;

/* setRenderMode 设置画面的裁剪模式
 * 参数
 *       renderMode : 详见 TX_Enum_Type_RenderMode 的定义。
 */
- (void)setRenderMode:(int)renderMode;

/* getSDKVersion 获取SDK版本信息
 * 变更历史：1.5.2版本将此接口由实例方法变更为类方法，使用方式变更为[TXLivePlayer getSDKVersion]
 */
+ (NSArray*)getSDKVersion;

/**
 * 设置静音
 */
- (void)setMute:(BOOL)bEnable;

@end
