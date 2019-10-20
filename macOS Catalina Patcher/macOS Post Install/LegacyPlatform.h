//
//  LegacyPlatform.h
//  macOS Catalina Patcher
//
//  Created by Collin Mistr on 6/28/19.
//  Copyright (c) 2019 dosdude1 Apps. All rights reserved.
//

#import "Patch.h"

@interface LegacyPlatform : Patch

-(id)init;
-(int)applyToVolume:(NSString *)volumePath;

@end
