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
    [self setVersion:0];
    [self setName:@"Platform Check Patch"];
    return self;
}
-(int)applyToVolume:(NSString *)volumePath {
    int ret = 0;
    NSMutableDictionary *bootPlist = [[NSMutableDictionary alloc]initWithContentsOfFile:[volumePath stringByAppendingString:@"/Library/Preferences/SystemConfiguration/com.apple.Boot.plist"]];
    NSString *kernelFlags = [bootPlist objectForKey:@"Kernel Flags"];
    if ([kernelFlags isEqualToString:@""])
    {
        kernelFlags = @"-no_compat_check";
    }
    else if ([kernelFlags rangeOfString:@"-no_compat_check"].location == NSNotFound)
    {
        kernelFlags = [kernelFlags stringByAppendingString:@" -no_compat_check"];
    }
    [bootPlist setObject:kernelFlags forKey:@"Kernel Flags"];
    [bootPlist writeToFile:[volumePath stringByAppendingString:@"/Library/Preferences/SystemConfiguration/com.apple.Boot.plist"] atomically:YES];
    
    NSString *prebootDisk = [[APFSManager sharedInstance] getPrebootVolumeforAPFSVolumeAtPath:volumePath];
    NSString *volumeUUID = [[APFSManager sharedInstance] getUUIDOfVolumeAtPath:volumePath];
    NSTask *mount = [[NSTask alloc] init];
    [mount setLaunchPath:@"/usr/sbin/diskutil"];
    [mount setArguments:@[@"mount", prebootDisk]];
    [mount launch];
    [mount waitUntilExit];
    
    [bootPlist writeToFile:[NSString stringWithFormat:@"/Volumes/Preboot/%@/Library/Preferences/SystemConfiguration/com.apple.Boot.plist", volumeUUID] atomically:YES];
    
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
