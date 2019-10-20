//
//  LegacyIDE.m
//  macOS Catalina Patcher
//
//  Created by Collin Mistr on 7/5/19.
//  Copyright (c) 2019 dosdude1 Apps. All rights reserved.
//

#import "LegacyIDE.h"

@implementation LegacyIDE

-(id)init {
    self = [super init];
    [self setID:@"legacyIDE"];
    [self setVersion:0];
    [self setName:@"Legacy Intel IDE Controller Patch"];
    return self;
}
-(int)applyToVolume:(NSString *)volumePath {
    int ret = 0;
    ret = [self copyFile:[resourcePath stringByAppendingPathComponent:@"patchedkexts/AppleIntelPIIXATA.kext"] toDirectory:[volumePath stringByAppendingPathComponent:@"System/Library/Extensions/IOATAFamily.kext/Contents/PlugIns"]];
    return ret;
}

@end
