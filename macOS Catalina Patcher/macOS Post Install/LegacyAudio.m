//
//  LegacyAudio.m
//  macOS Catalina Patcher
//
//  Created by Collin Mistr on 6/28/19.
//  Copyright (c) 2019 dosdude1 Apps. All rights reserved.
//

#import "LegacyAudio.h"

@implementation LegacyAudio

-(id)init {
    self = [super init];
    [self setID:@"legacyAudio"];
    [self setVersion:0];
    [self setName:@"Legacy Audio Patch"];
    return self;
}
-(int)applyToVolume:(NSString *)volumePath {
    int ret = 0;
    ret = [self copyFile:[resourcePath stringByAppendingPathComponent:@"patchedkexts/AppleHDA.kext"] toDirectory:[volumePath stringByAppendingPathComponent:@"System/Library/Extensions"]];
    return ret;
}

@end
