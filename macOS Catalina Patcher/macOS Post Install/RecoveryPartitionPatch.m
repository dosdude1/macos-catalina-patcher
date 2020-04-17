//
//  RecoveryPartitionPatch.m
//  macOS Catalina Patcher
//
//  Created by Collin Mistr on 4/17/20.
//  Copyright (c) 2020 dosdude1 Apps. All rights reserved.
//

#import "RecoveryPartitionPatch.h"

@implementation RecoveryPartitionPatch

-(id)init {
    self = [super init];
    [self setID:@"recoveryPartitionPatch"];
    [self setVersion:0];
    [self setName:@"Recovery Partition Patch"];
    return self;
}
-(int)applyToVolume:(NSString *)volumePath {
    
    int ret = 0;
    NSString *recoveryVolumePath = @"/Volumes/Recovery";
    
    NSString *recoveryDisk = [[APFSManager sharedInstance] getRecoveryVolumeforAPFSVolumeAtPath:volumePath];
    NSString *volumeUUID = [[APFSManager sharedInstance] getUUIDOfVolumeAtPath:volumePath];
    
    NSTask *mount = [[NSTask alloc] init];
    [mount setLaunchPath:@"/usr/sbin/diskutil"];
    [mount setArguments:@[@"mount", recoveryDisk]];
    [mount launch];
    [mount waitUntilExit];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:recoveryVolumePath]) {
        recoveryVolumePath = @"/Volumes/Image Volume";
    }
    
    [self setPlatformSupportPlistAtPath:[NSString stringWithFormat:@"%@/%@/PlatformSupport.plist", recoveryVolumePath, volumeUUID]];
    [self setBootPlistAtPath:[NSString stringWithFormat:@"%@/%@/com.apple.Boot.plist", recoveryVolumePath, volumeUUID]];
    ret = [self copyFile:[resourcePath stringByAppendingPathComponent:@"prelinkedkernel"] toDirectory:[NSString stringWithFormat:@"%@/%@", recoveryVolumePath, volumeUUID]];
    if (ret) {
        return ret;
    }
    ret = [self copyFile:[resourcePath stringByAppendingPathComponent:@"patchedfiles/boot.efi"] toDirectory:[NSString stringWithFormat:@"%@/%@", recoveryVolumePath, volumeUUID]];
    
    
    NSTask *unmount = [[NSTask alloc] init];
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
