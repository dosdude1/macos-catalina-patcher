//
//  SystemPrep.h
//  macOS Catalina Patcher
//
//  Created by Collin Mistr on 7/8/19.
//  Copyright (c) 2019 dosdude1 Apps. All rights reserved.
//


#import <Foundation/Foundation.h>
#include <sys/sysctl.h>
#import "PatcherFlags.h"
#import "APFSManager.h"

#define kModelNeedsAPFSPatch "needsAPFSPatch"
#define InstallerPrebootBootFileLocation "com.apple.installer\\boot.efi"
#define InstallerPrebootBootPlistFileLocation "com.apple.installer/com.apple.Boot.plist"
#define InstallerBootPlistFileLocation "macOS Install Data/Locked Files/Boot Files/com.apple.Boot.plist"


#define PrepFlagsFile "installPrepFlags.plist"
#define kToolHasRun "hasRun"

@interface SystemPrep : NSObject
{
    NSString *resourcePath;
}


-(id)init;
-(NSString *)locateTargetVolume;
-(BOOL)systemNeedsAPFSBooter;
-(void)setNoCompatCheckNVRAM;
-(void)setNoCompatCheckInstallerBootPlistOnVolumePath:(NSString *)volumePath;
-(void)installAPFSBooterForInstallerVolumeAtPath:(NSString *)volumePath;
-(BOOL)hasRunThisBoot;
-(void)setToolHasRunThisBoot:(BOOL)hasRun;
-(void)blessESPForBooter;

@end
