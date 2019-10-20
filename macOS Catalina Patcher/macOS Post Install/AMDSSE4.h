//
//  AMDSSE4.h
//  macOS Catalina Patcher
//
//  Created by Collin Mistr on 10/19/19.
//  Copyright (c) 2019 dosdude1 Apps. All rights reserved.
//

#import "Patch.h"

@interface AMDSSE4 : Patch

-(id)init;
-(int)applyToVolume:(NSString *)volumePath;

@end
