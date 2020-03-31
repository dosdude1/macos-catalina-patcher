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
    [self setVersion:2];
    [self setName:@"SIP Disabler Patch"];
    return self;
}
-(int)applyToVolume:(NSString *)volumePath {
    int ret = 0;
    
    ret = [self copyFile:[resourcePath stringByAppendingPathComponent:@"patchedfiles/boot.efi"] toDirectory:[volumePath stringByAppendingPathComponent:@"System/Library/CoreServices"]];
    if (ret) {
        return ret;
    }
    
    ret = [self copyFile:[resourcePath stringByAppendingPathComponent:@"patchedfiles/boot.efi"] toDirectory:[volumePath stringByAppendingPathComponent:@"usr/standalone/i386"]];
    if (ret) {
        return ret;
    }
    
    NSString *prebootDisk = [[APFSManager sharedInstance] getPrebootVolumeforAPFSVolumeAtPath:volumePath];
    NSString *volumeUUID = [[APFSManager sharedInstance] getUUIDOfVolumeAtPath:volumePath];
    NSTask *mount = [[NSTask alloc] init];
    [mount setLaunchPath:@"/usr/sbin/diskutil"];
    [mount setArguments:@[@"mount", prebootDisk]];
    [mount launch];
    [mount waitUntilExit];
    
    ret = [self copyFile:[resourcePath stringByAppendingPathComponent:@"patchedfiles/boot.efi"] toDirectory:[NSString stringWithFormat:@"/Volumes/Preboot/%@/System/Library/CoreServices", volumeUUID]];
    
    NSTask *unmount = [[NSTask alloc] init];
    [unmount setLaunchPath:@"/usr/sbin/diskutil"];
    [unmount setArguments:@[@"unmount", prebootDisk]];
    [unmount launch];
    [unmount waitUntilExit];
    
    
    return ret;
}

@end
