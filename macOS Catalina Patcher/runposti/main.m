//
//  main.m
//  runposti
//
//  Created by Collin Mistr on 6/30/19.
//  Copyright (c) 2019 dosdude1 Apps. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PatcherFlags.h"


int main(int argc, const char * argv[])
{
    //This binary takes the place of "shutdown".
    @autoreleasepool {
        
        [[PatcherFlags sharedInstance] loadFromDirectory:@"/"];
        if ([[PatcherFlags sharedInstance] shouldAutoApplyPostInstall]) {
            NSTask *launchPost = [[NSTask alloc] init];
            [launchPost setLaunchPath:@"/Applications/Utilities/macOS Post Install.app/Contents/MacOS/macOS Post Install"];
            [launchPost setArguments:@[@"-installer"]];
            [launchPost launch];
            [launchPost waitUntilExit];
        }
        
        NSMutableArray *shutdownArgs = [[NSMutableArray alloc] init];
        for (int i=1; i<argc; i++) {
            [shutdownArgs addObject:[NSString stringWithUTF8String:argv[i]]];
        }
        NSTask *shutdown = [[NSTask alloc] init];
        [shutdown setLaunchPath:@"/sbin/shutdown"];
        [shutdown setArguments:shutdownArgs];
        [shutdown launch];
    }
    return 0;
}

