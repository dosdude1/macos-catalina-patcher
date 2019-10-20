//
//  AppDelegate.h
//  Patch Updater
//
//  Created by Collin Mistr on 7/7/17.
//  Copyright (c) 2017 dosdude1 Apps. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "UpdateController.h"
#import "Update.h"
#import "PreferencesHandler.h"
#import "UpdateManager.h"

@interface AppDelegate : NSObject <NSApplicationDelegate, NSTableViewDataSource, NSTableViewDelegate, UpdateControllerDelegate, UpdateManagerDelegate>
{
    NSArray *availableUpdates;
    NSMutableArray *checkBoxStates;
    double progressBarIncrement;
    BOOL isHidden;
    UpdateManager *updateManager;
}


@property (assign) IBOutlet NSWindow *window;
@property (strong) IBOutlet NSTableView *updateTable;
@property (strong) IBOutlet NSTextView *patchInfoText;
@property (strong) IBOutlet NSButton *installButton;
@property (strong) IBOutlet NSWindow *checkingForUpdatesWindow;
@property (strong) IBOutlet NSProgressIndicator *updateCheckingProgress;
@property (strong) IBOutlet NSTextField *installingStatusLabel;
@property (strong) IBOutlet NSProgressIndicator *updateInstallationProgress;
@property (strong) IBOutlet NSWindow *updateInstallationWindow;
@property (strong) IBOutlet NSButton *automaticUpdateCheck;

- (IBAction)installSelectedItems:(id)sender;
- (IBAction)showInstalledPatchesView:(id)sender;

@end
