//
//  PostInstallHandler.h
//  macOS Catalina Patcher
//
//  Created by Collin Mistr on 6/27/19.
//  Copyright (c) 2019 dosdude1 Apps. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Patch.h"
#import "PlatformCheck.h"
#import "LegacyGPU.h"
#import "LegacyUSB.h"
#import "LegacyPlatform.h"
#import "SIPDisabler.h"
#import "LegacyWiFi.h"
#import "BCM94321Patch.h"
#import "LegacyEnet.h"
#import "LegacyAudio.h"
#import "LegacyIDE.h"
#import "InstallPatchUpdater.h"
#import "APFSPatch.h"
#import "VolumeControlPatch.h"
#import "AMDSSE4.h"
#import "LibraryValidation.h"

@interface PostInstallHandler : NSObject
{
    NSArray *availablePatches;
    NSDictionary *availablePatchesDict;
    NSDictionary *macModels;
    NSString *resourcePath;
}

+ (PostInstallHandler *)sharedInstance;
-(id)init;
-(NSArray *)getAllPatches;
-(void)setPermissionsOnDirectory:(NSString *)path;
-(NSArray *)getOptimalPatchesForModel:(NSString *)macModel;
-(NSString *)getMachineModel;
-(BOOL)volumeContainsCatalina:(NSString *)volumePath;
-(NSArray *)getAvailableVolumes;
-(NSArray *)getAllModels;
-(NSString *)getCatalinaVolume;
-(void)rebootSystemWithCacheRebuild:(BOOL)rebuildCaches onVolume:(NSString *)volumePath;
-(void)beginForceCacheRebuildOnVolume:(NSString *)volumePath;
-(void)updateDyldSharedCacheOnVolume:(NSString *)volumePath;

@end
