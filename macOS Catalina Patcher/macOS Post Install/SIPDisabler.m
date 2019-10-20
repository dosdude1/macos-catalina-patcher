//
//  SIPDisabler.m
//  macOS Catalina Patcher
//
//  Created by Collin Mistr on 6/28/19.
//  Copyright (c) 2019 dosdude1 Apps. All rights reserved.
//

#import "SIPDisabler.h"

@implementation SIPDisabler

-(id)init {
    self = [super init];
    [self setID:@"sipPatch"];
    [self setVersion:0];
    [self setName:@"SIP Disabler Patch"];
    return self;
}
-(int)applyToVolume:(NSString *)volumePath {
    int ret = 0;
    ret = [self copyFile:[resourcePath stringByAppendingPathComponent:@"addonkexts/SIPManager.kext"] toDirectory:[volumePath stringByAppendingPathComponent:@"Library/Extensions"]];
    
    return ret;
}

@end
