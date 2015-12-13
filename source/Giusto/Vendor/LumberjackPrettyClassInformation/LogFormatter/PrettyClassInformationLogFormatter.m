//
//  PrettyClassInformationLogFormatter.m
// 
//
//  Created by Vincil Bishop on 8/3/13.
//  Copyright (c) 2013 All rights reserved.
//

#import "PrettyClassInformationLogFormatter.h"

@implementation PrettyClassInformationLogFormatter

- (NSString *)formatLogMessage:(DDLogMessage *)logMessage
{
    /*
     int logLevel;
     int logFlag;
     int logContext;
     NSString *logMsg;
     NSDate *timestamp;
     char *file;
     char *function;
     int lineNumber;
     mach_port_t machThreadID;
     char *queueLabel;
     NSString *threadName;
     */
    NSString *logLevel;
    switch (logMessage->_flag)
    {
        case LOG_FLAG_ERROR : logLevel = @"Error"; break;
        case LOG_FLAG_WARN  : logLevel = @"Warning"; break;
        case LOG_FLAG_INFO  : logLevel = @"Information"; break;
        default             : logLevel = @"Verbose"; break;
    }
    
    NSDateFormatter *formatter=[[NSDateFormatter alloc]init];
    [formatter setLocale:[NSLocale currentLocale]];
    [formatter setDateFormat:@"yyyy.MM.dd HH:mm:ss+zzz"];
    NSString *dateString = [formatter stringFromDate:logMessage->_timestamp];
    
    NSString *longFileName = [NSString stringWithFormat:@"%@",logMessage->_file];
    
    NSString *fileName = [[longFileName componentsSeparatedByString:@"/"] lastObject];
    
    return [NSString stringWithFormat:@"[%@]:[%@]:[%@]:[%@:%lu]:[%@]:%@\n", dateString,logLevel,logMessage->_threadID,fileName,(unsigned long)logMessage->_line,logMessage->_function, logMessage->_message];
}

@end
