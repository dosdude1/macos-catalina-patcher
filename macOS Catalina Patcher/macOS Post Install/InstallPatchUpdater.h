//
//  InstallPatchUpdater.h
//  macOS Catalina Patcher
//
//  Created by Collin Mistr on 7/10/19.
//  Copyright (c) 2019 dosdude1 Apps. All rights reserved.
//

#import "Patch.h"

@interface InstallPatchUpdater : Patch

-(id)init;
-(int)applyToVolume:(NSString *)volumePath;
-(NSString *)getUIActionString;

@end
