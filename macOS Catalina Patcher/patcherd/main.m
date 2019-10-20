//
//  main.m
//  patcherd
//
//  Created by Collin Mistr on 6/23/19.
//  Copyright (c) 2019 dosdude1 Apps. All rights reserved.
//

#import <Foundation/Foundation.h>
#include "PatchHandler.h"

int main(int argc, const char * argv[])
{

    @autoreleasepool {
        PatchHandler *ph = [[PatchHandler alloc] init];
        [ph startIPCService];
        
    }
    return 0;
}

