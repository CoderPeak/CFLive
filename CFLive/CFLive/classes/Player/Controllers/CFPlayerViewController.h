//
//  CFPlayerViewController.h
//  CFMediaPlayer
//
//  Created by Peak on 17/3/7.
//  Copyright © 2017年 Peak. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <TXRTMPSDK/TXLivePlayer.h>


#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>


@interface CFPlayerViewController : UIViewController
{
    TXLivePlayer *      _txLivePlayer;
    UITextView*         _statusView;
    UITextView*         _logViewEvt;
    unsigned long long  _startTime;
    unsigned long long  _lastTime;
    
    UIButton*           _btnPlay;
    UIButton*           _btnClose;
    UIView*             _cover;
    
    BOOL                _screenPortrait;
    BOOL                _renderFillScreen;
    BOOL                _log_switch;
    BOOL                _play_switch;
    AVCaptureSession *  _VideoCaptureSession;
    
    NSString*           _logMsg;
    NSString*           _tipsMsg;
    NSString*           _testPath;
    NSInteger           _cacheStrategy;
    
    UIButton*           _btnCacheStrategy;
    UIView*             _vCacheStrategy;
    UIButton*           _radioBtnFast;
    UIButton*           _radioBtnSmooth;
    UIButton*           _radioBtnAUTO;
    
    TXLivePlayConfig*   _config;
}

@property (nonatomic, retain) UITextField* txtRtmpUrl;
@property (nonatomic, assign) BOOL isLivePlay;



@end
