//
//  LoggingManager.h
//  macOS Catalina Patcher
//
//  Created by Collin Mistr on 7/22/19.
//  Copyright (c) 2019 dosdude1 Apps. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    errMountingBSImage = 1,
    errMountingESDImage = 2,
    errCopyingSharedSupport = 3,
    errSavingBSImage = 4,
    errSavingESDImage = 5,
    errRestoringBSImage = 6,
    errBaseSystemPerms = 7,
    errPatchingBaseSystem = 8,
    errPatchingInstallESD = 9,
    isoErrCreatingBaseImage = 10,
    errCopyingBooterFiles = 11,
    errLaunchingInstaller = 12,
    errLoadingLibValKext = 13,
    errSettingLibValKextPerms = 14,
    errSIPEnabled = 15,
    errPreparingFSForInPlaceInstall = 16
}err;

@protocol LoggingDelegate <NSObject>

-(void)logDidUpdateWithText:(NSString *)text;

@end

@interface LoggingManager : NSObject


@property (strong) id <LoggingDelegate> delegate;
- (id)init;
+ (LoggingManager *)sharedInstance;
-(void)setOutputPipe:(NSPipe *)pipe;

@end
