//
//  APFSManager.h
//  macOS Catalina Patcher
//
//  Created by Collin Mistr on 10/8/19.
//  Copyright (c) 2019 dosdude1 Apps. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface APFSManager : NSObject

-(id)init;
+ (APFSManager *)sharedInstance;
-(NSString *)getAPFSPhysicalStoreForVolumeAtPath:(NSString *)volumePath;
-(NSString *)getUUIDOfVolumeAtPath:(NSString *)volumePath;
-(NSString *)getPrebootVolumeforAPFSVolumeAtPath:(NSString *)volumePath;

@end
