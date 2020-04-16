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
    [self setVersion:1];
    [self setName:@"Platform Check Patch"];
    return self;
}
-(int)applyToVolume:(NSString *)volumePath {
    
    int ret = 0;
    
    const NSString *kSupportedBoardIDs = @"SupportedBoardIds";
    const NSString *kSupportedModels = @"SupportedModelProperties";
    
    NSMutableDictionary *bootPlist = [[NSMutableDictionary alloc]initWithContentsOfFile:[volumePath stringByAppendingPathComponent:@"Library/Preferences/SystemConfiguration/com.apple.Boot.plist"]];
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
    [bootPlist writeToFile:[volumePath stringByAppendingPathComponent:@"Library/Preferences/SystemConfiguration/com.apple.Boot.plist"] atomically:YES];
    
    NSDictionary *legacyPlatformSupport = [[NSDictionary alloc] initWithContentsOfFile:[resourcePath stringByAppendingPathComponent:@"PlatformSupportLegacy.plist"]];
    NSArray *legacyBoardSupport = [legacyPlatformSupport objectForKey:kSupportedBoardIDs];
    NSArray *legacyModelSupport = [legacyPlatformSupport objectForKey:kSupportedModels];
    
    NSMutableDictionary *platformSupport = [[NSMutableDictionary alloc] initWithContentsOfFile:[volumePath stringByAppendingPathComponent:@"System/Library/CoreServices/PlatformSupport.plist"]];
    NSMutableArray *boardSupport = [platformSupport objectForKey:kSupportedBoardIDs];
    NSMutableArray *modelSupport = [platformSupport objectForKey:kSupportedModels];
    
    for (NSString *boardID in legacyBoardSupport) {
        if (![boardSupport containsObject:boardID]) {
            [boardSupport addObject:boardID];
        }
    }
    
    for (NSString *modelID in legacyModelSupport) {
        if (![modelSupport containsObject:modelID]) {
            [modelSupport addObject:modelID];
        }
    }
    
    [platformSupport setObject:boardSupport forKey:kSupportedBoardIDs];
    [platformSupport setObject:modelSupport forKey:kSupportedModels];
    
    [platformSupport writeToFile:[volumePath stringByAppendingPathComponent:@"System/Library/CoreServices/PlatformSupport.plist"] atomically:YES];
    
    
    NSString *prebootDisk = [[APFSManager sharedInstance] getPrebootVolumeforAPFSVolumeAtPath:volumePath];
    NSString *recoveryDisk = [[APFSManager sharedInstance] getRecoveryVolumeforAPFSVolumeAtPath:volumePath];
    NSString *volumeUUID = [[APFSManager sharedInstance] getUUIDOfVolumeAtPath:volumePath];
    NSTask *mount = [[NSTask alloc] init];
    [mount setLaunchPath:@"/usr/sbin/diskutil"];
    [mount setArguments:@[@"mount", prebootDisk]];
    [mount launch];
    [mount waitUntilExit];
    
    mount = [[NSTask alloc] init];
    [mount setLaunchPath:@"/usr/sbin/diskutil"];
    [mount setArguments:@[@"mount", recoveryDisk]];
    [mount launch];
    [mount waitUntilExit];
    
    [bootPlist writeToFile:[NSString stringWithFormat:@"/Volumes/Preboot/%@/Library/Preferences/SystemConfiguration/com.apple.Boot.plist", volumeUUID] atomically:YES];
    
    [platformSupport writeToFile:[NSString stringWithFormat:@"/Volumes/Preboot/%@/System/Library/CoreServices/PlatformSupport.plist", volumeUUID] atomically:YES];
    [platformSupport writeToFile:[NSString stringWithFormat:@"/Volumes/Recovery/%@/PlatformSupport.plist", volumeUUID] atomically:YES];
    
    [self copyFile:[resourcePath stringByAppendingPathComponent:@"prelinkedkernel"] toDirectory:[NSString stringWithFormat:@"/Volumes/Recovery/%@", volumeUUID]];
    
    NSTask *unmount = [[NSTask alloc] init];
    [unmount setLaunchPath:@"/usr/sbin/diskutil"];
    [unmount setArguments:@[@"unmount", prebootDisk]];
    [unmount launch];
    [unmount waitUntilExit];
    
    unmount = [[NSTask alloc] init];
    [unmount setLaunchPath:@"/usr/sbin/diskutil"];
    [unmount setArguments:@[@"unmount", recoveryDisk]];
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
