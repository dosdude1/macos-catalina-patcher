//
//  PatchHandler.h
//  macOS Catalina Patcher
//
//  Created by Collin Mistr on 6/23/19.
//  Copyright (c) 2019 dosdude1 Apps. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "InstallerPatcher.h"
#import "LoggingManager.h"
#import "ISOManager.h"
#import "InPlaceInstallerManager.h"
#import "PatcherFlags.h"

#define SERVER_ID "com.dosdude1.catalinapatcher"


@protocol PatchHandlerDelegate <NSObject>

-(void)updateProgressWithValue:(double)percent;
-(void)updateProgressStatus:(NSString *)status;
-(void)operationDidComplete;
-(void)operationDidFailWithError:(err)error;
-(void)setProgBarMaxValue:(double)maxValue;
-(void)displayHelperError:(NSString *)message withInfo:(NSString *)info;
-(void)logDidUpdateWithText:(NSString *)text;

@end

@interface PatchHandler : NSObject <LoggingDelegate>
{
    NSConnection *connection;
    BOOL shouldKeepRunning;
    NSTimer *progTimer;
    double progressValue;
    double NUM_PROCS;
    PatcherFlags *patcherFlags;
}
@property (strong) id <PatchHandlerDelegate> delegate;
-(id)init;
-(void)startIPCService;
-(int)createPatchedInstallerOnVolume:(NSString *)volumePath usingResources:(NSString *)resourcePath fromInstallerApp:(NSString *)installerAppPath;
-(int)createISOImageAtPath:(NSString *)isoPath usingResources:(NSString *)resourcePath fromInstallerApp:(NSString *)installerAppPath;
-(int)createPatchedInstallerAppAtPath:(NSString *)targetAppPath usingResources:(NSString *)resourcePath fromBaseApp:(NSString *)baseAppPath;
-(void)setPatcherFlagsObject:(PatcherFlags *)flags;
-(oneway void)terminateHelper;


@end
