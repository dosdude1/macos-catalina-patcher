//
//  MCPEnet.m
//  macOS Catalina Patcher
//
//  Created by Collin Mistr on 6/28/19.
//  Copyright (c) 2019 dosdude1 Apps. All rights reserved.
//

#import "LegacyEnet.h"

@implementation LegacyEnet

-(id)init {
    self = [super init];
    [self setID:@"legacyEnet"];
    [self setVersion:0];
    [self setName:@"Legacy Ethernet Patch"];
    return self;
}
-(int)applyToVolume:(NSString *)volumePath {
    int ret = 0;
    ret = [self copyFilesFromDirectory:[resourcePath stringByAppendingPathComponent:@"patchedkexts/ethernet"] toPath:[volumePath stringByAppendingPathComponent:@"System/Library/Extensions/IONetworkingFamily.kext/Contents/PlugIns"]];
    return ret;
}


@end
