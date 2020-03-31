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
    ret = [self copyFile:[resourcePath stringByAppendingPathComponent:@"addonkexts/SIPManager.kext"] toDirectory:[volumePath stringByAppendingPathComponent:@"Library/Extensions"]];
    
    [self copyFile:[resourcePath stringByAppendingPathComponent:@"patchedfiles/boot.efi"] toDirectory:[volumePath stringByAppendingPathComponent:@"System/Library/CoreServices"]];
    [self copyFile:[resourcePath stringByAppendingPathComponent:@"patchedfiles/boot.efi"] toDirectory:[volumePath stringByAppendingPathComponent:@"usr/standalone/i386"]];
    
    
    NSMutableDictionary *bootPlist = [[NSMutableDictionary alloc]initWithContentsOfFile:[volumePath stringByAppendingString:@"/Library/Preferences/SystemConfiguration/com.apple.Boot.plist"]];
    NSString *kernelFlags = [bootPlist objectForKey:@"Kernel Flags"];
    if ([kernelFlags isEqualToString:@""])
    {
        kernelFlags = @"amfi_get_out_of_my_way=0x1";
    }
    else if ([kernelFlags rangeOfString:@"amfi_get_out_of_my_way"].location == NSNotFound)
    {
        kernelFlags = [kernelFlags stringByAppendingString:@" amfi_get_out_of_my_way=0x1"];
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
    
    [self copyFile:[resourcePath stringByAppendingPathComponent:@"patchedfiles/boot.efi"] toDirectory:[NSString stringWithFormat:@"/Volumes/Preboot/%@/System/Library/CoreServices", volumeUUID]];
    [bootPlist writeToFile:[NSString stringWithFormat:@"/Volumes/Preboot/%@/Library/Preferences/SystemConfiguration/com.apple.Boot.plist", volumeUUID] atomically:YES];
    
    NSTask *unmount = [[NSTask alloc] init];
    [unmount setLaunchPath:@"/usr/sbin/diskutil"];
    [unmount setArguments:@[@"unmount", prebootDisk]];
    [unmount launch];
    [unmount waitUntilExit];
    
    
    return ret;
}

@end
