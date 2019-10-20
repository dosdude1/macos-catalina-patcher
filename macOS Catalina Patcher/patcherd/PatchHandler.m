//
//  PatchHandler.m
//  macOS Catalina Patcher
//
//  Created by Collin Mistr on 6/23/19.
//  Copyright (c) 2019 dosdude1 Apps. All rights reserved.
//

#import "PatchHandler.h"

@implementation PatchHandler

-(id)init {
    self = [super init];
    shouldKeepRunning = YES;
    progressValue = 0.0;
    [LoggingManager sharedInstance].delegate = self;
    return self;
}

-(void)startIPCService {
    connection = [[NSConnection alloc] init];
    [connection setRootObject:self];
    [connection registerName:@SERVER_ID];
    NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
    while (shouldKeepRunning && [runLoop runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]]);
}

-(oneway void)terminateHelper {
    NSLog(@"Helper Terminating");
    shouldKeepRunning = NO;
}


-(int)createPatchedInstallerOnVolume:(NSString *)volumePath usingResources:(NSString *)resourcePath fromInstallerApp:(NSString *)installerAppPath {
    progressValue = 0.0;
    NUM_PROCS = 2.0;
    err errID = 0;
    const int MAX_PROGBAR_VALUE = 120.0;
    
    NSString *bsMount = @"/private/tmp/basesystem";
    NSString *installESDMount = @"/private/tmp/installesd";
    NSString *tmpBSDMGPath = @"/private/tmp/BaseSystem.dmg";
    
    [self.delegate setProgBarMaxValue:MAX_PROGBAR_VALUE];
    [self updateProgressWithValue:progressValue+2.0];
    [self.delegate updateProgressStatus:@"Mounting BaseSystem.dmg..."];
    
    NSFileManager *man = [NSFileManager defaultManager];
    if ([man fileExistsAtPath:bsMount]) {
        [man removeItemAtPath:bsMount error:nil];
    }
    if ([man fileExistsAtPath:installESDMount]) {
        [man removeItemAtPath:installESDMount error:nil];
    }
    if ([man fileExistsAtPath:tmpBSDMGPath]) {
        [man removeItemAtPath:tmpBSDMGPath error:nil];
    }
    
    InstallerPatcher *ip = [[InstallerPatcher alloc] init];
    errID = [ip shadowMountDMGAtPath:[installerAppPath stringByAppendingPathComponent:@"Contents/SharedSupport/BaseSystem.dmg"] toMountpoint:bsMount];
    if (errID) {
        [self handleError:errMountingBSImage];
        return errMountingBSImage;
    }
    
    [self.delegate updateProgressStatus:@"Patching BaseSystem.dmg..."];
    [self updateProgressWithValue:progressValue+2.0];
    errID = [ip copyPatchedBaseSystemFilesFromDirectory:resourcePath toBSMount:bsMount];
    if (errID) {
        [self handleError:errPatchingBaseSystem];
        return errPatchingBaseSystem;
    }
    errID = [ip setBaseSystemPermissionsOnVolume:bsMount];
    if (errID) {
        [self handleError:errBaseSystemPerms];
        return errBaseSystemPerms;
    }
    [ip preventVolumeFromDisplayingWindowOnMount:bsMount];
    [ip addPostInstallEntryToUtilitiesOnVolume:bsMount];
    [ip setBootPlistOnVolume:bsMount];
    
    [patcherFlags saveToDirectory:bsMount];
    
    [self startProgressUpdateTimerWithFile:[installerAppPath stringByAppendingPathComponent:@"Contents/SharedSupport/BaseSystem.dmg"] beingCopiedToVolume:@"/"];
    errID = [ip saveModifiedShadowDMG:[installerAppPath stringByAppendingPathComponent:@"Contents/SharedSupport/BaseSystem.dmg"] mountedAt:bsMount toPath:tmpBSDMGPath];
    [[NSFileManager defaultManager] removeItemAtPath:[installerAppPath stringByAppendingPathComponent:@"Contents/SharedSupport/BaseSystem.dmg.shadow"] error:nil];
    [progTimer invalidate];
    if (errID) {
        [self handleError:errSavingBSImage];
        return errSavingBSImage;
    }
    
    [self.delegate updateProgressStatus:@"Restoring BaseSystem.dmg..."];
    [self updateProgressWithValue:progressValue+2.0];
    errID = [ip restoreBaseSystemDMG:tmpBSDMGPath toVolume:volumePath];
    if (errID) {
        [self handleError:errRestoringBSImage];
        return errRestoringBSImage;
    }
    NSString *installerAppName = [ip locateInstallerAppAtPath:volumePath];
    
    [self.delegate updateProgressStatus:@"Copying SharedSupport to Volume..."];
    [self updateProgressWithValue:progressValue+3.0];
    errID = [ip copySharedSupportDirectoryFilesFrom:[installerAppPath stringByAppendingPathComponent:@"Contents/SharedSupport"] toPath:[volumePath stringByAppendingPathComponent:[installerAppName stringByAppendingPathComponent:@"Contents/SharedSupport"]]];
    if (errID) {
        [self handleError:errCopyingSharedSupport];
        return errCopyingSharedSupport;
    }
    
    
    [self.delegate updateProgressStatus:@"Copying Patched BaseSystem.dmg..."];
    //[self startProgressUpdateTimerWithFile:tmpBSDMGPath beingCopiedToVolume:volumePath];
    [[NSFileManager defaultManager] copyItemAtPath:tmpBSDMGPath toPath:[volumePath stringByAppendingPathComponent:[installerAppName stringByAppendingPathComponent:@"Contents/SharedSupport/BaseSystem.dmg"]] error:nil];
    [[NSFileManager defaultManager] removeItemAtPath:tmpBSDMGPath error:nil];
    [[NSFileManager defaultManager] removeItemAtPath:bsMount error:nil];
    
    [self.delegate updateProgressStatus:@"Mounting InstallESD.dmg..."];
    [self updateProgressWithValue:progressValue + 3.0];
    errID = [ip shadowMountDMGAtPath:[installerAppPath stringByAppendingPathComponent:@"Contents/SharedSupport/InstallESD.dmg"] toMountpoint:installESDMount];
    if (errID) {
        [self handleError:errMountingESDImage];
        return errMountingESDImage;
    }
    
    
    [self.delegate updateProgressStatus:@"Patching and Copying InstallESD.dmg..."];
    [self startProgressUpdateTimerWithFile:[installerAppPath stringByAppendingPathComponent:@"Contents/SharedSupport/InstallESD.dmg"] beingCopiedToVolume:volumePath];
    errID = [ip copyPatchedInstallESDFilesFromDirectory:resourcePath toESDMount:installESDMount];
    
    if (errID) {
        [self handleError:errPatchingInstallESD];
        return errPatchingInstallESD;
    }
    errID = [ip saveModifiedShadowDMG:[installerAppPath stringByAppendingPathComponent:@"Contents/SharedSupport/InstallESD.dmg"] mountedAt:installESDMount toPath:[[volumePath stringByAppendingPathComponent:installerAppName] stringByAppendingPathComponent:@"Contents/SharedSupport/InstallESD.dmg"]];
    [[NSFileManager defaultManager] removeItemAtPath:[installerAppPath stringByAppendingPathComponent:@"Contents/SharedSupport/InstallESD.dmg.shadow"] error:nil];
    [progTimer invalidate];
    if (errID) {
        [self handleError:errSavingESDImage];
        return errSavingESDImage;
    }
    [[NSFileManager defaultManager] removeItemAtPath:installESDMount error:nil];
     
    [self.delegate updateProgressStatus:@"Complete!"];
    [self.delegate operationDidComplete];
    
    return errID;
}

