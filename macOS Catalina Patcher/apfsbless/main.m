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
    //This binary takes the place of "bless".
    @autoreleasepool {
        
        SystemPrep *p = [[SystemPrep alloc] init];
        
        if ([p systemNeedsAPFSBooter]) {
            
            NSMutableArray *blessArgs = [[NSMutableArray alloc] init];
            for (int i=1; i<argc; i++) {
                [blessArgs addObject:[NSString stringWithUTF8String:argv[i]]];
            }
            NSTask *bless = [[NSTask alloc] init];
            [bless setLaunchPath:@"/usr/sbin/bless"];
            [bless setArguments:blessArgs];
            [bless launch];
            [bless waitUntilExit];
            
            [p blessESPForBooter];
            
        } else {
            NSMutableArray *blessArgs = [[NSMutableArray alloc] init];
            for (int i=1; i<argc; i++) {
                [blessArgs addObject:[NSString stringWithUTF8String:argv[i]]];
            }
            NSTask *bless = [[NSTask alloc] init];
            [bless setLaunchPath:@"/usr/sbin/bless"];
            [bless setArguments:blessArgs];
            [bless launch];
            [bless waitUntilExit];
            return [bless terminationStatus];
        }
    }
    return 0;
}

