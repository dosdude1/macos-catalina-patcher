//
//  AMDSSE4.m
//  macOS Catalina Patcher
//
//  Created by Collin Mistr on 10/19/19.
//  Copyright (c) 2019 dosdude1 Apps. All rights reserved.
//

#import "AMDSSE4.h"

@implementation AMDSSE4

-(id)init {
    self = [super init];
    [self setID:@"amdSSE4"];
    [self setVersion:2];
    [self setName:@"AMD Metal Driver SSE4.2 Emulation Layer"];
    return self;
}
-(int)applyToVolume:(NSString *)volumePath {
    int ret = 0;
    ret = [self copyFile:[resourcePath stringByAppendingPathComponent:@"addonkexts/AAAMouSSE.kext"] toDirectory:[volumePath stringByAppendingPathComponent:@"Library/Extensions"]];
    return ret;
}

@end
