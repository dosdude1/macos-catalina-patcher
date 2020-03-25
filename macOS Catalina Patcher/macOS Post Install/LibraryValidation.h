//
//  LibraryValidation.h
//  macOS Catalina Patcher
//
//  Created by Collin Mistr on 3/24/20.
//  Copyright (c) 2020 dosdude1 Apps. All rights reserved.
//

#import "Patch.h"

@interface LibraryValidation : Patch

-(id)init;
-(int)applyToVolume:(NSString *)volumePath;
-(BOOL)shouldInstallOnMachineModel:(NSString *)model;

@end
