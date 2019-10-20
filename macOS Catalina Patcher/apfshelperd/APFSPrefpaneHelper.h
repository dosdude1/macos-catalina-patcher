//
//  APFSPrefpaneHelper.h
//  macOS Catalina Patcher
//
//  Created by Collin Mistr on 8/8/19.
//  Copyright (c) 2019 dosdude1 Apps. All rights reserved.
//

#import <Foundation/Foundation.h>

#define SERVER_ID "com.dosdude1.apfshelperd"
#define BootFileLocation "System\\Library\\CoreServices\\boot.efi"

typedef enum {
    errSomething = 1
}err;

@protocol APFSPrefHelperDelegate <NSObject>

-(void)didSetStartupVolumeWithError:(err)errID;
-(void)didLoadVolumes:(NSArray *)volumes withCurrentBootVolume:(NSString *)currentVol withError:(err)errID;

@end

@interface APFSPrefpaneHelper : NSObject
{
    NSConnection *connection;
    BOOL shouldKeepRunning;
    NSString *resourcePath;
    NSString *currentUUID;
}

@property (strong) id <APFSPrefHelperDelegate> delegate;
-(id)init;
-(void)startIPCService;
-(void)setResourcesPath:(NSString *)path;

-(void)beginLoadingAvailableVolumesForRoot;
-(void)beginSettingBootVolume:(NSString *)volumeName;

@end
