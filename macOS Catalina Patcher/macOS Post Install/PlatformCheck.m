//
//  PlatformCheck.m
//  macOS Catalina Patcher
//
//  Created by Collin Mistr on 6/29/19.
//  Copyright (c) 2019 dosdude1 Apps. All rights reserved.
//

#import "PlatformCheck.h"

@implementation PlatformCheck

-(id)init {
    self = [super init];
    [self setID:@"platformCheckPatch"];
    [self setVersion:2];
    [self setName:@"Platform Check Patch"];
    return self;
}
-(int)applyToVolume:(NSString *)volumePath {
    
    int ret = 0;
    
    [self setBootPlistAtPath:[volumePath stringByAppendingPathComponent:@"Library/Preferences/SystemConfiguration/com.apple.Boot.plist"]];
    [self setPlatformSupportPlistAtPath:[volumePath stringByAppendingPathComponent:@"System/Library/CoreServices/PlatformSupport.plist"]];
    
    NSString *prebootDisk = [[APFSManager sharedInstance] getPrebootVolumeforAPFSVolumeAtPath:volumePath];
    NSString *volumeUUID = [[APFSManager sharedInstance] getUUIDOfVolumeAtPath:volumePath];
    NSTask *mount = [[NSTask alloc] init];
    [mount setLaunchPath:@"/usr/sbin/diskutil"];
    [mount setArguments:@[@"mount", prebootDisk]];
    [mount launch];
    [mount waitUntilExit];
    
    [self setBootPlistAtPath:[NSString stringWithFormat:@"/Volumes/Preboot/%@/Library/Preferences/SystemConfiguration/com.apple.Boot.plist", volumeUUID]];
    [self setPlatformSupportPlistAtPath:[NSString stringWithFormat:@"/Volumes/Preboot/%@/System/Library/CoreServices/PlatformSupport.plist", volumeUUID]];
    
    NSTask *unmount = [[NSTask alloc] init];
    [unmount setLaunchPath:@"/usr/sbin/diskutil"];
    [unmount setArguments:@[@"unmount", prebootDisk]];
    [unmount launch];
    [unmount waitUntilExit];
    
    return ret;
}

-(BOOL)shouldInstallOnMachineModel:(NSString *)model {
    NSDictionary *machinePatches = [macModels objectForKey:model];
    if (machinePatches) {
        return YES;
    }
    return NO;
}
@end
