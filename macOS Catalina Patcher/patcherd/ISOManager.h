//
//  ISOManager.h
//  macOS Catalina Patcher
//
//  Created by Collin Mistr on 7/22/19.
//  Copyright (c) 2019 dosdude1 Apps. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PatchManager.h"


@interface ISOManager : PatchManager

-(id)init;
-(int)createISOImageAtPath:(NSString *)path withVolumeName:(NSString *)name usingContentsOfDirectory:(NSString *)dirPath;
-(int)copyBaseSystemInstallerFilesFromDirectory:(NSString *)dir toDirectory:(NSString *)targetDir;
-(int)setupBootPlistForBSBootOnVolume:(NSString *)path;
-(int)writeIAPhysicalMediaFlagWithAppName:(NSString *)name toVolume:(NSString *)path;

@end
