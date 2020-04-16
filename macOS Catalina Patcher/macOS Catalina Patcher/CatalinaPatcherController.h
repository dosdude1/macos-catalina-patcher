//
//  CatalinaPatcherController.h
//  macOS Catalina Patcher
//
//  Created by Collin Mistr on 6/18/19.
//  Copyright (c) 2019 dosdude1 Apps. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PatchHandler.h"
#import "STPrivilegedTask.h"
#import "CatalinaPatcherLoggingManager.h"
#import "AnalyticsManager.h"
#import "APFSManager.h"

#define systemCompatibilityFile "macModels.plist"
#define kSystemNeedsAPFSROMUpdate "needsAPFSBootROMUpdate"

typedef enum {
    modeCreateInstallerVolume = 0,
    modeInstallToSameMachine = 1,
    modeCreateISO = 2
}mode;

typedef enum {
    compatibilityStateIsSupportedMachine = 0,
    compatibilityStateNeedsAPFSROMUpdate = 1,
    compatibilityStateIsUnsupportedMachine = 2,
    compatibilityStateIsNativelySupportedMachine = 3
}compatibilityState;

@protocol CatalinaPatcherControllerDelegate <NSObject>

-(void)updateProgressWithValue:(double)percent;
-(void)updateProgressStatus:(NSString *)status;
-(void)operationDidComplete;
-(void)operationDidFailWithError:(err)error;
-(void)setProgBarMaxValue:(double)maxValue;
-(void)helperFailedLaunchWithError:(OSStatus)err;
-(void)displayHelperError:(NSString *)message withInfo:(NSString *)info;

@end


@interface CatalinaPatcherController : NSObject <PatchHandlerDelegate>
{
    NSString *installerAppPath;
    NSString *installerVolumePath;
    PatchHandler *ph;
    BOOL shouldUseAPFSBooter;
    BOOL shouldAutoApplyPostInstall;
    NSString *isoPath;
    NSString *targetPatchedAppPath;
    NSString *installerAppVersion;
}
@property (strong) id <CatalinaPatcherControllerDelegate> delegate;
-(id)init;
+ (CatalinaPatcherController *)sharedInstance;
-(BOOL)setInstallerAppPath:(NSString *)appPath withVerification:(BOOL)verify;
-(void)setTargetVolume:(NSString *)volume;
-(int)startProcessInMode:(mode)desiredMode;
-(void)setISOPath:(NSString *)path;
-(void)setTargetPatchedAppPath:(NSString *)appPath;
-(compatibilityState)checkSystemCompatibility;

@end
