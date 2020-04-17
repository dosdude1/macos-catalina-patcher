//
//  RecoveryPartitionPatch.h
//  macOS Catalina Patcher
//
//  Created by Collin Mistr on 4/17/20.
//  Copyright (c) 2020 dosdude1 Apps. All rights reserved.
//

#import "Patch.h"
#import "APFSManager.h"

@interface RecoveryPartitionPatch : Patch

-(id)init;
-(int)applyToVolume:(NSString *)volumePath;

@end