-(int)createISOImageAtPath:(NSString *)isoPath usingResources:(NSString *)resourcePath fromInstallerApp:(NSString *)installerAppPath {
    progressValue = 0.0;
    NUM_PROCS = 2.0;
    err errID = 0;
    const int MAX_PROGBAR_VALUE = 126.0;
    
    NSString *bsMount = @"/private/tmp/basesystem";
    NSString *installESDMount = @"/private/tmp/installesd";
    NSString *tmpBSDMGPath = @"/private/tmp/BaseSystem.dmg";
    NSString *tmpImgDir = @"/private/tmp/tmpimg";
    
    [self.delegate setProgBarMaxValue:MAX_PROGBAR_VALUE];
    [self updateProgressWithValue:progressValue+2.0];
    [self.delegate updateProgressStatus:@"Mounting BaseSystem.dmg..."];
    
    NSFileManager *man = [NSFileManager defaultManager];
    if ([man fileExistsAtPath:bsMount]) {
        [man removeItemAtPath:bsMount error:nil];
    }
    if ([man fileExistsAtPath:installESDMount]) {
        [man removeItemAtPath:installESDMount error:nil];
    }
    if ([man fileExistsAtPath:tmpBSDMGPath]) {
        [man removeItemAtPath:tmpBSDMGPath error:nil];
    }
    if ([man fileExistsAtPath:tmpImgDir]) {
        [man removeItemAtPath:tmpImgDir error:nil];
    }
    
    [man createDirectoryAtPath:tmpImgDir withIntermediateDirectories:YES attributes:nil error:nil];
    
    
    InstallerPatcher *ip = [[InstallerPatcher alloc] init];
    errID = [ip shadowMountDMGAtPath:[installerAppPath stringByAppendingPathComponent:@"Contents/SharedSupport/BaseSystem.dmg"] toMountpoint:bsMount];
    if (errID) {
        [self handleError:errMountingBSImage];
        return errMountingBSImage;
    }
    [self.delegate updateProgressStatus:@"Patching BaseSystem.dmg..."];
    [self updateProgressWithValue:progressValue+3.0];
    errID = [ip copyPatchedBaseSystemFilesFromDirectory:resourcePath toBSMount:bsMount];
    if (errID) {
        [self handleError:errPatchingBaseSystem];
        return errPatchingBaseSystem;
    }
    errID = [ip setBaseSystemPermissionsOnVolume:bsMount];
    if (errID) {
        [self handleError:errBaseSystemPerms];
        return errBaseSystemPerms;
    }
    [ip preventVolumeFromDisplayingWindowOnMount:bsMount];
    [ip addPostInstallEntryToUtilitiesOnVolume:bsMount];
    [ip setBootPlistOnVolume:bsMount];
    
    [patcherFlags saveToDirectory:bsMount];
    
    [self.delegate updateProgressStatus:@"Copying BaseSystem Booter Files..."];
    [self updateProgressWithValue:progressValue+2.0];
    ISOManager *isoMan  = [[ISOManager alloc] init];
    errID = [isoMan copyBaseSystemInstallerFilesFromDirectory:bsMount toDirectory:tmpImgDir];
    [progTimer invalidate];
    if (errID) {
        [self handleError:errCopyingBooterFiles];
        return errCopyingBooterFiles;
    }
    
    [self.delegate updateProgressStatus:@"Setting Boot Plist..."];
    [self updateProgressWithValue:progressValue+2.0];
    [isoMan setupBootPlistForBSBootOnVolume:tmpImgDir];
    
    [self.delegate updateProgressStatus:@"Storing BaseSystem.dmg..."];
    [self updateProgressWithValue:progressValue+3.0];
    [self startProgressUpdateTimerWithFile:[installerAppPath stringByAppendingPathComponent:@"Contents/SharedSupport/BaseSystem.dmg"] beingCopiedToVolume:@"/"];
    errID = [ip saveModifiedShadowDMG:[installerAppPath stringByAppendingPathComponent:@"Contents/SharedSupport/BaseSystem.dmg"] mountedAt:bsMount toPath:tmpBSDMGPath];
    [[NSFileManager defaultManager] removeItemAtPath:[installerAppPath stringByAppendingPathComponent:@"Contents/SharedSupport/BaseSystem.dmg.shadow"] error:nil];
    [progTimer invalidate];
    if (errID) {
        [self handleError:errSavingBSImage];
        return errSavingBSImage;
    }
    
    
    NSString *installerAppName = [ip locateInstallerAppAtPath:tmpImgDir];
    
    [isoMan writeIAPhysicalMediaFlagWithAppName:installerAppName toVolume:tmpImgDir];
    
    [self.delegate updateProgressStatus:@"Copying SharedSupport..."];
    [self updateProgressWithValue:progressValue+3.0];
    errID = [ip copySharedSupportDirectoryFilesFrom:[installerAppPath stringByAppendingPathComponent:@"Contents/SharedSupport"] toPath:[tmpImgDir stringByAppendingPathComponent:[installerAppName stringByAppendingPathComponent:@"Contents/SharedSupport"]]];
    if (errID) {
        [self handleError:errCopyingSharedSupport];
        return errCopyingSharedSupport;
    }
    
    [self.delegate updateProgressStatus:@"Copying Patched BaseSystem.dmg..."];
    [[NSFileManager defaultManager] copyItemAtPath:tmpBSDMGPath toPath:[tmpImgDir stringByAppendingPathComponent:[installerAppName stringByAppendingPathComponent:@"Contents/SharedSupport/BaseSystem.dmg"]] error:nil];
    [[NSFileManager defaultManager] removeItemAtPath:tmpBSDMGPath error:nil];
    [[NSFileManager defaultManager] removeItemAtPath:bsMount error:nil];
    
    [self.delegate updateProgressStatus:@"Mounting InstallESD.dmg..."];
    [self updateProgressWithValue:progressValue + 3.0];
    errID = [ip shadowMountDMGAtPath:[installerAppPath stringByAppendingPathComponent:@"Contents/SharedSupport/InstallESD.dmg"] toMountpoint:installESDMount];
    if (errID) {
        [self handleError:errMountingESDImage];
        return errMountingESDImage;
    }
    
    
    [self.delegate updateProgressStatus:@"Patching and Copying InstallESD.dmg..."];
    [self updateProgressWithValue:progressValue + 2.0];
    [self startProgressUpdateTimerWithFile:[installerAppPath stringByAppendingPathComponent:@"Contents/SharedSupport/InstallESD.dmg"] beingCopiedToVolume:tmpImgDir];
    errID = [ip copyPatchedInstallESDFilesFromDirectory:resourcePath toESDMount:installESDMount];
    
    if (errID) {
        [self handleError:errPatchingInstallESD];
        return errPatchingInstallESD;
    }
    errID = [ip saveModifiedShadowDMG:[installerAppPath stringByAppendingPathComponent:@"Contents/SharedSupport/InstallESD.dmg"] mountedAt:installESDMount toPath:[[tmpImgDir stringByAppendingPathComponent:installerAppName] stringByAppendingPathComponent:@"Contents/SharedSupport/InstallESD.dmg"]];
    [[NSFileManager defaultManager] removeItemAtPath:[installerAppPath stringByAppendingPathComponent:@"Contents/SharedSupport/InstallESD.dmg.shadow"] error:nil];
    [progTimer invalidate];
    if (errID) {
        [self handleError:errSavingESDImage];
        return errSavingESDImage;
    }
    [[NSFileManager defaultManager] removeItemAtPath:installESDMount error:nil];
    
    [self.delegate updateProgressStatus:@"Saving ISO Image..."];
    [self updateProgressWithValue:progressValue + 2.0];
    errID = [isoMan createISOImageAtPath:isoPath withVolumeName:@"Install macOS Catalina" usingContentsOfDirectory:tmpImgDir];
    if (errID) {
        [self handleError:isoErrCreatingBaseImage];
        return isoErrCreatingBaseImage;
    }
    
    [[NSFileManager defaultManager] removeItemAtPath:tmpImgDir error:nil];
    
    [self.delegate updateProgressStatus:@"Complete!"];
    [self.delegate operationDidComplete];
    return errID;
}
-(int)createPatchedInstallerAppAtPath:(NSString *)targetAppPath usingResources:(NSString *)resourcePath fromBaseApp:(NSString *)baseAppPath {
    
    progressValue = 0.0;
    NUM_PROCS = 2.0;
    err errID = 0;
    const int MAX_PROGBAR_VALUE = 120.0;
    
    NSString *bsMount = @"/private/tmp/basesystem";
    NSString *installESDMount = @"/private/tmp/installesd";
    NSString *tmpBSDMGPath = @"/private/tmp/BaseSystem.dmg";
    
    [self.delegate setProgBarMaxValue:MAX_PROGBAR_VALUE];
    [self updateProgressWithValue:progressValue+2.0];
    [self.delegate updateProgressStatus:@"Mounting BaseSystem.dmg..."];
    
    NSFileManager *man = [NSFileManager defaultManager];
    if ([man fileExistsAtPath:bsMount]) {
        [man removeItemAtPath:bsMount error:nil];
    }
    if ([man fileExistsAtPath:installESDMount]) {
        [man removeItemAtPath:installESDMount error:nil];
    }
    if ([man fileExistsAtPath:tmpBSDMGPath]) {
        [man removeItemAtPath:tmpBSDMGPath error:nil];
    }
    
    InstallerPatcher *ip = [[InstallerPatcher alloc] init];
    errID = [ip shadowMountDMGAtPath:[baseAppPath stringByAppendingPathComponent:@"Contents/SharedSupport/BaseSystem.dmg"] toMountpoint:bsMount];
    if (errID) {
        [self handleError:errMountingBSImage];
        return errMountingBSImage;
    }
    
    [self.delegate updateProgressStatus:@"Patching BaseSystem.dmg..."];
    [self updateProgressWithValue:progressValue+3.0];
    errID = [ip copyPatchedBaseSystemFilesFromDirectory:resourcePath toBSMount:bsMount];
    if (errID) {
        [self handleError:errPatchingBaseSystem];
        return errPatchingBaseSystem;
    }
    errID = [ip setBaseSystemPermissionsOnVolume:bsMount];
    if (errID) {
        [self handleError:errBaseSystemPerms];
        return errBaseSystemPerms;
    }
    [ip preventVolumeFromDisplayingWindowOnMount:bsMount];
    [ip addPostInstallEntryToUtilitiesOnVolume:bsMount];
    [ip setBootPlistOnVolume:bsMount];
    
    [patcherFlags saveToDirectory:bsMount];
    [patcherFlags saveToDirectory:@"/private/tmp"];
    
    NSString *appFile = [ip locateInstallerAppAtPath:bsMount];
    NSString *finalAppPath = [targetAppPath stringByAppendingPathComponent:appFile];
    
    if ([man fileExistsAtPath:finalAppPath]) {
        [man removeItemAtPath:finalAppPath error:nil];
    }
    
    [man copyItemAtPath:[bsMount stringByAppendingPathComponent:appFile] toPath:finalAppPath error:nil];
    
    [self.delegate updateProgressStatus:@"Storing BaseSystem.dmg..."];
    [self updateProgressWithValue:progressValue+3.0];
    [self startProgressUpdateTimerWithFile:[baseAppPath stringByAppendingPathComponent:@"Contents/SharedSupport/BaseSystem.dmg"] beingCopiedToVolume:@"/"];
    errID = [ip saveModifiedShadowDMG:[baseAppPath stringByAppendingPathComponent:@"Contents/SharedSupport/BaseSystem.dmg"] mountedAt:bsMount toPath:tmpBSDMGPath];
    [[NSFileManager defaultManager] removeItemAtPath:[baseAppPath stringByAppendingPathComponent:@"Contents/SharedSupport/BaseSystem.dmg.shadow"] error:nil];
    [progTimer invalidate];
    if (errID) {
        [self handleError:errSavingBSImage];
        return errSavingBSImage;
    }
    
    [self.delegate updateProgressStatus:@"Copying SharedSupport to App..."];
    [self updateProgressWithValue:progressValue+3.0];
    errID = [ip copySharedSupportDirectoryFilesFrom:[baseAppPath stringByAppendingPathComponent:@"Contents/SharedSupport"] toPath:[finalAppPath stringByAppendingPathComponent:@"Contents/SharedSupport"]];
    if (errID) {
        [self handleError:errCopyingSharedSupport];
        return errCopyingSharedSupport;
    }
    
    [self.delegate updateProgressStatus:@"Copying Patched BaseSystem.dmg..."];
    [self updateProgressWithValue:progressValue+2.0];
    [[NSFileManager defaultManager] copyItemAtPath:tmpBSDMGPath toPath:[finalAppPath stringByAppendingPathComponent:@"Contents/SharedSupport/BaseSystem.dmg"] error:nil];
    [[NSFileManager defaultManager] removeItemAtPath:tmpBSDMGPath error:nil];
    [[NSFileManager defaultManager] removeItemAtPath:bsMount error:nil];
    
    [self.delegate updateProgressStatus:@"Mounting InstallESD.dmg..."];
    [self updateProgressWithValue:progressValue + 3.0];
    errID = [ip shadowMountDMGAtPath:[baseAppPath stringByAppendingPathComponent:@"Contents/SharedSupport/InstallESD.dmg"] toMountpoint:installESDMount];
    if (errID) {
        [self handleError:errMountingESDImage];
        return errMountingESDImage;
    }
    
    
    [self.delegate updateProgressStatus:@"Patching and Copying InstallESD.dmg..."];
    [self startProgressUpdateTimerWithFile:[baseAppPath stringByAppendingPathComponent:@"Contents/SharedSupport/InstallESD.dmg"] beingCopiedToVolume:finalAppPath];
    errID = [ip copyPatchedInstallESDFilesFromDirectory:resourcePath toESDMount:installESDMount];
    
    if (errID) {
        [self handleError:errPatchingInstallESD];
        return errPatchingInstallESD;
    }
    errID = [ip saveModifiedShadowDMG:[baseAppPath stringByAppendingPathComponent:@"Contents/SharedSupport/InstallESD.dmg"] mountedAt:installESDMount toPath:[finalAppPath stringByAppendingPathComponent:@"Contents/SharedSupport/InstallESD.dmg"]];
    [[NSFileManager defaultManager] removeItemAtPath:[baseAppPath stringByAppendingPathComponent:@"Contents/SharedSupport/InstallESD.dmg.shadow"] error:nil];
    [progTimer invalidate];
    if (errID) {
        [self handleError:errSavingESDImage];
        return errSavingESDImage;
    }
    [[NSFileManager defaultManager] removeItemAtPath:installESDMount error:nil];
    
    InPlaceInstallerManager *im = [[InPlaceInstallerManager alloc] init];
    
    [self.delegate updateProgressStatus:@"Preparing to Launch Installer..."];
    [self updateProgressWithValue:progressValue+2.0];
    
    if ([im isSIPEnabled]) {
        [self handleError:errSIPEnabled];
        return errSIPEnabled;
    }
    
    errID = [im prepareRootFSForInstallationUsingResources:resourcePath];
    if (errID) {
        [self handleError:errPreparingFSForInPlaceInstall];
        return errPreparingFSForInPlaceInstall;
    }
    
    if ([im systemNeedsDisableLibVal]) {
        
        errID = [im loadDisableLibValKext:[resourcePath stringByAppendingPathComponent:@"DisableLibraryValidation.kext"]];
        if (errID) {
            [self handleError:errLoadingLibValKext];
            return errLoadingLibValKext;
        }
    }
    
    errID = [im launchInstallerAppAtPath:finalAppPath];
    if (errID) {
        [self handleError:errLaunchingInstaller];
        return errLaunchingInstaller;
    }
    
    [self.delegate updateProgressStatus:@"Complete!"];
    [self.delegate operationDidComplete];
    
    return errID;
}
-(void)updateProgressWithValue:(double)val {
    [self.delegate updateProgressWithValue:val];
    progressValue = val;
}
-(void)handleError:(err)errID {
    [self.delegate operationDidFailWithError:errID];
    switch (errID) {
        case errMountingBSImage:
            [self.delegate displayHelperError:@"Error Mounting BaseSystem Image" withInfo:@"An error occurred while mounting the BaseSystem image. Verify that BaseSystem.dmg is not mounted using Disk Utility, then try again."];
            break;
        case errMountingESDImage:
            [self.delegate displayHelperError:@"Error Mounting InstallESD Image" withInfo:@"An error occurred while mounting the InstallESD image. Verify that InstallESD.dmg is not mounted using Disk Utility, then try again."];
            break;
        case errSavingBSImage:
            [self.delegate displayHelperError:@"Error Saving BaseSystem Image" withInfo:@"An error occurred while attempting to save the BaseSystem image. Ensure that there is at least 10GB of free space on your Startup Disk, then try again."];
            break;
        case errSavingESDImage:
            [self.delegate displayHelperError:@"Error Saving InstallESD Image" withInfo:@"An error occurred while attempting to save the InstallESD image. Ensure that there is at least 10GB of free space on your Startup Disk, then try again."];
            break;
        case errRestoringBSImage:
            [self.delegate displayHelperError:@"Error Restoring BaseSystem" withInfo:@"An error occurred while restoring BaseSystem.dmg. Ensure that your target installer volume is formatted as \"macOS Extended (Journaled)\" (HFS+), then try running the tool again."];
            break;
        case errBaseSystemPerms:
            [self.delegate displayHelperError:@"Error Setting BaseSystem Permissions" withInfo:@"An error occurred while setting permissions on the BaseSystem volume."];
            break;
        case errCopyingSharedSupport:
            [self.delegate displayHelperError:@"Error Copying SharedSupport" withInfo:@"An error occurred while copying the SharedSupport directory to the target app."];
            break;
        case errPatchingBaseSystem:
            [self.delegate displayHelperError:@"Error Patching BaseSystem" withInfo:@"An error occurred while patching the contents of the BaseSystem image."];
            break;
        case errPatchingInstallESD:
            [self.delegate displayHelperError:@"Error Patching InstallESD" withInfo:@"An error occurred while patching the contents of the InstallESD image."];
            break;
        case errCopyingBooterFiles:
            [self.delegate displayHelperError:@"Error Copying Booter Files" withInfo:@"An error occurred while copying booter files to the target directory."];
            break;
        case isoErrCreatingBaseImage:
            [self.delegate displayHelperError:@"Error Saving ISO" withInfo:@"An error occurred while attempting to save the ISO image."];
            break;
        case errLaunchingInstaller:
            [self.delegate displayHelperError:@"Error Launching Installer" withInfo:@"An error occurred while attempting to launch the installer app."];
            break;
        case errSettingLibValKextPerms:
            [self.delegate displayHelperError:@"Error Setting Kext Permissions" withInfo:@"An error occurred while attempting to set permissions on DisableLibraryValidation.kext."];
            break;
        case errLoadingLibValKext:
            [self.delegate displayHelperError:@"Error Loading Kext" withInfo:@"An error occurred while attempting to load DisableLibraryValidation.kext."];
            break;
        case errSIPEnabled:
            [self.delegate displayHelperError:@"SIP Enabled" withInfo:@"SIP is enabled on this system. SIP must be disabled in order for the in-place installation to function correctly. To disable SIP, boot off your system's Recovery partition, or an OS X 10.11 or later installer drive, open Terminal, and run \"csrutil disable\"."];
            break;
        case errPreparingFSForInPlaceInstall:
            [self.delegate displayHelperError:@"Error Preparing Root Filesystem" withInfo:@"An error occurred while preparing your root volume to launch the patched installer app."];
            break;
        default: {
            [self.delegate displayHelperError:@"Error" withInfo:[NSString stringWithFormat:@"An unknown error occurred. (%d)", errID]];
            break;
        }
    }
}

