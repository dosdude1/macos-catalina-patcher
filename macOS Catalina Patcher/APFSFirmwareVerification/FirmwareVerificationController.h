//
//  FirmwareVerificationController.h
//  macOS Catalina Patcher
//
//  Created by Collin Mistr on 4/16/20.
//  Copyright (c) 2020 dosdude1 Apps. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sys/sysctl.h>
#import "APFSManager.h"
#import "FirmwareVerificationWindowController.h"

#define systemCompatibilityFile "macModels.plist"
#define kSystemNeedsAPFSROMUpdate "needsAPFSBootROMUpdate"

@interface FirmwareVerificationController : NSObject {
    FirmwareVerificationWindowController *alertWindow;
}

-(id)init;
+(FirmwareVerificationController *)sharedInstance;
-(BOOL)systemNeedsAPFSROMUpdate;
-(void)showAlertWindow;

@end
