//
//  Patch.h
//  macOS Catalina Patcher
//
//  Created by Collin Mistr on 6/27/19.
//  Copyright (c) 2019 dosdude1 Apps. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PatcherFlags.h"


@interface Patch : NSObject
{
    NSString *identifier;
    NSString *visibleName;
    int version;
    NSString *resourcePath;
    BOOL shouldInstall;
    NSDictionary *macModels;
}
-(id)init;
-(NSString *)getID;
-(void)setID:(NSString *)inID;
-(NSString *)getName;
-(void)setName:(NSString *)name;
-(int)getVersion;
-(void)setVersion:(int)ver;
-(int)applyToVolume:(NSString *)volumePath;
-(BOOL)shouldBeInstalled;
-(void)setShouldBeInstalled:(BOOL)install;

-(int)copyFile:(NSString *)filePath toDirectory:(NSString *)dirPath;
-(int)copyFilesFromDirectory:(NSString *)dirPath toPath:(NSString *)targetPath;
-(NSString *)getDataVolumeForMainVolume:(NSString *)mainVolume;
-(void)setPermissionsOnDirectory:(NSString *)path;
-(NSString *)getUIActionString;
-(BOOL)shouldInstallOnMachineModel:(NSString *)model;

@end
