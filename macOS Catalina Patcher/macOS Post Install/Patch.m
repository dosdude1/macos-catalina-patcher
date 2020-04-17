//
//  Patch.m
//  macOS Catalina Patcher
//
//  Created by Collin Mistr on 6/27/19.
//  Copyright (c) 2019 dosdude1 Apps. All rights reserved.
//

#import "Patch.h"

@implementation Patch

-(id)init {
    self = [super init];
    identifier = @"";
    version = 0;
    shouldInstall = NO;
    resourcePath = [[NSBundle mainBundle] resourcePath];
    [self loadMacModels];
    return self;
}
-(void)loadMacModels {
    macModels = [[NSDictionary alloc] initWithContentsOfFile:[resourcePath stringByAppendingPathComponent:@"macmodels.plist"]];
}
-(int)applyToVolume:(NSString *)volumePath {
    return 0;
}
-(NSString *)getID {
    return identifier;
}
-(void)setID:(NSString *)inID {
    identifier = inID;
}
-(int)getVersion {
    return version;
}
-(void)setVersion:(int)ver {
    version = ver;
}
-(NSString *)getName {
    return visibleName;
}
-(void)setName:(NSString *)name {
    visibleName = name;
}

-(int)copyFile:(NSString *)filePath toDirectory:(NSString *)dirPath {
    NSTask *copy = [[NSTask alloc] init];
    [copy setLaunchPath:@"/bin/cp"];
    [copy setArguments:@[@"-r", filePath, dirPath]];
    [copy launch];
    [copy waitUntilExit];
    return [copy terminationStatus];
}
-(int)copyFilesFromDirectory:(NSString *)dirPath toPath:(NSString *)targetPath {
    int ret = 0;
    NSArray *filesToCopy = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:dirPath error:nil];
    
    for (NSString *file in filesToCopy) {
        NSTask *copy = [[NSTask alloc] init];
        [copy setLaunchPath:@"/bin/cp"];
        [copy setArguments:@[@"-r", [dirPath stringByAppendingPathComponent:file], targetPath]];
        [copy launch];
        [copy waitUntilExit];
        ret = [copy terminationStatus];
        if (ret) {
            return ret;
        }
    }
    return ret;
}
-(BOOL)shouldBeInstalled {
    return shouldInstall;
}
-(void)setShouldBeInstalled:(BOOL)install {
    shouldInstall = install;
}
-(NSString *)getDataVolumeForMainVolume:(NSString *)mainVolume {
    return [mainVolume stringByAppendingString:@" - Data"];
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
-(NSString *)getUIActionString {
    return @"Applying";
}
-(BOOL)shouldInstallOnMachineModel:(NSString *)model {
    NSDictionary *machinePatches = [macModels objectForKey:model];
    if (machinePatches) {
        if ([[machinePatches objectForKey:identifier] boolValue]) {
            return YES;
        }
    }
    return NO;
}
-(void)setBootPlistAtPath:(NSString *)plistPath {
    NSMutableDictionary *bootPlist = [[NSMutableDictionary alloc]initWithContentsOfFile:plistPath];
    NSString *kernelFlags = [bootPlist objectForKey:@"Kernel Flags"];
    if ([kernelFlags isEqualToString:@""]) {
        kernelFlags = @"-no_compat_check";
    }
    else if ([kernelFlags rangeOfString:@"-no_compat_check"].location == NSNotFound) {
        kernelFlags = [kernelFlags stringByAppendingString:@" -no_compat_check"];
    }
    [bootPlist setObject:kernelFlags forKey:@"Kernel Flags"];
    [bootPlist writeToFile:plistPath atomically:YES];
}
-(void)setPlatformSupportPlistAtPath:(NSString *)plistPath {
    
    const NSString *kSupportedBoardIDs = @"SupportedBoardIds";
    const NSString *kSupportedModels = @"SupportedModelProperties";
    
    NSDictionary *legacyPlatformSupport = [[NSDictionary alloc] initWithContentsOfFile:[resourcePath stringByAppendingPathComponent:@"PlatformSupportLegacy.plist"]];
    NSArray *legacyBoardSupport = [legacyPlatformSupport objectForKey:kSupportedBoardIDs];
    NSArray *legacyModelSupport = [legacyPlatformSupport objectForKey:kSupportedModels];
    
    NSMutableDictionary *platformSupport = [[NSMutableDictionary alloc] initWithContentsOfFile:plistPath];
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
    
    [platformSupport writeToFile:plistPath atomically:YES];
}
@end
