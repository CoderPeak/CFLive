//
//  NSTimer+Block.h
//  CFLive
//
//  Created by 陈峰 on 2017/3/10.
//  Copyright © 2017年 Peak. All rights reserved.
//

#import <Foundation/Foundation.h>


#define WeakSelf  __weak typeof(self) weakSelf = self;
#define StrongSelf  __strong typeof(self) strongSelf = weakSelf;

@interface NSTimer (Block)

+ (NSTimer *)scheduledTimerWithTimeInterval:(NSTimeInterval)seconds block:(void (^)(NSTimer *timer))block repeats:(BOOL)repeats;

+ (NSTimer *)timerWithTimeInterval:(NSTimeInterval)seconds block:(void (^)(NSTimer *timer))block repeats:(BOOL)repeats;

@end
