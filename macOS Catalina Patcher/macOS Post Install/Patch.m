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
@end
