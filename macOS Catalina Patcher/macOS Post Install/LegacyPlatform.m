//
//  LegacyPlatform.m
//  macOS Catalina Patcher
//
//  Created by Collin Mistr on 6/28/19.
//  Copyright (c) 2019 dosdude1 Apps. All rights reserved.
//

#import "LegacyPlatform.h"

@implementation LegacyPlatform
-(id)init {
    self = [super init];
    [self setID:@"legacyPlatform"];
    [self setVersion:0];
    [self setName:@"Legacy Platform Compatibility Patch"];
    return self;
}
-(int)applyToVolume:(NSString *)volumePath {
    
    [[NSFileManager defaultManager] removeItemAtPath:[volumePath stringByAppendingPathComponent:@"System/Library/UserEventPlugins/com.apple.telemetry.plugin"] error:nil];
    
    return 0;
}
@end
