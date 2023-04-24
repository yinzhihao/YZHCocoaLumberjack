//
//  YZHLogFormatter.m
//  YZHCocoaLumberjack
//
//  Created by NO NAME on 2023/3/22.
//

#import "YZHLogFormatter.h"
#import <CocoaLumberjack/CocoaLumberjack.h>

@interface YZHLogFormatter ()
{
    int loggerCount;
    NSDateFormatter *threadUnsafeDateFormatter;
}
@end

@implementation YZHLogFormatter

- (instancetype)init
{
    self = [super init];
    if (self) {
        threadUnsafeDateFormatter = [[NSDateFormatter alloc] init];
        [threadUnsafeDateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss:SSS"];
    }
    return self;
}

#pragma mark - DDLogFormatter

- (nullable NSString *)formatLogMessage:(nonnull DDLogMessage *)logMessage {
    NSString *logLevel;
    switch (logMessage->_flag) {
        case DDLogFlagError:    logLevel = @"Error  ";  break;
        case DDLogFlagWarning:  logLevel = @"Warn   ";  break;
        case DDLogFlagInfo:     logLevel = @"Info   ";  break;
        case DDLogFlagDebug:    logLevel = @"Debug  ";  break;
        case DDLogFlagVerbose:  logLevel = @"Verbose";  break;
        default:                logLevel = @"Default";  break;
    }
    
    NSString *dateAndTime = [threadUnsafeDateFormatter stringFromDate:logMessage->_timestamp];
    NSString *logMsg = logMessage->_message;
    
#ifdef DEBUG
    return [NSString stringWithFormat:@"[%@] %@", logLevel, logMsg];
#else
    return [NSString stringWithFormat:@"[%@] [%@] %@", logLevel, dateAndTime, logMsg];
#endif
}

@end
