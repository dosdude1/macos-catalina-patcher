//
//  PlatformCheck.h
//  macOS Catalina Patcher
//
//  Created by Collin Mistr on 6/29/19.
//  Copyright (c) 2019 dosdude1 Apps. All rights reserved.
//

#import "Patch.h"
#import "APFSManager.h"

@interface PlatformCheck : Patch

-(id)init;
-(int)applyToVolume:(NSString *)volumePath;

@end
