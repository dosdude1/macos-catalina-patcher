//
//  LibraryValidation.m
//  macOS Catalina Patcher
//
//  Created by Collin Mistr on 3/24/20.
//  Copyright (c) 2020 dosdude1 Apps. All rights reserved.
//

#import "LibraryValidation.h"

@implementation LibraryValidation

-(id)init {
    self = [super init];
    [self setID:@"LibraryValidation"];
    [self setVersion:1];
    [self setName:@"Library Validation Disabler Patch"];
    return self;
}
-(int)applyToVolume:(NSString *)volumePath {
    NSString *plistPath = [volumePath stringByAppendingPathComponent:@"Library/Preferences/com.apple.security.libraryvalidation.plist"];
    NSMutableDictionary *libValPrefs;
    if ([[NSFileManager defaultManager] fileExistsAtPath:plistPath]) {
        libValPrefs = [[NSMutableDictionary alloc] initWithContentsOfFile:plistPath];
    } else {
        libValPrefs = [[NSMutableDictionary alloc] init];
    }
    [libValPrefs setObject:[NSNumber numberWithBool:YES] forKey:@"DisableLibraryValidation"];
    [libValPrefs writeToFile:plistPath atomically:YES];
    
    NSMutableDictionary *bootPlist = [[NSMutableDictionary alloc]initWithContentsOfFile:[volumePath stringByAppendingString:@"/Library/Preferences/SystemConfiguration/com.apple.Boot.plist"]];
    NSString *kernelFlags = [bootPlist objectForKey:@"Kernel Flags"];
    if ([kernelFlags isEqualToString:@""])
    {
        kernelFlags = @"amfi_get_out_of_my_way=0x1";
    }
    else if ([kernelFlags rangeOfString:@"amfi_get_out_of_my_way=0x1"].location == NSNotFound)
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
    
    [bootPlist writeToFile:[NSString stringWithFormat:@"/Volumes/Preboot/%@/Library/Preferences/SystemConfiguration/com.apple.Boot.plist", volumeUUID] atomically:YES];
    
    NSTask *unmount = [[NSTask alloc] init];
    [unmount setLaunchPath:@"/usr/sbin/diskutil"];
    [unmount setArguments:@[@"unmount", prebootDisk]];
    [unmount launch];
    [unmount waitUntilExit];
    
    return 0;
}
-(BOOL)shouldInstallOnMachineModel:(NSString *)model {
    NSDictionary *machinePatches = [macModels objectForKey:model];
    if (machinePatches) {
        return YES;
    }
    return NO;
}
@end
