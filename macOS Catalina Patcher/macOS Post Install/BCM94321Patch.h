//
//  BCM94321Patch.h
//  macOS Catalina Patcher
//
//  Created by Collin Mistr on 6/28/19.
//  Copyright (c) 2019 dosdude1 Apps. All rights reserved.
//

#import "Patch.h"
#include <sys/sysctl.h>

@interface BCM94321Patch : Patch

-(id)init;
-(int)applyToVolume:(NSString *)volumePath;


@end
