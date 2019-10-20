//
//  LegacyIDE.h
//  macOS Catalina Patcher
//
//  Created by Collin Mistr on 7/5/19.
//  Copyright (c) 2019 dosdude1 Apps. All rights reserved.
//

#import "Patch.h"

@interface LegacyIDE : Patch

-(id)init;
-(int)applyToVolume:(NSString *)volumePath;

@end
