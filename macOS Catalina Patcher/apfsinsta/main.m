//
//  main.m
//  apfsprep
//
//  Created by Collin Mistr on 6/26/19.
//  Copyright (c) 2019 dosdude1 Apps. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SystemPrep.h"


int main(int argc, const char * argv[])
{
    //This binary takes the place of "nvram".
    @autoreleasepool {
        
        SystemPrep *p = [[SystemPrep alloc] init];
        if (![p hasRunThisBoot]) {
            [p setNoCompatCheckNVRAM];
            
            NSString *targetVolumePath = [@"/Volumes" stringByAppendingPathComponent:[p locateTargetVolume]];
            
            [p setNoCompatCheckInstallerBootPlistOnVolumePath:targetVolumePath];
            if ([p systemNeedsAPFSBooter]) {
                
                [p installAPFSBooterForInstallerVolumeAtPath:targetVolumePath];
            }
            [p setToolHasRunThisBoot:YES];
        }
        
        
        NSMutableArray *nvramArgs = [[NSMutableArray alloc] init];
        for (int i=1; i<argc; i++) {
            [nvramArgs addObject:[NSString stringWithUTF8String:argv[i]]];
        }
        NSTask *nvram = [[NSTask alloc] init];
        [nvram setLaunchPath:@"/usr/sbin/nvram"];
        [nvram setArguments:nvramArgs];
        [nvram launch];
        [nvram waitUntilExit];
        return [nvram terminationStatus];
    }
    return 0;
}

