#ifndef __TX_LIVE_SDK_EVENT_DEF_H__
#define __TX_LIVE_SDK_EVENT_DEF_H__

enum EventID
{
    /**
     * 推流事件列表
     */
/*step2*/    PUSH_EVT_CONNECT_SUCC            =  1001,   // 已经连接推流服务器
/*step3*/    PUSH_EVT_PUSH_BEGIN              =  1002,   // 已经与服务器握手完毕,开始推流
/*step1*/    PUSH_EVT_OPEN_CAMERA_SUCC        =  1003,   // 打开摄像头成功
    		 PUSH_EVT_CHANGE_RESOLUTION		  =  1005,	 //推流动态调整分辨率
			 PUSH_EVT_CHANGE_BITRATE          =  1006,   // 推流动态调整码率
			 PUSH_EVT_FIRST_FRAME_AVAILABLE   =  1007,   // 首帧画面采集完成
			 PUSH_EVT_START_VIDEO_ENCODER     =  1008,   // 编码器启动

	/*step1*/    PUSH_ERR_OPEN_CAMERA_FAIL        = -1301,   // 打开摄像头失败
/*step1*/    PUSH_ERR_OPEN_MIC_FAIL           = -1302,   // 打开麦克风失败
/*step3*/    PUSH_ERR_VIDEO_ENCODE_FAIL       = -1303,   // 视频编码失败
/*step3*/    PUSH_ERR_AUDIO_ENCODE_FAIL       = -1304,   // 音频编码失败
/*step1*/    PUSH_ERR_UNSUPPORTED_RESOLUTION  = -1305,   // 不支持的视频分辨率
/*step1*/    PUSH_ERR_UNSUPPORTED_SAMPLERATE  = -1306,   // 不支持的音频采样率
    
/*step2*/    PUSH_ERR_NET_DISCONNECT          = -1307,   // 网络断连,且经多次重连抢救无效,可以放弃治疗,更多重试请自行重启推流
    
/*step3*/    PUSH_WARNING_NET_BUSY            =  1101,   // 网络状况不佳：上行带宽太小，上传数据受阻
/*step2*/    PUSH_WARNING_RECONNECT           =  1102,   // 网络断连, 已启动自动重连 (自动重连连续失败超过三次会放弃)
/*step3*/    PUSH_WARNING_HW_ACCELERATION_FAIL=  1103,   // 硬编码启动失败，采用软编码
/*step3*/    PUSH_WARNING_VIDEO_ENCODE_FAIL   =  1104,   // 视频编码失败,非致命错,内部会重启编码器
/*step2*/    PUSH_WARNING_DNS_FAIL            =  3001,   // RTMP -DNS解析失败
/*step2*/    PUSH_WARNING_SEVER_CONN_FAIL     =  3002,   // RTMP服务器连接失败
/*step2*/    PUSH_WARNING_SHAKE_FAIL          =  3003,   // RTMP服务器握手失败
/*step3*/	 PUSH_WARNING_SERVER_DISCONNECT	  =  3004,	 // RTMP服务器主动断开，请检查推流地址的合法性或防盗链有效期

/*内部事件*/    INNER_EVT_SET_BITRATE_4_SCREEN_CAPTURE  = 100001,   // 动态设置录屏编码码率
    /**
     * 播放事件列表
     */
/*step1*/    PLAY_EVT_CONNECT_SUCC            =  2001,   // 已经连接服务器
/*step2*/    PLAY_EVT_RTMP_STREAM_BEGIN       =  2002,   // 已经连接服务器，开始拉流
/*step3*/    PLAY_EVT_RCV_FIRST_I_FRAME       =  2003,   // 渲染首个视频数据包(IDR)
/*step3*/    PLAY_EVT_PLAY_BEGIN              =  2004,   // 视频播放开始
/*step3*/    PLAY_EVT_PLAY_PROGRESS           =  2005,   // 视频播放进度
/*step3*/    PLAY_EVT_PLAY_END                =  2006,   // 视频播放结束
/*step3*/    PLAY_EVT_PLAY_LOADING			  =  2007,   // 视频播放loading
	         PLAY_EVT_START_VIDEO_DECODER     =  2008,   // 解码器启动

	/*step1*/    PLAY_ERR_NET_DISCONNECT          = -2301,   // 网络断连,且经多次重连抢救无效,可以放弃治疗,更多重试请自行重启播放
    
/*step3*/    PLAY_WARNING_VIDEO_DECODE_FAIL   =  2101,   // 当前视频帧解码失败
/*step3*/    PLAY_WARNING_AUDIO_DECODE_FAIL   =  2102,   // 当前音频帧解码失败
/*step1*/    PLAY_WARNING_RECONNECT           =  2103,   // 网络断连, 已启动自动重连 (自动重连连续失败超过三次会放弃)
/*step3*/    PLAY_WARNING_RECV_DATA_LAG       =  2104,   // 网络来包不稳：可能是下行带宽不足，或由于主播端出流不均匀
/*step3*/    PLAY_WARNING_VIDEO_PLAY_LAG      =  2105,   // 当前视频播放出现卡顿（用户直观感受）
/*step3*/    PLAY_WARNING_HW_ACCELERATION_FAIL=  2106,   // 硬解启动失败，采用软解
/*step3*/    PLAY_WARNING_VIDEO_DISCONTINUITY =  2107,   // 当前视频帧不连续，可能丢帧
/*step3*/    PLAY_WARNING_FIRST_IDR_HW_DECODE_FAIL =  2108,   // 当前流硬解第一个I帧失败，SDK自动切软解
/*step1*/    PLAY_WARNING_DNS_FAIL            =  3001,   // RTMP -DNS解析失败
/*step1*/    PLAY_WARNING_SEVER_CONN_FAIL     =  3002,   // RTMP服务器连接失败
/*step1*/    PLAY_WARNING_SHAKE_FAIL          =  3003,   // RTMP服务器握手失败
};

#endif // __TX_LIVE_SDK_TYPE_DEF_H__
