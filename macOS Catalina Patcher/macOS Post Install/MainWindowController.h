//
//  MainWindowController.h
//  macOS Catalina Patcher
//
//  Created by Collin Mistr on 6/21/19.
//  Copyright (c) 2019 dosdude1 Apps. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PostInstallHandler.h"
#import "Patch.h"

typedef enum {
    alertConfirmApply = 0
}alert;

@interface MainWindowController : NSWindowController <NSTableViewDataSource, NSTableViewDelegate>
{
    NSArray *availableVolumes;
    NSString *resourcePath;
    NSArray *availablePatches;
    NSString *desiredVolume;
    NSString *desiredModel;
    NSTimer *progTimer;
    int remainingTimeToApply;
    int remainingTimeToReboot;
    BOOL isInstaller;
}
@property (strong) IBOutlet NSTableView *patchesTable;
@property (strong) IBOutlet NSTextField *statusLabel;
@property (strong) IBOutlet NSProgressIndicator *progressIndicator;
@property (strong) IBOutlet NSButton *applyButton;
@property (strong) IBOutlet NSButton *skipButton;
@property (strong) IBOutlet NSTextField *summaryField;
@property (strong) IBOutlet NSPanel *changePatchSettingsView;
@property (strong) IBOutlet NSPopUpButton *modelList;
@property (strong) IBOutlet NSPopUpButton *volumeList;
@property (strong) IBOutlet NSButton *changeSettingsButton;
@property (strong) IBOutlet NSTextField *autoActionStatusLabel;
@property (strong) IBOutlet NSButton *restartButton;
@property (strong) IBOutlet NSButton *forceCacheRebuildButton;
@property (strong) IBOutlet NSProgressIndicator *rebuildingCachesIndicator;
@property (strong) IBOutlet NSTextField *rebuildingCachesLabel;

- (IBAction)applySelectedPatches:(id)sender;
- (IBAction)skipPostInstall:(id)sender;
- (IBAction)showChangeSettingsView:(id)sender;
- (IBAction)dismissSettingsView:(id)sender;
- (IBAction)setDesiredModel:(id)sender;
- (IBAction)setDesiredVolume:(id)sender;
- (IBAction)rebootSystem:(id)sender;
- (IBAction)selectedForceCacheRebuild:(id)sender;


@end
