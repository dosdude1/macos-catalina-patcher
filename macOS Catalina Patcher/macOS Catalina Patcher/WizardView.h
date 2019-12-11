//
//  WizardView.h
//  macOS Catalina Patcher
//
//  Created by Collin Mistr on 6/22/19.
//  Copyright (c) 2019 dosdude1 Apps. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "CatalinaPatcherController.h"

typedef enum {
    viewIDNA = -1,
    viewIDMain = 0,
    viewIDContrib = 1,
    viewIDDownload = 2,
    viewIDInstallerAppOptions = 3,
    viewIDPatchOptions = 4,
    viewIDCreateBootableInstaller = 5,
    viewIDInstallerVolumeSuccess = 6,
    viewIDCreateISO = 7,
    viewIDISOCreationSuccess = 8,
    viewIDInPlaceInstallationPreparation = 9,
    viewIDInPlaceInstallationPreparationSuccess = 10,
    viewIDFirmwareUpdateNeeded = 11
}viewID;


typedef enum {
    transitionDirectionRight = 0,
    transitionDirectionLeft = 1
}transitionDirection;

@protocol WizardViewDelegate <NSObject>
@required
-(void)transitionToView:(viewID)view withDirection:(transitionDirection)dir;
-(void)showLogWindow;

@end

@interface WizardView : NSView
{
    viewID lastView;
}
@property (strong) id <WizardViewDelegate> delegate;
-(void)setLastView:(viewID)view;
-(viewID)getLastView;

@end
