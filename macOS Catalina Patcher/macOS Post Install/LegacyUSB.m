//
//  LegacyUSB.m
//  macOS Catalina Patcher
//
//  Created by Collin Mistr on 6/28/19.
//  Copyright (c) 2019 dosdude1 Apps. All rights reserved.
//

#import "LegacyUSB.h"

@implementation LegacyUSB

-(id)init {
    self = [super init];
    [self setID:@"legacyusb"];
    [self setVersion:1];
    [self setName:@"Legacy USB Support Injector"];
    return self;
}
-(int)applyToVolume:(NSString *)volumePath {
    int ret = 0;
    ret = [self copyFile:[resourcePath stringByAppendingPathComponent:@"addonkexts/LegacyUSBInjector.kext"] toDirectory:[volumePath stringByAppendingPathComponent:@"Library/Extensions"]];
    if (ret) {
        return ret;
    }
    ret = [self copyFile:[resourcePath stringByAppendingPathComponent:@"addonkexts/LegacyUSBVideoSupport.kext"] toDirectory:[volumePath stringByAppendingPathComponent:@"Library/Extensions"]];
    
    return ret;
}

@end
