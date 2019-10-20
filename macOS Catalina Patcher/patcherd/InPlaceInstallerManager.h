//
//  InPlaceInstallerManager.h
//  macOS Catalina Patcher
//
//  Created by Collin Mistr on 7/23/19.
//  Copyright (c) 2019 dosdude1 Apps. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PatchManager.h"

@interface InPlaceInstallerManager : PatchManager

-(id)init;
-(int)launchInstallerAppAtPath:(NSString *)appPath;
-(int)loadDisableLibValKext:(NSString *)kextPath;
-(BOOL)systemNeedsDisableLibVal;
-(int)prepareRootFSForInstallationUsingResources:(NSString *)resourcePath;
-(BOOL)isSIPEnabled;

@end
