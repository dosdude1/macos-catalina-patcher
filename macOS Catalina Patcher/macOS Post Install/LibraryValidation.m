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
    [self setVersion:6];
    [self setName:@"Library Validation Disabler Patch"];
    return self;
}
-(int)applyToVolume:(NSString *)volumePath {
    
    int ret = 0;
    
    NSString *plistPath = [volumePath stringByAppendingPathComponent:@"Library/Preferences/com.apple.security.libraryvalidation.plist"];
    NSMutableDictionary *libValPrefs;
    if ([[NSFileManager defaultManager] fileExistsAtPath:plistPath]) {
        libValPrefs = [[NSMutableDictionary alloc] initWithContentsOfFile:plistPath];
    } else {
        libValPrefs = [[NSMutableDictionary alloc] init];
    }
    [libValPrefs setObject:[NSNumber numberWithBool:YES] forKey:@"DisableLibraryValidation"];
    [libValPrefs writeToFile:plistPath atomically:YES];
    
    NSMutableDictionary *bootPlist = [[NSMutableDictionary alloc] initWithContentsOfFile:[volumePath stringByAppendingPathComponent:@"Library/Preferences/SystemConfiguration/com.apple.Boot.plist"]];
    NSString *kernelFlags = [bootPlist objectForKey:@"Kernel Flags"];
    
    NSString *newKernelFlags = @"";
    NSArray *flags = [kernelFlags componentsSeparatedByString:@" "];
    for (NSString *flag in flags) {
        if ([flag rangeOfString:@"amfi_allow_any_signature"].location == NSNotFound || [flag rangeOfString:@"amfi_get_out_of_my_way"].location == NSNotFound) {
            if ([newKernelFlags isEqualToString:@""]) {
                newKernelFlags = [newKernelFlags stringByAppendingString:flag];
            } else {
                newKernelFlags = [newKernelFlags stringByAppendingString:[NSString stringWithFormat:@" %@", flag]];
            }
        }
    }
    
    if ([newKernelFlags isEqualToString:@""]) {
        newKernelFlags = @"amfi_allow_any_signature=1";
    } else {
        newKernelFlags = [newKernelFlags stringByAppendingString:@" amfi_allow_any_signature=1"];
    }
    
    [bootPlist setObject:newKernelFlags forKey:@"Kernel Flags"];
    [bootPlist writeToFile:[volumePath stringByAppendingPathComponent:@"Library/Preferences/SystemConfiguration/com.apple.Boot.plist"] atomically:YES];
    
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
