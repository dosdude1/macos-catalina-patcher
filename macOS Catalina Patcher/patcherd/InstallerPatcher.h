//
//  InstallerPatcher.h
//  macOS Catalina Patcher
//
//  Created by Collin Mistr on 6/15/19.
//  Copyright (c) 2019 dosdude1 Apps. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PatchManager.h"


@interface InstallerPatcher : PatchManager

-(id)init;
-(int)shadowMountDMGAtPath:(NSString *)path toMountpoint:(NSString *)mntpt;
-(int)copyPatchedBaseSystemFilesFromDirectory:(NSString *)dir toBSMount:(NSString *)mnt;
-(int)setBaseSystemPermissionsOnVolume:(NSString *)path;
-(int)copyPatchedInstallESDFilesFromDirectory:(NSString *)dir toESDMount:(NSString *)mnt;
-(int)saveModifiedShadowDMG:(NSString *)dmgPath mountedAt:(NSString *)mountPt toPath:(NSString *)path;
-(int)restoreBaseSystemDMG:(NSString *)dmgPath toVolume:(NSString *)volumePath;
-(int)copySharedSupportDirectoryFilesFrom:(NSString *)ssPath toPath:(NSString *)path;
-(NSString *)locateInstallerAppAtPath:(NSString *)path;
-(int)preventVolumeFromDisplayingWindowOnMount:(NSString *)volumePath;
-(int)addPostInstallEntryToUtilitiesOnVolume:(NSString *)volumePath;
-(int)setBootPlistOnVolume:(NSString *)volumePath;


@end
