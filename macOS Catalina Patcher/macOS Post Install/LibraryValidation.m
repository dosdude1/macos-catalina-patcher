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
    [self setVersion:1];
    [self setName:@"Library Validation Disabler Patch"];
    return self;
}
-(int)applyToVolume:(NSString *)volumePath {
    NSString *plistPath = [volumePath stringByAppendingPathComponent:@"Library/Preferences/com.apple.security.libraryvalidation.plist"];
    NSMutableDictionary *libValPrefs;
    if ([[NSFileManager defaultManager] fileExistsAtPath:plistPath]) {
        libValPrefs = [[NSMutableDictionary alloc] initWithContentsOfFile:plistPath];
    } else {
        libValPrefs = [[NSMutableDictionary alloc] init];
    }
    [libValPrefs setObject:[NSNumber numberWithBool:YES] forKey:@"DisableLibraryValidation"];
    [libValPrefs writeToFile:plistPath atomically:YES];
    
    return 0;
}
-(BOOL)shouldInstallOnMachineModel:(NSString *)model {
    NSDictionary *machinePatches = [macModels objectForKey:model];
    if (machinePatches) {
        return YES;
    }
    return NO;
}
@end
