//
//  PostInstallHandler.m
//  macOS Catalina Patcher
//
//  Created by Collin Mistr on 6/27/19.
//  Copyright (c) 2019 dosdude1 Apps. All rights reserved.
//

#import "PostInstallHandler.h"

@implementation PostInstallHandler

-(id)init {
    self = [super init];
    resourcePath = [[NSBundle mainBundle] resourcePath];
    [self loadAllPatches];
    [self loadMacModels];
    return self;
}
+ (PostInstallHandler *)sharedInstance {
    static PostInstallHandler *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}
-(void)loadAllPatches {
    
    NSMutableArray *patches = [[NSMutableArray alloc] init];
    [patches addObject:[[PlatformCheck alloc] init]];
    [patches addObject:[[InstallPatchUpdater alloc] init]];
    [patches addObject:[[LegacyGPU alloc] init]];
    [patches addObject:[[LegacyUSB alloc] init]];
    [patches addObject:[[LegacyPlatform alloc] init]];
    [patches addObject:[[APFSPatch alloc] init]];
    [patches addObject:[[SIPDisabler alloc] init]];
    [patches addObject:[[LegacyWiFi alloc] init]];
    [patches addObject:[[BCM94321Patch alloc] init]];
    [patches addObject:[[LegacyEnet alloc] init]];
    [patches addObject:[[LegacyAudio alloc] init]];
    [patches addObject:[[LegacyIDE alloc] init]];
    [patches addObject:[[VolumeControlPatch alloc] init]];
    [patches addObject:[[AMDSSE4 alloc] init]];
    [patches addObject:[[LibraryValidation alloc] init]];
    availablePatches = patches;
    
    NSMutableDictionary *d = [[NSMutableDictionary alloc] init];
    for (Patch *p in availablePatches) {
        [d setObject:p forKey:[p getID]];
    }
    availablePatchesDict = d;
}
-(void)loadMacModels {
    macModels = [[NSDictionary alloc] initWithContentsOfFile:[resourcePath stringByAppendingPathComponent:@"macmodels.plist"]];
}
-(NSArray *)getAllPatches {
    return availablePatches;
}
-(void)setPermissionsOnDirectory:(NSString *)path {
    NSTask *chmod = [[NSTask alloc] init];
    [chmod setLaunchPath:@"/bin/chmod"];
    [chmod setArguments:@[@"-R", @"755", path]];
    [chmod launch];
    [chmod waitUntilExit];
    
    NSTask *chown = [[NSTask alloc] init];
    [chown setLaunchPath:@"/usr/sbin/chown"];
    [chown setArguments:@[@"-R", @"0:0", path]];
    [chown launch];
    [chown waitUntilExit];
}
-(NSArray *)getOptimalPatchesForModel:(NSString *)macModel {
    NSMutableArray *optimalPatches = [[NSMutableArray alloc] init];
    
    for (Patch *p in availablePatches) {
        if ([p shouldInstallOnMachineModel:macModel]) {
            [optimalPatches addObject:p];
        }
    }
    
    return optimalPatches;
}
-(NSString *)getMachineModel {
    NSString *macModel=@"";
    size_t len=0;
    sysctlbyname("hw.model", nil, &len, nil, 0);
    if (len)
    {
        char *model = malloc(len*sizeof(char));
        sysctlbyname("hw.model", model, &len, nil, 0);
        macModel=[NSString stringWithFormat:@"%s", model];
        free(model);
    }
    return macModel;
}
-(NSString *)getCatalinaVolume {
    NSString *catVolume = [[self getAvailableVolumes] objectAtIndex:0];
    NSDate *latestDate = [NSDate dateWithTimeIntervalSince1970:0];
    for (NSString *volume in [self getAvailableVolumes]) {
        if ([self volumeContainsCatalina:[@"/Volumes" stringByAppendingPathComponent:volume]]) {
            NSDictionary *attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:[NSString stringWithFormat:@"/Volumes/%@", volume] error:nil];
            
            NSDate *date = [attributes fileModificationDate];
            if ([date compare:latestDate] == NSOrderedDescending) {
                latestDate = date;
                catVolume = volume;
            }
        }
    }
    return catVolume;
}
-(BOOL)volumeContainsCatalina:(NSString *)volumePath {
    if ([[NSFileManager defaultManager]fileExistsAtPath:[volumePath stringByAppendingString:@"/System/Library/CoreServices/SystemVersion.plist"]] && ![[NSFileManager defaultManager]fileExistsAtPath:[volumePath stringByAppendingString:@"/System/Installation"]] && [[NSFileManager defaultManager]fileExistsAtPath:[volumePath stringByAppendingString:@"/Applications"]])
    {
        NSDictionary *dict = [[NSDictionary alloc]initWithContentsOfFile:[volumePath stringByAppendingString:@"/System/Library/CoreServices/SystemVersion.plist"]];
        if ([[dict objectForKey:@"ProductVersion"]rangeOfString:@"10.15"].location != NSNotFound)
        {
            return YES;
        }
    }
    return NO;
}
-(NSArray *)getAvailableVolumes {
    NSMutableArray *availableVolumes = [[NSMutableArray alloc] initWithArray:[[NSFileManager defaultManager] contentsOfDirectoryAtPath:@"/Volumes" error:nil]];
    if ([[availableVolumes objectAtIndex:0] isEqualToString:@".DS_Store"])
    {
        [availableVolumes removeObjectAtIndex:0];
    }
    if ([[availableVolumes objectAtIndex:0] isEqualToString:@".Trashes"])
    {
        [availableVolumes removeObjectAtIndex:0];
    }
    return availableVolumes;
}
-(NSArray *)getAllModels {
    return [[macModels allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
}
-(void)rebootSystemWithCacheRebuild:(BOOL)rebuildCaches onVolume:(NSString *)volumePath {
    if (rebuildCaches) {
        [self beginForceCacheRebuildOnVolume:volumePath];
    }
    NSTask *task = [[NSTask alloc] init];
    [task setLaunchPath:@"/sbin/reboot"];
    [task launch];
}
-(void)beginForceCacheRebuildOnVolume:(NSString *)volumePath {
    
    NSTask *invalidate = [[NSTask alloc] init];
    [invalidate setLaunchPath:@"/usr/sbin/kextcache"];
    [invalidate setArguments:@[@"-i", volumePath]];
    [invalidate launch];
    [invalidate waitUntilExit];
}
-(void)updateDyldSharedCacheOnVolume:(NSString *)volumePath {
    
    NSTask *updateDyld = [[NSTask alloc] init];
    [updateDyld setLaunchPath:@"/usr/bin/update_dyld_shared_cache"];
    [updateDyld setArguments:@[@"-root", volumePath]];
    [updateDyld launch];
    [updateDyld waitUntilExit];
}
@end
