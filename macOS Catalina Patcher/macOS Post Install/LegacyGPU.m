//
//  LegacyGPU.m
//  macOS Catalina Patcher
//
//  Created by Collin Mistr on 6/27/19.
//  Copyright (c) 2019 dosdude1 Apps. All rights reserved.
//

#import "LegacyGPU.h"

@implementation LegacyGPU
-(id)init {
    self = [super init];
    [self setID:@"legacyGPU"];
    [self setVersion:12];
    [self setName:@"Legacy Video Card Patch"];
    return self;
}
-(int)applyToVolume:(NSString *)volumePath {
    int ret = 0;
    ret = [self copyFilesFromDirectory:[resourcePath stringByAppendingPathComponent:@"videocardpatches/gfxshared/kexts"] toPath:[volumePath stringByAppendingPathComponent:@"System/Library/Extensions"]];
    if (ret) {
        return ret;
    }
    
    //No errors for FWs as they will always return one
    
    [self copyFilesFromDirectory:[resourcePath stringByAppendingPathComponent:@"videocardpatches/gfxshared/frameworks"] toPath:[volumePath stringByAppendingPathComponent:@"System/Library/Frameworks"]];

    [self copyFilesFromDirectory:[resourcePath stringByAppendingPathComponent:@"videocardpatches/gfxshared/privateframeworks"] toPath:[volumePath stringByAppendingPathComponent:@"System/Library/PrivateFrameworks"]];
    
    //Copy wrappers
    ret = [self copyFilesFromDirectory:[resourcePath stringByAppendingPathComponent:@"videocardpatches/gfxshared/wrappers/CoreDisplay"] toPath:[volumePath stringByAppendingPathComponent:@"System/Library/Frameworks/CoreDisplay.framework/Versions/A"]];
    if (ret) {
        return ret;
    }
    ret = [self copyFilesFromDirectory:[resourcePath stringByAppendingPathComponent:@"videocardpatches/gfxshared/wrappers/SkyLight"] toPath:[volumePath stringByAppendingPathComponent:@"System/Library/PrivateFrameworks/SkyLight.framework/Versions/A"]];
    if (ret) {
        return ret;
    }
    
    //Copy kexts
    ret = [self copyFile:[resourcePath stringByAppendingPathComponent:@"videocardpatches/gfxshared/IOSurface"] toDirectory:[volumePath stringByAppendingPathComponent:@"System/Library/Extensions/IOSurface.kext/Contents/MacOS"]];
    if (ret) {
        return ret;
    }
    
    ret = [self copyFilesFromDirectory:[resourcePath stringByAppendingPathComponent:@"videocardpatches/intelarrandalegraphics"] toPath:[volumePath stringByAppendingPathComponent:@"System/Library/Extensions"]];
    if (ret) {
        return ret;
    }
    ret = [self copyFilesFromDirectory:[resourcePath stringByAppendingPathComponent:@"videocardpatches/intelsandybridgegraphics"] toPath:[volumePath stringByAppendingPathComponent:@"System/Library/Extensions"]];
    if (ret) {
        return ret;
    }
    ret = [self copyFilesFromDirectory:[resourcePath stringByAppendingPathComponent:@"videocardpatches/legacyamd"] toPath:[volumePath stringByAppendingPathComponent:@"System/Library/Extensions"]];
    if (ret) {
        return ret;
    }
    ret = [self copyFilesFromDirectory:[resourcePath stringByAppendingPathComponent:@"videocardpatches/legacynvidia"] toPath:[volumePath stringByAppendingPathComponent:@"System/Library/Extensions"]];
    if (ret) {
        return ret;
    }
    
    //Copy misc
    ret = [self copyFile:[resourcePath stringByAppendingPathComponent:@"videocardpatches/gfxshared/misc/MonitorPanels"] toDirectory:[volumePath stringByAppendingPathComponent:@"System/Library"]];
    
    return ret;
}

@end
