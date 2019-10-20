//
//  CatalinaPatcherLoggingManager.m
//  macOS Catalina Patcher
//
//  Created by Collin Mistr on 7/22/19.
//  Copyright (c) 2019 dosdude1 Apps. All rights reserved.
//

#import "CatalinaPatcherLoggingManager.h"

@implementation CatalinaPatcherLoggingManager

-(id)init {
    self = [super init];
    log = @"";
    
    return self;
}
+ (CatalinaPatcherLoggingManager *)sharedInstance {
    static CatalinaPatcherLoggingManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

-(NSString *)getCurrentLogText {
    return log;
}
-(void)updateLogWithText:(NSString *)text {
    log = [log stringByAppendingString:text];
    if ([self.delegate respondsToSelector:@selector(logDidUpdateWithText:)]) {
        [self.delegate logDidUpdateWithText:log];
    }
}
-(void)saveLogToPath:(NSString *)path {
    [log writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:nil];
}
-(void)resetLog {
    log = @"";
    if ([self.delegate respondsToSelector:@selector(logDidUpdateWithText:)]) {
        [self.delegate logDidUpdateWithText:log];
    }
}
@end
