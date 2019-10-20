//
//  VolumeControlPatch.m
//  macOS Catalina Patcher
//
//  Created by Collin Mistr on 10/15/19.
//  Copyright (c) 2019 dosdude1 Apps. All rights reserved.
//

#import "VolumeControlPatch.h"

@implementation VolumeControlPatch

-(id)init {
    self = [super init];
    [self setID:@"volControlPatch"];
    [self setVersion:0];
    [self setName:@"Volume Control Patch"];
    return self;
}
-(int)applyToVolume:(NSString *)volumePath {
    int ret = 0;
    ret = [self copyFilesFromDirectory:[resourcePath stringByAppendingPathComponent:@"patchedkexts/volControl"] toPath:[volumePath stringByAppendingPathComponent:@"System/Library/Extensions"]];
    return ret;
}

@end
