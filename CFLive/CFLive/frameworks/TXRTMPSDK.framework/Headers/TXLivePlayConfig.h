#import <Foundation/NSObject.h>

@interface TXLivePlayConfig : NSObject

//播放器缓存时间 : 单位秒，取值需要大于0
@property (nonatomic, assign) float                 cacheTime;

//是否自动调整播放器缓存时间 : YES:启用自动调整，自动调整的最大值和最小值可以分别通过修改maxCacheTime和minCacheTime来设置；
//                         NO:关闭自动调整，采用默认的指定缓存时间(1s)，可以通过修改cacheTime来调整缓存时间.
@property (nonatomic, assign) BOOL                  bAutoAdjustCacheTime;

//播放器缓存自动调整的最大时间 : 单位秒，取值需要大于0
@property (nonatomic, assign) float                 maxAutoAdjustCacheTime;

//播放器缓存自动调整的最小时间 : 单位秒，取值需要大于0
@property (nonatomic, assign) float                 minAutoAdjustCacheTime;

//播放器连接重试次数 : 最小值为 1， 最大值为 10, 默认值为 3
@property (nonatomic, assign) int                   connectRetryCount;

//播放器连接重试间隔 : 单位秒，最小值为 3, 最大值为 30， 默认值为 3
@property (nonatomic, assign) int                   connectRetryInterval;

//是否开启回声消除
@property (nonatomic, assign) BOOL                  enableAEC;

@end
