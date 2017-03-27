//
//  NSTimer+Block.m
//  CFLive
//
//  Created by 陈峰 on 2017/3/10.
//  Copyright © 2017年 Peak. All rights reserved.
//

#import "NSTimer+Block.h"

@implementation NSTimer (Block)

+ (void)cf_ExecBlock:(NSTimer *)timer {
    if ([timer userInfo]) {
        void (^block)(NSTimer *timer) = (void (^)(NSTimer *timer))[timer userInfo];
        block(timer);
    }
}

+ (NSTimer *)scheduledTimerWithTimeInterval:(NSTimeInterval)seconds block:(void (^)(NSTimer *timer))block repeats:(BOOL)repeats {
    return [NSTimer scheduledTimerWithTimeInterval:seconds target:self selector:@selector(cf_ExecBlock:) userInfo:[block copy] repeats:repeats];
}

+ (NSTimer *)timerWithTimeInterval:(NSTimeInterval)seconds block:(void (^)(NSTimer *timer))block repeats:(BOOL)repeats {
    return [NSTimer timerWithTimeInterval:seconds target:self selector:@selector(cf_ExecBlock:) userInfo:[block copy] repeats:repeats];
}
@end
