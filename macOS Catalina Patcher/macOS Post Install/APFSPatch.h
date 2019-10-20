//
//  APFSPatch.h
//  macOS Catalina Patcher
//
//  Created by Collin Mistr on 7/12/19.
//  Copyright (c) 2019 dosdude1 Apps. All rights reserved.
//

#import "Patch.h"
#import "APFSManager.h"
#define BootFileLocation "System\\Library\\CoreServices\\boot.efi"

@interface APFSPatch : Patch

-(id)init;
-(int)applyToVolume:(NSString *)volumePath;

@end
