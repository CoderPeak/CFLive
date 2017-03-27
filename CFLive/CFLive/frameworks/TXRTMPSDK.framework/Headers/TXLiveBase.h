#import "TXLiveSDKTypeDef.h"

@protocol TXLiveBaseDelegate <NSObject>

/**
 *  SDK内部不再负责log的输出，而是通过这个函数将全部log回调给SDK使用者，由SDK使用者来决定log如何处理
 *	使用方式，具体可参看Demo中实现：
 *	1.实现TXLiveBaseDelegate，建议在一个比较早的初始化类中如AppDelegate
 *  2.在初始化中设置此回调，eg：[TXLiveBase sharedInstance].delegate = self;
 **/
@optional
-(void) onLog:(NSString*)log LogLevel:(int)level WhichModule:(NSString*)module;

@end

@interface TXLiveBase : NSObject

@property (nonatomic, weak) id<TXLiveBaseDelegate> delegate;

+ (instancetype) sharedInstance;

/* setLogLevel 设置log输出级别
 *  level：参见 LOGLEVEL
 *
 */
-(void) setLogLevel:(TX_Enum_Type_LogLevel)level;

@end
