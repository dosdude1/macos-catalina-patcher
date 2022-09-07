//
//  LibraryValidation.m
//  macOS Catalina Patcher
//
//  Created by Collin Mistr on 3/24/20.
//  Copyright (c) 2020 dosdude1 Apps. All rights reserved.
//

#import "LibraryValidation.h"

@implementation LibraryValidation

-(id)init {
    self = [super init];
    [self setID:@"LibraryValidation"];
    [self setVersion:4];
    [self setName:@"Library Validation Disabler Patch"];
    return self;
}
-(int)applyToVolume:(NSString *)volumePath {
    
    int ret = 0;
    ret = [self copyFile:[resourcePath stringByAppendingPathComponent:@"addonkexts/DisableLibraryValidation.kext"] toDirectory:[volumePath stringByAppendingPathComponent:@"Library/Extensions"]];
    return ret;
}
-(BOOL)shouldInstallOnMachineModel:(NSString *)model {
    NSDictionary *machinePatches = [macModels objectForKey:model];
    if (machinePatches) {
        return YES;
    }
    return NO;
}
@end
