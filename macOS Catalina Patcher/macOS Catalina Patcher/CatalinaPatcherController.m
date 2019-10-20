//
//  CatalinaPatcherController.m
//  macOS Catalina Patcher
//
//  Created by Collin Mistr on 6/18/19.
//  Copyright (c) 2019 dosdude1 Apps. All rights reserved.
//

#import "CatalinaPatcherController.h"

@implementation CatalinaPatcherController

-(id)init {
    self = [super init];
    installerAppPath = @"";
    return self;
}

+ (CatalinaPatcherController *)sharedInstance {
    static CatalinaPatcherController *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}


-(BOOL)setInstallerAppPath:(NSString *)appPath withVerification:(BOOL)verify {
    NSDictionary *dict = [[NSDictionary alloc] initWithContentsOfFile:[appPath stringByAppendingString:@"/Contents/Info.plist"]];
    NSString *appVersion = [dict objectForKey:@"CFBundleDisplayName"];
    //NSString *appBuildVersion = [dict objectForKey:@"DTSDKBuild"];
    installerAppVersion = [dict objectForKey:@"CFBundleShortVersionString"];
    if (verify) {
        if ([appVersion isEqualToString:@"Install macOS 10.15 Beta"] && [[NSFileManager defaultManager]fileExistsAtPath:[appPath stringByAppendingString:@"/Contents/SharedSupport/InstallESD.dmg"]]) {
            installerAppPath = appPath;
            return YES;
        }
        else if ([appVersion rangeOfString:@"Install macOS Catalina"].location != NSNotFound && [[NSFileManager defaultManager]fileExistsAtPath:[appPath stringByAppendingString:@"/Contents/SharedSupport/InstallESD.dmg"]]) {
            installerAppPath = appPath;
            return YES;
        }
        else {
            return NO;
        }
    }
    else {
        installerAppPath = appPath;
        return YES;
    }
    return NO;
}
-(void)setTargetVolume:(NSString *)volume {
    installerVolumePath = volume;
}

-(int)startProcessInMode:(mode)desiredMode {
    
    switch (desiredMode) {
        case modeCreateInstallerVolume:
            [self performSelectorInBackground:@selector(startInstallerVolumeCreation) withObject:nil];
            break;
        case modeCreateISO:
            [self performSelectorInBackground:@selector(startISOImageCreation) withObject:nil];
            break;
        case modeInstallToSameMachine:
            [self performSelectorInBackground:@selector(startInPlaceInstallation) withObject:nil];
            break;
    }
    return 0;
}

