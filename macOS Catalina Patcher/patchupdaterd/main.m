//
//  main.m
//  patchupdaterd
//
//  Created by Collin Mistr on 7/5/19.
//  Copyright (c) 2019 dosdude1 Apps. All rights reserved.
//

#import <Foundation/Foundation.h>

int main(int argc, const char * argv[])
{

    @autoreleasepool {
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSTask *launchPU = [[NSTask alloc] init];
            [launchPU setLaunchPath:@"/System/Applications/Utilities/Patch Updater.app/Contents/MacOS/Patch Updater"];
            [launchPU setArguments:@[@"-silent"]];
            [launchPU launch];
            [launchPU waitUntilExit];
            while (YES)
            {
                sleep(7200);
                NSTask *launchPU = [[NSTask alloc] init];
                [launchPU setLaunchPath:@"/System/Applications/Utilities/Patch Updater.app/Contents/MacOS/Patch Updater"];
                [launchPU setArguments:@[@"-silent"]];
                [launchPU launch];
                [launchPU waitUntilExit];
            }
        });
        
        while (YES)
        {
            sleep(1);
        }
        
    }
    return 0;
}

