//
//  PatchManager.m
//  macOS Catalina Patcher
//
//  Created by Collin Mistr on 8/3/19.
//  Copyright (c) 2019 dosdude1 Apps. All rights reserved.
//

#import "PatchManager.h"

@implementation PatchManager

-(id)init {
    self = [super init];
    return self;
}

-(int)copyFile:(NSString *)filePath toDirectory:(NSString *)dirPath {
    NSTask *copy = [[NSTask alloc] init];
    [copy setLaunchPath:@"/bin/cp"];
    [copy setArguments:@[@"-R", filePath, dirPath]];
    NSPipe *out = [NSPipe pipe];
    [copy setStandardOutput:out];
    [copy setStandardError:out];
    [[LoggingManager sharedInstance] setOutputPipe:out];
    [copy launch];
    [copy waitUntilExit];
    return [copy terminationStatus];
}
-(int)setPermsOnFile:(NSString *)path {
    int err = 0;
    NSTask *chmod = [[NSTask alloc] init];
    [chmod setLaunchPath:@"/bin/chmod"];
    [chmod setArguments:@[@"-R", @"755", path]];
    NSPipe *out = [NSPipe pipe];
    [chmod setStandardOutput:out];
    [chmod setStandardError:out];
    [[LoggingManager sharedInstance] setOutputPipe:out];
    [chmod launch];
    [chmod waitUntilExit];
    err = [chmod terminationStatus];
    if (err) {
        return err;
    }
    
    NSTask *chown = [[NSTask alloc] init];
    [chown setLaunchPath:@"/usr/sbin/chown"];
    [chown setArguments:@[@"-R", @"0:0", path]];
    out = [NSPipe pipe];
    [chown setStandardOutput:out];
    [chown setStandardError:out];
    [[LoggingManager sharedInstance] setOutputPipe:out];
    [chown launch];
    [chown waitUntilExit];
    err = [chown terminationStatus];
    return err;
}
@end