-(void)startInstallerVolumeCreation {
    NSLog(@"Initializing Patch Handler");
    STPrivilegedTask *t = [[STPrivilegedTask alloc] initWithLaunchPath:[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"patcherd"]];
    OSStatus err = [t launch];
    if (err != errAuthorizationSuccess) {
        dispatch_async (dispatch_get_main_queue(), ^{
            [self.delegate helperFailedLaunchWithError:err];
        });
    }
    else {
        sleep(1);
        ph = (PatchHandler *)[NSConnection rootProxyForConnectionWithRegisteredName:@SERVER_ID host:nil];
        ph.delegate = self;
        [ph setPatcherFlagsObject:[PatcherFlags sharedInstance]];
        NSLog(@"Starting creation of volume");
        [[CatalinaPatcherLoggingManager sharedInstance] resetLog];
        int ret = [ph createPatchedInstallerOnVolume:installerVolumePath usingResources:[[NSBundle mainBundle] resourcePath] fromInstallerApp:installerAppPath];
        [ph terminateHelper];
        dispatch_async (dispatch_get_main_queue(), ^{
            [[AnalyticsManager sharedInstance] postAnalyticsOfPatcherMode:modeCreateInstallerVolume usingInstallerAppVersion:installerAppVersion withError:ret];
        });
        NSLog(@"Done");
    }
}
-(void)startISOImageCreation {
    NSLog(@"Initializing Patch Handler");
    STPrivilegedTask *t = [[STPrivilegedTask alloc] initWithLaunchPath:[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"patcherd"]];
    OSStatus err = [t launch];
    if (err != errAuthorizationSuccess) {
        dispatch_async (dispatch_get_main_queue(), ^{
            [self.delegate helperFailedLaunchWithError:err];
        });
    }
    else {
        sleep(1);
        ph = (PatchHandler *)[NSConnection rootProxyForConnectionWithRegisteredName:@SERVER_ID host:nil];
        ph.delegate = self;
        [ph setPatcherFlagsObject:[PatcherFlags sharedInstance]];
        NSLog(@"Starting creation of ISO");
        [[CatalinaPatcherLoggingManager sharedInstance] resetLog];
        int ret = [ph createISOImageAtPath:isoPath usingResources:[[NSBundle mainBundle] resourcePath] fromInstallerApp:installerAppPath];
        [ph terminateHelper];
        dispatch_async (dispatch_get_main_queue(), ^{
            [[AnalyticsManager sharedInstance] postAnalyticsOfPatcherMode:modeCreateISO usingInstallerAppVersion:installerAppVersion withError:ret];
        });
        NSLog(@"Done");
    }
}
-(void)startInPlaceInstallation {
    NSLog(@"Initializing Patch Handler");
    STPrivilegedTask *t = [[STPrivilegedTask alloc] initWithLaunchPath:[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"patcherd"]];
    OSStatus err = [t launch];
    if (err != errAuthorizationSuccess) {
        dispatch_async (dispatch_get_main_queue(), ^{
            [self.delegate helperFailedLaunchWithError:err];
        });
    }
    else {
        sleep(1);
        ph = (PatchHandler *)[NSConnection rootProxyForConnectionWithRegisteredName:@SERVER_ID host:nil];
        ph.delegate = self;
        [ph setPatcherFlagsObject:[PatcherFlags sharedInstance]];
        NSLog(@"Starting creation of patched installer");
        [[CatalinaPatcherLoggingManager sharedInstance] resetLog];
        int ret = [ph createPatchedInstallerAppAtPath:targetPatchedAppPath usingResources:[[NSBundle mainBundle] resourcePath] fromBaseApp:installerAppPath];
        [ph terminateHelper];
        dispatch_async (dispatch_get_main_queue(), ^{
            [[AnalyticsManager sharedInstance] postAnalyticsOfPatcherMode:modeInstallToSameMachine usingInstallerAppVersion:installerAppVersion withError:ret];
        });
        NSLog(@"Done");
    }
}
-(void)setISOPath:(NSString *)path {
    isoPath = path;
}
-(void)setTargetPatchedAppPath:(NSString *)appPath {
    targetPatchedAppPath = appPath;
}
-(void)updateProgressWithValue:(double)percent {
    dispatch_async (dispatch_get_main_queue(), ^{
        [self.delegate updateProgressWithValue:percent];
    });
    
}
-(void)updateProgressStatus:(NSString *)status {
    dispatch_async (dispatch_get_main_queue(), ^{
        [[CatalinaPatcherLoggingManager sharedInstance] updateLogWithText:[NSString stringWithFormat:@"\n\n%@\n\n", status]];
        [self.delegate updateProgressStatus:status];
    });
    
}
-(void)operationDidComplete {
    dispatch_async (dispatch_get_main_queue(), ^{
        [self.delegate operationDidComplete];
    });
    
}
-(void)setProgBarMaxValue:(double)maxValue {
    dispatch_async (dispatch_get_main_queue(), ^{
        [self.delegate setProgBarMaxValue:maxValue];
    });
    
}
-(void)operationDidFailWithError:(err)error {
    dispatch_async (dispatch_get_main_queue(), ^{
        [self.delegate operationDidFailWithError:error];
    });
    
}
-(void)displayHelperError:(NSString *)message withInfo:(NSString *)info {
    dispatch_async (dispatch_get_main_queue(), ^{
        [self.delegate displayHelperError:message withInfo:info];
    });
    
}
-(void)logDidUpdateWithText:(NSString *)text {
    dispatch_async (dispatch_get_main_queue(), ^{
        [[CatalinaPatcherLoggingManager sharedInstance] updateLogWithText:text];
    });
}
@end
