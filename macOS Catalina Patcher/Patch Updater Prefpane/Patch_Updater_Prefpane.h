//
//  Patch_Updater_Prefpane.h
//  Patch Updater Prefpane
//
//  Created by Collin Mistr on 3/3/19.
//  Copyright (c) 2019 dosdude1 Apps. All rights reserved.
//

#import <PreferencePanes/PreferencePanes.h>
#import "PreferencesHandler.h"

@interface Patch_Updater_Prefpane : NSPreferencePane

- (void)mainViewDidLoad;
@property (strong) IBOutlet NSButton *autoUpdate;
@property (strong) IBOutlet NSButton *verifyIntegrity;
- (IBAction)setCheckForUpdates:(id)sender;
- (IBAction)setIntegrityCheck:(id)sender;

@end
