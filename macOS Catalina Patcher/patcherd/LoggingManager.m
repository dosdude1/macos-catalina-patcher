//
//  LoggingManager.m
//  macOS Catalina Patcher
//
//  Created by Collin Mistr on 7/22/19.
//  Copyright (c) 2019 dosdude1 Apps. All rights reserved.
//

#import "LoggingManager.h"

@implementation LoggingManager

-(id)init {
    self = [super init];
    return self;
}
+ (LoggingManager *)sharedInstance {
    static LoggingManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}
-(void)setOutputPipe:(NSPipe *)pipe
{
    NSPipe *out = pipe;
    NSFileHandle *fh = [out fileHandleForReading];
    [fh waitForDataInBackgroundAndNotify];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedInfo:) name:NSFileHandleDataAvailableNotification object:fh];
}

- (void)receivedInfo:(NSNotification *)notification
{
    NSFileHandle *fh = [notification object];
    NSData *data = [fh availableData];
    if (data.length > 0)
    {
        [fh waitForDataInBackgroundAndNotify];
        NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        [self.delegate logDidUpdateWithText:str];
    }
}

@end
