//
//  WizardWindowController.h
//  macOS Catalina Patcher
//
//  Created by Collin Mistr on 6/18/19.
//  Copyright (c) 2019 dosdude1 Apps. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <QuartzCore/CAAnimation.h>
#import "WizardView.h"
#import "LoggingWindowController.h"
#import "PatcherFlags.h"


@interface WizardWindowController : NSWindowController <WizardViewDelegate>
{
    BOOL shouldVerifyApp;
    int currentViewIndex;
    NSString *resourcePath;
    viewID currentView;
    LoggingWindowController *logWindow;
}

@property (strong) IBOutlet WizardView *mainView;
@property (strong) IBOutlet WizardView *contributorsView;
@property (strong) IBOutlet WizardView *installerOptionsView;
@property (strong) IBOutlet WizardView *downloadMacOSView;
@property (strong) IBOutlet WizardView *patchOptionsView;
@property (strong) IBOutlet WizardView *createBootableInstallerView;
@property (strong) IBOutlet WizardView *installerVolumeSuccessView;
@property (strong) IBOutlet WizardView *createISOView;
@property (strong) IBOutlet WizardView *isoCreationSuccessView;
@property (strong) IBOutlet WizardView *inPlacePreparationView;
@property (strong) IBOutlet WizardView *inPlacePreparationSuccessView;
@property (strong) IBOutlet WizardView *firmwareUpdateNeededView;

@property (strong) IBOutlet NSMenuItem *disableAPFSBooterMenu;
@property (strong) IBOutlet NSMenuItem *autoApplyPostInstallMenu;
-(IBAction)toggleDisableAPFSBooterMenu:(id)sender;
- (IBAction)toggleAutoApplyPostInstallMenu:(id)sender;
- (IBAction)showLogWindow:(id)sender;


@end
