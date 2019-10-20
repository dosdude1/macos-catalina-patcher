//
//  AppDelegate.m
//  Patch Updater
//
//  Created by Collin Mistr on 7/7/17.
//  Copyright (c) 2017 dosdude1 Apps. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    isHidden=NO;
    NSArray *arguments = [[NSProcessInfo processInfo] arguments];
    if (arguments.count > 1)
    {
        if ([[arguments objectAtIndex:1] isEqualToString:@"-silent"])
        {
            isHidden=YES;
        }
    }
    if (!isHidden)
    {
        [NSApp activateIgnoringOtherApps:YES];
        [self.checkingForUpdatesWindow makeKeyAndOrderFront:self];
        [self.updateCheckingProgress setIndeterminate:YES];
        [self.updateCheckingProgress startAnimation:self];
    }
    availableUpdates = [[NSArray alloc] init];
    checkBoxStates = [[NSMutableArray alloc] init];
    [UpdateController sharedInstance].delegate = self;
    [[UpdateController sharedInstance] performSelector:@selector(updateData) withObject:nil afterDelay:1.0];
    self.updateTable.delegate = self;
    self.updateTable.dataSource = self;
    [self.updateInstallationProgress setMaxValue:100.0];
    [self.updateInstallationProgress setMinValue:0.0];
}
-(void)didRecieveUpdateData:(NSArray *)data
{
    [self.updateCheckingProgress stopAnimation:self];
    [self.checkingForUpdatesWindow close];
    if (data.count > 0)
    {
        if (isHidden)
        {
            if (![[PreferencesHandler sharedInstance] shouldCheckUpdatesAutomatically])
            {
                if ([[PreferencesHandler sharedInstance] shouldCheckPatchIntegrity])
                {
                    [self beginPatchIntegrityCheck];
                }
                else
                {
                    [[NSApplication sharedApplication] terminate:nil];
                }
            }
        }
        availableUpdates = data;
        [NSApp setActivationPolicy:NSApplicationActivationPolicyRegular];
        [NSApp activateIgnoringOtherApps:YES];
        [self.window makeKeyAndOrderFront:self];
        [self.updateTable reloadData];
    }
    else if (isHidden)
    {
        if ([[PreferencesHandler sharedInstance] shouldCheckPatchIntegrity])
        {
            [self beginPatchIntegrityCheck];
        }
        else
        {
            [[NSApplication sharedApplication] terminate:nil];
        }
    }
    else
    {
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:@"Up to Date"];
        [alert setInformativeText:@"No new patch updates are available at this time."];
        [alert addButtonWithTitle:@"Quit"];
        [alert addButtonWithTitle:@"View Installed Updates"];
        if ([alert runModal] == NSAlertSecondButtonReturn)
        {
            [NSApp setActivationPolicy:NSApplicationActivationPolicyRegular];
            [NSApp activateIgnoringOtherApps:YES];
            [self showInstalledPatchesView:self];
        }
    }
}
- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    [checkBoxStates removeAllObjects];
    for (int i=0; i<[availableUpdates count]; i++)
    {
        [checkBoxStates addObject:[NSNumber numberWithBool:YES]];
    }
    [self updateInstallButton];
    return [availableUpdates count];
}
- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    if ([[tableColumn identifier] isEqualToString:@"installUpdate"])
    {
        return [checkBoxStates objectAtIndex:row];
    }
    else if ([[tableColumn identifier] isEqualToString:@"updateName"])
    {
        return [[availableUpdates objectAtIndex:row] getUserVisibleName];
    }
    else if ([[tableColumn identifier] isEqualToString:@"updateSize"])
    {
        return [[availableUpdates objectAtIndex:row] getSize];
    }
    return nil;
}
- (void)tableView:(NSTableView *)tableView setObjectValue:(id)value forTableColumn:(NSTableColumn *)column row:(NSInteger)row
{
    [checkBoxStates replaceObjectAtIndex:row withObject:value];
    [self updateInstallButton];
}
- (void)tableViewSelectionDidChange:(NSNotification *)notification
{
    [self.patchInfoText setString:[[availableUpdates objectAtIndex:[self.updateTable selectedRow]] getDescription]];
}
-(void)updateInstallButton
{
    int numSelected=0;
    for (NSNumber *i in checkBoxStates)
    {
        if ([i boolValue])
        {
            numSelected++;
        }
    }
    if (numSelected == 1)
    {
        [self.installButton setTitle:@"Install 1 Item"];
        [self.installButton setEnabled:YES];
    }
    else if (numSelected == 0)
    {
        [self.installButton setTitle:[NSString stringWithFormat:@"Install %d Items", numSelected]];
        [self.installButton setEnabled:NO];
    }
    else
    {
        [self.installButton setTitle:[NSString stringWithFormat:@"Install %d Items", numSelected]];
        [self.installButton setEnabled:YES];
    }
}
-(BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender
{
    return YES;
}
-(void)updateDidFinishInstalling:(Update *)update withError:(int)err
{
    if (err == 0)
    {
        [self.updateInstallationProgress incrementBy:progressBarIncrement];
    }
    else
    {
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:@"Error"];
        [alert setInformativeText:[NSString stringWithFormat:@"An error occured while installing updates. (%d)", err]];
        [alert addButtonWithTitle:@"Quit"];
        [alert runModal];
        [self.updateInstallationWindow close];
        [[NSApplication sharedApplication] terminate:nil];
    }
}
-(void)willInstallUpdate:(Update *)update
{
    [self.installingStatusLabel setStringValue:[NSString stringWithFormat:@"Installing %@...", [update getUserVisibleName]]];
}
-(void)installedUpdatesNeedKextcacheRebuild:(BOOL)rebuild
{
    if (rebuild)
    {
        [self.updateInstallationProgress setIndeterminate:YES];
        [self.updateInstallationProgress startAnimation:self];
        [self.installingStatusLabel setStringValue:@"Rebuilding Kextcache..."];
        [[UpdateController sharedInstance] performSelectorInBackground:@selector(rebuildKextcache) withObject:nil];
    }
    else
    {
        [self.installingStatusLabel setStringValue:@"Complete!"];
        [self performSelector:@selector(finishInstallation) withObject:nil afterDelay:1.0];
    }
}
-(void)kextcacheRebuildComplete
{
    [self.installingStatusLabel setStringValue:@"Complete!"];
    [self.updateInstallationProgress stopAnimation:self];
    [self.updateInstallationProgress setIndeterminate:NO];
    [self performSelector:@selector(finishInstallation) withObject:nil afterDelay:1.0];
}
- (IBAction)installSelectedItems:(id)sender
{
    NSMutableArray *updatesToInstall = [[NSMutableArray alloc] init];
    for (int i=0; i<availableUpdates.count; i++)
    {
        if ([[checkBoxStates objectAtIndex:i] boolValue])
        {
            [updatesToInstall addObject:[availableUpdates objectAtIndex:i]];
        }
    }
    [self beginInstallingUpdates:updatesToInstall];
}
-(void)finishInstallation
{
    NSAlert *alert = [[NSAlert alloc] init];
    [alert setMessageText:@"Updates Installed"];
    [alert setInformativeText:@"All selected updates were installed successfully. You will need to restart your computer for changes to take effect."];
    [alert addButtonWithTitle:@"Restart Now"];
    [alert addButtonWithTitle:@"Restart Later"];
    if ([alert runModal] == NSAlertFirstButtonReturn)
    {
        NSAppleScript *reboot = [[NSAppleScript alloc] initWithSource:@"tell app \"System Events\" to restart"];
        [reboot executeAndReturnError:nil];
    }
    else
    {
        [[NSApplication sharedApplication] terminate:nil];
    }
}
-(void)connectionErrorOccurred
{
    if (!isHidden)
    {
        [self.checkingForUpdatesWindow close];
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:@"Server Unreachable"];
        [alert setInformativeText:@"The Patch Updater server could not be reached. Please check your Internet connection and try again."];
        [alert addButtonWithTitle:@"Quit"];
        [alert runModal];
    }
    [[NSApplication sharedApplication] terminate:nil];
}
- (IBAction)showInstalledPatchesView:(id)sender
{
    if (!updateManager)
    {
        updateManager = [[UpdateManager alloc] init];
        updateManager.delegate=self;
    }
    [updateManager showWindow];
}
-(void)beginInstallingUpdates:(NSArray *)updatesToInstall
{
    [self.window close];
    [self.updateInstallationProgress setDoubleValue:0.0];
    [self.updateInstallationWindow makeKeyAndOrderFront:self];
    double numUpdatesToInstall=updatesToInstall.count;
    progressBarIncrement = 100.0/(numUpdatesToInstall+1);
    [self.updateInstallationProgress startAnimation:self];
    [self.updateInstallationProgress incrementBy:progressBarIncrement];
    [[UpdateController sharedInstance] installUpdates:updatesToInstall];
}
-(void)beginReInstallingUpdates:(NSArray *)updatesToInstall
{
    [self beginInstallingUpdates:updatesToInstall];
}
-(void)beginPatchIntegrityCheck
{
    NSArray *failedPatches = [[UpdateController sharedInstance] checkPatchIntegrityOfInstalledPatches];
    if (failedPatches.count > 0)
    {
        NSString *msg = @"Patch Updater has detected that some system patches have been overwritten, and need to be re-installed. Not re-installing these patches may result in some system functionality issues. The following patches will need to be re-installed:\n";
        for (Update *u in failedPatches)
        {
            msg = [msg stringByAppendingString:[NSString stringWithFormat:@"\n- %@", [u getUserVisibleName]]];
        }
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:@"System Patches Overwritten"];
        [alert setInformativeText:msg];
        [alert addButtonWithTitle:@"Re-install Patches"];
        [alert addButtonWithTitle:@"Skip for Now"];
        [alert addButtonWithTitle:@"Don't Remind me Again"];
        NSModalResponse result = [alert runModal];
        if (result == NSAlertFirstButtonReturn)
        {
            [NSApp setActivationPolicy:NSApplicationActivationPolicyRegular];
            [NSApp activateIgnoringOtherApps:YES];
            [self beginReInstallingUpdates:failedPatches];
        }
        else if (result == NSAlertSecondButtonReturn)
        {
            [[NSApplication sharedApplication] terminate:nil];
        }
        else if (result == NSAlertThirdButtonReturn)
        {
            [[PreferencesHandler sharedInstance] setShouldCheckPatchIntegrity:NO];
            [[NSApplication sharedApplication] terminate:nil];
        }
    }
    else
    {
        [[NSApplication sharedApplication] terminate:nil];
    }
}
@end
