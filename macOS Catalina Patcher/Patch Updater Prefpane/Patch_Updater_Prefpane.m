//
//  Patch_Updater_Prefpane.m
//  Patch Updater Prefpane
//
//  Created by Collin Mistr on 3/3/19.
//  Copyright (c) 2019 dosdude1 Apps. All rights reserved.
//

#import "Patch_Updater_Prefpane.h"

@implementation Patch_Updater_Prefpane
- (void)willSelect
{
    if ([[PreferencesHandler sharedInstance] shouldCheckUpdatesAutomatically])
    {
        [self.autoUpdate setState:NSOnState];
    }
    else
    {
        [self.autoUpdate setState:NSOffState];
    }
    if ([[PreferencesHandler sharedInstance] shouldCheckPatchIntegrity])
    {
        [self.verifyIntegrity setState:NSOnState];
    }
    else
    {
        [self.verifyIntegrity setState:NSOffState];
    }
}
- (void)mainViewDidLoad
{
    
}

- (IBAction)setCheckForUpdates:(id)sender
{
    switch ([self.autoUpdate state]) {
        case NSOnState:
            [[PreferencesHandler sharedInstance] setShouldCheckUpdatesAutomatically:YES];
            break;
            
        case NSOffState:
            [[PreferencesHandler sharedInstance] setShouldCheckUpdatesAutomatically:NO];
            break;
    }
}

- (IBAction)setIntegrityCheck:(id)sender
{
    switch ([self.verifyIntegrity state]) {
        case NSOnState:
            [[PreferencesHandler sharedInstance] setShouldCheckPatchIntegrity:YES];
            break;
            
        case NSOffState:
            [[PreferencesHandler sharedInstance] setShouldCheckPatchIntegrity:NO];
            break;
    }
}

@end
