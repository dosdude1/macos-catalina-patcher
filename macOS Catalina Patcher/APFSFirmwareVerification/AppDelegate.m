//
//  AppDelegate.m
//  APFSFirmwareVerification
//
//  Created by Collin Mistr on 4/16/20.
//  Copyright (c) 2020 dosdude1 Apps. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    if([[FirmwareVerificationController sharedInstance] systemNeedsAPFSROMUpdate]) {
        [[FirmwareVerificationController sharedInstance] showAlertWindow];
    } else {
        [[NSApplication sharedApplication] terminate:nil];
    }
}

@end
