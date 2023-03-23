//
//  YZHLogManager.m
//  YZHCocoaLumberjack
//
//  Created by NO NAME on 2023/3/22.
//

#import "YZHLogManager.h"
#import "YZHLogFormatter.h"

#define LastUploadTimeIntervalKey @"LastUploadTimeIntervalKey"

@interface YZHLogManager ()

@property (nonatomic, strong) YZHUploadFileLogBlock uploadBlock;

@property (nonatomic, assign) YZHLogFrequency uploadFrequency;

@property (nonatomic, assign) NSTimeInterval lastUploadTimeInterval;

@property (nonatomic, assign) BOOL LogFileEnabled;

@property (nonatomic, strong) DDFileLogger *fileLogger;

@property (nonatomic, assign) double logFreshTimer;

@end

@implementation YZHLogManager

static YZHLogManager *_instance = nil;

/**
 获取单例

 @return 单例
 */
+ (instancetype)sharedInstance {
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[super allocWithZone:NULL] init];
        
        [DDLog addLogger:[DDOSLogger sharedInstance]];
        [DDOSLogger sharedInstance].logFormatter = [[YZHLogFormatter alloc] init];
    });
    
    _instance.lastUploadTimeInterval = [[NSUserDefaults standardUserDefaults] doubleForKey:LastUploadTimeIntervalKey] ? [[NSUserDefaults standardUserDefaults] doubleForKey:LastUploadTimeIntervalKey] : 0;
    
    return _instance;
}

+ (id)allocWithZone:(struct _NSZone *)zone {
    
    return [YZHLogManager sharedInstance];
}

- (id)copyWithZone:(struct _NSZone *)zone {
    
    return [YZHLogManager sharedInstance];
}

/**
 开启日志文件系统, 默认日志文件保存1个月
 */
- (void)enableFileLogSystem {
    
    _LogFileEnabled = YES;
    
    _fileLogger = [[DDFileLogger alloc] init];
    
    _fileLogger.rollingFrequency = 60 * 60 * 24 * 30;
    
    _fileLogger.logFormatter = [[YZHLogFormatter alloc] init];
    
    [DDLog addLogger:_fileLogger];
}

/**
 开启自定义日志文件系统

 @param direct 日志文件文件夹地址
 @param freshFrequency 日志刷新频率
 */
- (void)enableFileLogSystemWithDirectory:(NSString *)direct freshTimeInterval:(YZHLogFrequency)freshFrequency {
    
    _LogFileEnabled = YES;
    
    DDLogFileManagerDefault *logFileManager = [[DDLogFileManagerDefault alloc] initWithLogsDirectory:direct];
    
    _fileLogger = [[DDFileLogger alloc] initWithLogFileManager:logFileManager];
    
    switch (freshFrequency) {
        case YZHFrequencyYear:
            
            _logFreshTimer = 60 * 60 * 24 * 365;
            break;
            
        case YZHFrequencyMonth:
            
            _logFreshTimer = 60 * 60 * 24 * 30;
            break;
            
        case YZHFrequencyWeek:
            
            _logFreshTimer = 60 * 60 * 24 * 7;
            break;
            
        case YZHFrequencyDay:
            
            _logFreshTimer = 60 * 60 * 24;
            break;
            
        default:
            
            _logFreshTimer = 60 * 60 * 24 * 30;
            break;
    }
    
    _fileLogger.rollingFrequency = _logFreshTimer;
    
    [DDLog addLogger:_fileLogger];
}

/**
 获取当前的日志文件地址
注意日志文件名称含有空格

 @return 日志文件地址
 */
- (NSString *)getCurrentLogFilePath {
    
    if (_LogFileEnabled && _fileLogger) {
        
        return _fileLogger.currentLogFileInfo.filePath;
    } else {
        
        return @"";
    }
}

/**
 删除日志文件,
 注意调用删除日志文件的方法后, 要在下次启动才会产生新的日志文件

 @return 删除的结果
 */
- (BOOL)clearFileLog {
    
    if ([self getCurrentLogFilePath].length > 1) {
        
        NSError *error;
        NSFileManager *fileManager = [NSFileManager defaultManager];
        
        [fileManager removeItemAtPath:[self getCurrentLogFilePath] error:&error];
        
        if (!error) {
            
            return true;
        } else {
            
            return false;
        }
    }
    
    return true;
}

/**
 停止所有Log系统, 并清除日志文件
 */
- (void)stopLog {
    
    [self clearFileLog];
    _LogFileEnabled = NO;
    
    [DDLog removeAllLoggers];
}

/**
 上传Log文件, 注意日志文件名称含有空格

 @param uploadBlock 上传的Block
 */
- (void)uploadFileLogWithBlock:(YZHUploadFileLogBlock)uploadBlock {
    
    if ([self getCurrentLogFilePath].length > 1 && _LogFileEnabled) {
        
        if (uploadBlock) {
            uploadBlock([self getCurrentLogFilePath]);
        }
    }
}

/**
 设置定期上传文件, 不会立即发送 注意日志文件名称含有空格

 @param uploadBlock 上传文件的block
 @param uploadFrequency 上传频率
 */
- (void)uploadFileLogWithBlock:(YZHUploadFileLogBlock)uploadBlock
                 withFrequency:(YZHLogFrequency)uploadFrequency {
    
    self.uploadBlock = uploadBlock;
    self.uploadFrequency = uploadFrequency;
    
    if (_LogFileEnabled) {
        
        if (!self.lastUploadTimeInterval) {
            
            //获取当前的时间戳
            self.lastUploadTimeInterval = [[NSDate date] timeIntervalSince1970];
            
            //存储时间戳
            NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
            [userDefault setDouble:self.lastUploadTimeInterval forKey:LastUploadTimeIntervalKey];
        }
        
        NSTimeInterval currentTimeInterval = [[NSDate date] timeIntervalSince1970];
        
        NSInteger days = YZHDaysWithFrequency(uploadFrequency);
        
        if (currentTimeInterval - self.lastUploadTimeInterval > 60 * 60 * 24 * days) {
            
            if (uploadBlock) {
                uploadBlock([self getCurrentLogFilePath]);
            }
        }
    }
}

/**
 log 错误信息

 @param message 错误信息
 */
- (void)logEror:(NSString *)message {
    YZHLogError(@"%@", message);
}

/**
 Log 警告信息

 @param message 警告信息
 */
- (void)logWarn:(NSString *)message {
    YZHLogWarn(@"%@", message);
}

/**
 log 普通信息

 @param message 普通信息
 */
- (void)logInfo:(NSString *)message {
    YZHLogInfo(@"%@", message);
}

/**
 log 调试信息

 @param message 调试信息
 */
- (void)logDebug:(NSString *)message {
    YZHLogDebug(@"%@", message);
}

@end

NSInteger YZHDaysWithFrequency(YZHLogFrequency frequency) {
    NSInteger days;
    switch (frequency) {
        case YZHFrequencyYear:
            
            days = 365;
            break;
            
        case YZHFrequencyMonth:
            
            days = 30;
            break;
            
        case YZHFrequencyWeek:
            
            days = 7;
            break;
            
        case YZHFrequencyDay:
            
            days = 1;
            break;
            
        default:
            
            days = 30;
            break;
    }
    return days;
}
