//
//  YZHLogManager.h
//  YZHCocoaLumberjack
//
//  Created by NO NAME on 2023/3/22.
//

#import <Foundation/Foundation.h>
#import <CocoaLumberjack/CocoaLumberjack.h>

/*
 ddLogLevel可依照需要设置为:
 DDLogLevelError / DDLogLevelWarning / DDLogLevelInfo / DDLogLevelDebug / DDLogLevelOff
 
 如果需要修改log格式, 可以修改MyCustomFormatter.m中的
 - (NSString *)formatLogMessage:(DDLogMessage *)logMessage
 方法.
 */
static const DDLogLevel ddLogLevel = DDLogLevelDebug;

#define YZHLogError(...) DDLogError(@"[Line %d] %s %@\n",__LINE__,__func__,[NSString stringWithFormat:__VA_ARGS__])

#define YZHLogWarn(...) DDLogWarn(@"[Line %d] %s %@\n",__LINE__,__func__,[NSString stringWithFormat:__VA_ARGS__])

#define YZHLogInfo(...) DDLogInfo(@"[Line %d] %s %@\n",__LINE__,__func__,[NSString stringWithFormat:__VA_ARGS__])

#define YZHLogDebug(...) DDLogDebug(@"[Line %d] %s %@\n",__LINE__,__func__,[NSString stringWithFormat:__VA_ARGS__])

typedef void(^YZHUploadFileLogBlock)(NSString * _Nonnull logFilePath);

typedef NS_ENUM(NSUInteger, YZHLogLevel) {
    YZHLogLevelError = 0,
    YZHLogLevelWarn,
    YZHLogLevelInfo,
    YZHLogLevelDebug,
    YZHLogLevelOff
};

typedef NS_ENUM(NSUInteger, YZHLogFrequency) {
    YZHFrequencyYear = 0,
    YZHFrequencyMonth,
    YZHFrequencyWeek,
    YZHFrequencyDay,
};

FOUNDATION_EXPORT NSInteger YZHDaysWithFrequency(YZHLogFrequency frequency);

NS_ASSUME_NONNULL_BEGIN

@interface YZHLogManager : NSObject

/**
 获取单例

 @return 单例
 */
+ (instancetype)sharedInstance;

/**
 开启日志文件系统, 默认日志文件保存1个月
 */
- (void)enableFileLogSystem;

/**
 开启自定义日志文件系统

 @param direct 日志文件文件夹地址
 @param freshFrequency 日志刷新频率
 */
- (void)enableFileLogSystemWithDirectory:(NSString *)direct freshTimeInterval:(YZHLogFrequency)freshFrequency;

/**
 获取当前的日志文件地址
注意日志文件名称含有空格

 @return 日志文件地址
 */
- (NSString *)getCurrentLogFilePath;

/**
 删除日志文件,
 注意调用删除日志文件的方法后, 要在下次启动才会产生新的日志文件

 @return 删除的结果
 */
- (BOOL)clearFileLog;

/**
 停止所有Log系统, 并清除日志文件
 */
- (void)stopLog;

/**
 上传Log文件, 注意日志文件名称含有空格

 @param uploadBlock 上传的Block
 */
- (void)uploadFileLogWithBlock:(YZHUploadFileLogBlock)uploadBlock;

/**
 设置定期上传文件, 不会立即发送 注意日志文件名称含有空格

 @param uploadBlock 上传文件的block
 @param uploadFrequency 上传频率
 */
- (void)uploadFileLogWithBlock:(YZHUploadFileLogBlock)uploadBlock
                 withFrequency:(YZHLogFrequency)uploadFrequency;

/**
 log 错误信息

 @param message 错误信息
 */
- (void)logEror:(NSString *)message;

/**
 Log 警告信息

 @param message 警告信息
 */
- (void)logWarn:(NSString *)message;

/**
 log 普通信息

 @param message 普通信息
 */
- (void)logInfo:(NSString *)message;

/**
 log 调试信息

 @param message 调试信息
 */
- (void)logDebug:(NSString *)message;

@end

NS_ASSUME_NONNULL_END
