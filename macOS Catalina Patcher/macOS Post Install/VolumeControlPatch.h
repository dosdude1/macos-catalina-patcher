//
//  VolumeControlPatch.h
//  macOS Catalina Patcher
//
//  Created by Collin Mistr on 10/15/19.
//  Copyright (c) 2019 dosdude1 Apps. All rights reserved.
//

#import "Patch.h"

@interface VolumeControlPatch : Patch

-(id)init;
-(int)applyToVolume:(NSString *)volumePath;

@end