-(void)updateCopyProgBar:(NSTimer *)timer
{
    NSDictionary *userInfo=[timer userInfo];
    NSDictionary *attr = [[NSFileManager defaultManager] attributesOfFileSystemForPath:[userInfo objectForKey:@"volume"] error:nil];
    double initialFreeSpace=[[userInfo objectForKey:@"initialFreeSpace"] doubleValue];
    double currentFreeSpace = [[attr objectForKey:NSFileSystemFreeSize] doubleValue];
    double initialProgress = [[userInfo objectForKey:@"initialProgress"] doubleValue];
    double fileSize = [[userInfo objectForKey:@"fileSize"] doubleValue];
    double progress = initialProgress + ((((initialFreeSpace-currentFreeSpace) / fileSize)*100) / NUM_PROCS);
    if (progress > initialProgress + (100.0/NUM_PROCS)) {
        progress = initialProgress + 100.0/NUM_PROCS;
    }
    [self updateProgressWithValue:progress];
    
}
-(void)startProgressUpdateTimerWithFile:(NSString *)path beingCopiedToVolume:(NSString *)volumePath {
    NSDictionary *attr1 = [[NSFileManager defaultManager] attributesOfFileSystemForPath:volumePath error:nil];
    NSDictionary *attr2 = [[NSFileManager defaultManager] attributesOfItemAtPath:path error:nil];
    double initialFreeBytes = [[attr1 objectForKey:NSFileSystemFreeSize] doubleValue];
    double initialProgress = progressValue;
    double expectedFileSize = [[attr2 objectForKey:NSFileSize] doubleValue];
    progTimer = [NSTimer scheduledTimerWithTimeInterval:0.5
                                                 target:self
                                               selector:@selector(updateCopyProgBar:)
                                               userInfo:(id)[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[NSNumber numberWithDouble:initialFreeBytes], volumePath, [NSNumber numberWithDouble:initialProgress], [NSNumber numberWithDouble:expectedFileSize], nil] forKeys:[NSArray arrayWithObjects:@"initialFreeSpace", @"volume", @"initialProgress", @"fileSize", nil]]
                                                repeats:YES];
}
-(void)logDidUpdateWithText:(NSString *)text {
    [self.delegate logDidUpdateWithText:text];
}
-(void)setPatcherFlagsObject:(PatcherFlags *)flags {
    patcherFlags = [[PatcherFlags alloc] initWithPatcherFlags:flags];
}
@end
