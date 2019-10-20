//
//  main.m
//  apfshelperd
//
//  Created by Collin Mistr on 8/8/19.
//  Copyright (c) 2019 dosdude1 Apps. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "APFSPrefpaneHelper.h"

int main(int argc, const char * argv[])
{

    @autoreleasepool {
        
        APFSPrefpaneHelper *h = [[APFSPrefpaneHelper alloc] init];
        [h startIPCService];
        
    }
    return 0;
}

