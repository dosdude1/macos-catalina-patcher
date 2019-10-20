//
//  AnalyticsManager.h
//  macOS Catalina Patcher
//
//  Created by Collin Mistr on 7/30/19.
//  Copyright (c) 2019 dosdude1 Apps. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <sys/sysctl.h>
#include <CommonCrypto/CommonDigest.h>

#import "CatalinaPatcherLoggingManager.h"

#define AnalyticsURL ""
#define AnalyticsKey ""

@interface AnalyticsManager : NSObject

-(id)init;
+ (AnalyticsManager *)sharedInstance;
-(void)postAnalyticsOfPatcherMode:(int)mode usingInstallerAppVersion:(NSString *)version withError:(int)err;

@end
