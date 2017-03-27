//
//  CFLivePushViewController.h
//  CFLive
//
//  Created by 陈峰 on 2017/3/9.
//  Copyright © 2017年 Peak. All rights reserved.
//


#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <TXRTMPSDK/TXLivePush.h>
#import "V8HorizontalPickerView.h"

typedef NS_ENUM(NSInteger,DemoFilterType) {
    FilterType_None 		= 0,
    FilterType_langman 		= 1,   //浪漫滤镜
    FilterType_qingxin 		= 2,   //清新滤镜
    FilterType_weimei 		= 3,   //唯美滤镜
    FilterType_fennen 		= 4,   //粉嫩滤镜
    FilterType_huaijiu 		= 5,   //怀旧滤镜
    FilterType_landiao 		= 6,   //蓝调滤镜
    FilterType_qingliang 	= 7,   //清凉滤镜
    FilterType_rixi 		= 8,   //日系滤镜
};

@interface CFLivePushViewController : UIViewController<V8HorizontalPickerViewDelegate,V8HorizontalPickerViewDataSource>
{
    BOOL _publish_switch;
    BOOL _hardware_switch;
    BOOL _log_switch;
    BOOL _camera_switch;
    CGFloat _specia_level;
    float  _beauty_level;
    float  _whitening_level;
    int    _filterType;
    int  _hd_level;
    BOOL _screenPortrait;
    BOOL _isMirror;
    
    UIButton*    _btnPublish;
    UIButton*    _btnCamera;
    UIButton*    _btnBeauty;
    UIButton*    _btnHardware;
    UIButton*    _btnLog;
    UIButton*    _btnResolution;
    UIButton*    _btnScreenOrientation;
    UIButton*    _btnMirror;
    
    UIButton*    _radioBtnHD;
    UIButton*    _radioBtnHD2;
    UIButton*    _radioBtnSD;
    UIButton*    _radioBtnAUTO;
    
    UISlider*    _sdSpecia;
    UISlider*    _sdBeauty;
    UISlider*    _sdWhitening;
    V8HorizontalPickerView* _vhPickerView;
    NSMutableArray* _filterArray;
    
    UILabel*     _txtSpecia;
    UILabel*     _txtBeauty;
    UILabel*     _txtWhitening;
    
    UIView*      _cover;
    
    UIControl*   _vBeauty;
    UIControl*   _vHD;
    
    TXLivePush * _txLivePublisher;
    
    UITextView*         _statusView;
    UITextView*         _logViewEvt;
    unsigned long long  _startTime;
    unsigned long long  _lastTime;
    
    NSString*       _logMsg;
    NSString*       _tipsMsg;
    NSString*       _testPath;
    BOOL            _isPreviewing;
}

@property (nonatomic, retain) UITextField* txtRtmpUrl;

@end

