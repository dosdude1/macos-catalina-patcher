//
//  InstallPatchUpdater.m
//  macOS Catalina Patcher
//
//  Created by Collin Mistr on 7/10/19.
//  Copyright (c) 2019 dosdude1 Apps. All rights reserved.
//

#import "InstallPatchUpdater.h"

@implementation InstallPatchUpdater

-(id)init {
    self = [super init];
    [self setID:@"patchUpdater"];
    [self setVersion:0];
    [self setName:@"Install Patch Updater"];
    return self;
}
-(int)applyToVolume:(NSString *)volumePath {
    int ret = 0;
    ret = [self copyFile:[resourcePath stringByAppendingPathComponent:@"Patch Updater.app"] toDirectory:[volumePath stringByAppendingPathComponent:@"System/Applications/Utilities"]];
    if (ret) {
        return ret;
    }
    if (![[NSFileManager defaultManager] fileExistsAtPath:[volumePath stringByAppendingPathComponent:@"usr/local/sbin"]]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:[volumePath stringByAppendingPathComponent:@"usr/local/sbin"] withIntermediateDirectories:YES attributes:nil error:nil];
    }
    ret = [self copyFile:[resourcePath stringByAppendingPathComponent:@"patchupdaterd"] toDirectory:[volumePath stringByAppendingPathComponent:@"usr/local/sbin"]];
    if (ret) {
        return ret;
    }
    ret = [self copyFile:[resourcePath stringByAppendingPathComponent:@"com.dosdude1.PatchUpdater.plist"] toDirectory:[volumePath stringByAppendingPathComponent:@"Library/LaunchAgents"]];
    if (ret) {
        return ret;
    }
    
    [self setPermissionsOnDirectory:[volumePath stringByAppendingPathComponent:@"Library/LaunchAgents/com.dosdude1.PatchUpdater.plist"]];
    
    ret = [self copyFile:[resourcePath stringByAppendingPathComponent:@"Patch Updater Prefpane.prefPane"] toDirectory:[volumePath stringByAppendingPathComponent:@"Library/PreferencePanes"]];
    if (ret) {
        return ret;
    }
    
    return ret;
}
-(NSString *)getUIActionString {
    return @"Installing";
}
-(BOOL)shouldInstallOnMachineModel:(NSString *)model {
    NSDictionary *machinePatches = [macModels objectForKey:model];
    if (machinePatches) {
        return YES;
    }
    return NO;
}
@end
