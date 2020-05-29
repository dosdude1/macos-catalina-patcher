//
//  MainWindowController.m
//  macOS Catalina Patcher
//
//  Created by Collin Mistr on 6/21/19.
//  Copyright (c) 2019 dosdude1 Apps. All rights reserved.
//

#import "MainWindowController.h"

@interface MainWindowController ()

@end

@implementation MainWindowController

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        resourcePath = [[NSBundle mainBundle]resourcePath];
        isInstaller = NO;
        remainingTimeToApply = 30;
        remainingTimeToReboot = 10;
        [self loadPatches];
        [self parseArgs];
    }
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    [self setupUI];

}
-(void)parseArgs {
    NSArray *args = [[NSProcessInfo processInfo] arguments];
    if (args.count > 1)
    {
        if ([[args objectAtIndex:1] isEqualToString:@"-installer"])
        {
            isInstaller = YES;
        }
    }
}
-(void)setupUI {
    [self.patchesTable setDelegate:self];
    [self.patchesTable setDataSource:self];
    [self.volumeList removeAllItems];
    [self.volumeList addItemsWithTitles:[[PostInstallHandler sharedInstance] getAvailableVolumes]];
    [self.modelList removeAllItems];
    [self.modelList addItemsWithTitles:[[PostInstallHandler sharedInstance] getAllModels]];
    
    NSArray *models = [[PostInstallHandler sharedInstance] getAllModels];
    for (int i=0; i<models.count; i++) {
        if ([[models objectAtIndex:i] isEqualToString:desiredModel]) {
            [self.modelList selectItemAtIndex:i];
        }
    }
    
    NSArray *volumes = [[PostInstallHandler sharedInstance] getAvailableVolumes];
    for (int i=0; i<volumes.count; i++) {
        if ([[volumes objectAtIndex:i] isEqualToString:desiredVolume]) {
            [self.volumeList selectItemAtIndex:i];
        }
    }
    
    
    [self setSelectedPatches];
    [self setSummaryString];
    
    progTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateTimeToApply:) userInfo:nil repeats:YES];
    
}
-(void)setSummaryString {
    NSString *prefix = @"a";
    if ([desiredModel rangeOfString:@"iMac"].location != NSNotFound || [desiredModel rangeOfString:@"Xserve"].location != NSNotFound) {
        prefix = @"an";
    }
    
    NSString *summary = [NSString stringWithFormat:@"Optimal patches for %@ %@ will be installed on the volume \"%@\".", prefix, desiredModel, desiredVolume];
    [self.summaryField setStringValue:summary];
}
-(void)setSelectedPatches {
    NSArray *optimalPatches = [[PostInstallHandler sharedInstance] getOptimalPatchesForModel:desiredModel];
    if (optimalPatches.count < 1 && isInstaller) {
        [[NSApplication sharedApplication] terminate:nil];
    }
    for (Patch *p in availablePatches) {
        [p setShouldBeInstalled:NO];
    }
    for (Patch *p in optimalPatches) {
        [p setShouldBeInstalled:YES];
    }
    
    [self.patchesTable reloadData];
}
-(void)loadPatches {
    availablePatches = [[PostInstallHandler sharedInstance] getAllPatches];
    desiredVolume = [[PostInstallHandler sharedInstance] getCatalinaVolume];
    desiredModel = [[PostInstallHandler sharedInstance] getMachineModel];
}
- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return [availablePatches count];
}
- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    if ([[tableColumn identifier] isEqualToString:@"installPatch"]) {
        return [NSNumber numberWithBool:[[availablePatches objectAtIndex:row] shouldBeInstalled]];
    }
    else if ([[tableColumn identifier] isEqualToString:@"patchTitle"]) {
        return [[availablePatches objectAtIndex:row] getName];
    }
    return nil;
}
- (void)tableView:(NSTableView *)tableView setObjectValue:(id)value forTableColumn:(NSTableColumn *)column row:(NSInteger)row {
    [progTimer invalidate];
    [self.autoActionStatusLabel setHidden:YES];
    [[availablePatches objectAtIndex:row] setShouldBeInstalled:[value boolValue]];
    NSString *summary = [NSString stringWithFormat:@"A custom selection of patches will be installed on the volume \"%@\".", desiredVolume];
    [self.summaryField setStringValue:summary];
}
-(void)setUI {
    [self.patchesTable setEnabled:NO];
    [self.applyButton setEnabled:NO];
    [self.skipButton setHidden:YES];
    [self.changeSettingsButton setHidden:YES];
    [self.progressIndicator setHidden:NO];
    [self.statusLabel setHidden:NO];
    [self.autoActionStatusLabel setHidden:YES];
}
- (IBAction)applySelectedPatches:(id)sender {
    
    [progTimer invalidate];
    [self.autoActionStatusLabel setHidden:YES];
    
    if ([[PostInstallHandler sharedInstance] volumeContainsCatalina:[@"/Volumes" stringByAppendingPathComponent:desiredVolume]]) {
        [self setUI];
        [self.progressIndicator setIndeterminate:YES];
        [self.progressIndicator startAnimation:self];
        [self performSelectorInBackground:@selector(beginApplyingPathces) withObject:nil];
    }
    else {
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:@"Warning"];
        [alert setInformativeText:[[@"The volume \"" stringByAppendingString:desiredVolume]stringByAppendingString:@"\" does not appear to contain a valid copy of macOS Catalina. Are you sure you want to apply patches to this volume?"]];
        [alert addButtonWithTitle:@"Cancel"];
        [alert addButtonWithTitle:@"Yes"];
        [alert beginSheetModalForWindow:self.window modalDelegate:self didEndSelector:@selector(alertDidEnd:returnCode:contextInfo:) contextInfo:alertConfirmApply];
    }
    
}

- (IBAction)skipPostInstall:(id)sender {
    [[NSApplication sharedApplication] terminate:nil];
}

- (IBAction)showChangeSettingsView:(id)sender {
    [progTimer invalidate];
    [self.autoActionStatusLabel setHidden:YES];
    [[NSApplication sharedApplication] beginSheet:self.changePatchSettingsView
                                   modalForWindow:self.window
                                    modalDelegate:self
                                   didEndSelector:nil
                                      contextInfo:nil];
}

- (IBAction)dismissSettingsView:(id)sender {
    [NSApp endSheet:self.changePatchSettingsView];
    [self.changePatchSettingsView orderOut:self];
}

- (IBAction)setDesiredModel:(id)sender {
    desiredModel = [self.modelList titleOfSelectedItem];
    [self setSummaryString];
    [self setSelectedPatches];
}

- (IBAction)setDesiredVolume:(id)sender {
    desiredVolume = [self.volumeList titleOfSelectedItem];
    [self setSummaryString];
}

- (IBAction)rebootSystem:(id)sender {
    [self.autoActionStatusLabel setHidden:YES];
    [progTimer invalidate];
    [self.restartButton setEnabled:NO];
    [self.forceCacheRebuildButton setEnabled:NO];
    [self.rebuildingCachesIndicator setHidden:NO];
    [self.rebuildingCachesIndicator startAnimation:self];
    [self.rebuildingCachesLabel setHidden:NO];
    [[PostInstallHandler sharedInstance] rebootSystemWithCacheRebuild:[self.forceCacheRebuildButton state] onVolume:[@"/Volumes" stringByAppendingPathComponent:desiredVolume]];
}

- (IBAction)selectedForceCacheRebuild:(id)sender {
    [progTimer invalidate];
    [self.autoActionStatusLabel setHidden:YES];
}

- (void)alertDidEnd:(NSAlert *)alert returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo
{
    if (contextInfo == alertConfirmApply)
    {
        if (returnCode==NSAlertSecondButtonReturn)
        {
            [self setUI];
            [self.progressIndicator setIndeterminate:YES];
            [self.progressIndicator startAnimation:self];
            [self performSelectorInBackground:@selector(beginApplyingPathces) withObject:nil];
        }
    }
}
-(void)updateTimeToApply:(NSTimer *)timer {
    remainingTimeToApply--;
    NSString *suf = @"seconds";
    if (remainingTimeToApply == 1) {
        suf = @"second";
    }
    [self.autoActionStatusLabel setStringValue:[NSString stringWithFormat:@"Selected patches will be automatically installed in %d %@.", remainingTimeToApply, suf]];
    if (remainingTimeToApply < 1) {
        [self applySelectedPatches:self];
    }
}
-(void)updateTimeToReboot:(NSTimer *)timer {
    remainingTimeToReboot--;
    NSString *suf = @"seconds";
    if (remainingTimeToReboot == 1) {
        suf = @"second";
    }
    [self.autoActionStatusLabel setStringValue:[NSString stringWithFormat:@"The system will be rebooted automatically in %d %@.", remainingTimeToReboot, suf]];
    if (remainingTimeToReboot < 1) {
        [progTimer invalidate];
        [self rebootSystem:self];
    }
}
-(void)beginApplyingPathces {
    int patchesToInstall = 0;
    for (Patch *p in availablePatches) {
        if ([p shouldBeInstalled]) {
            patchesToInstall++;
        }
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.progressIndicator setIndeterminate:NO];
        [self.progressIndicator setMinValue:0.0];
        [self.progressIndicator setMaxValue:100.0];
        [self.progressIndicator setDoubleValue:0.0];
    });
    int err = 0;
    double progress = 0.0;
    
    NSString *volumePath = [@"/Volumes" stringByAppendingPathComponent:desiredVolume];
    
    NSMutableDictionary *installedPatches = [[NSMutableDictionary alloc] init];
    if (![[NSFileManager defaultManager] fileExistsAtPath:[volumePath stringByAppendingPathComponent:@"Library/Application Support/macOS Catalina Patcher"]])
    {
        [[NSFileManager defaultManager] createDirectoryAtPath:[volumePath stringByAppendingPathComponent:@"Library/Application Support/macOS Catalina Patcher"] withIntermediateDirectories:YES attributes:nil error:nil];
    }
    else if ([[NSFileManager defaultManager] fileExistsAtPath:[volumePath stringByAppendingPathComponent:@"Library/Application Support/macOS Catalina Patcher/installedPatches.plist"]])
    {
        installedPatches = [[NSMutableDictionary alloc] initWithContentsOfFile:[volumePath stringByAppendingPathComponent:@"Library/Application Support/macOS Catalina Patcher/installedPatches.plist"]];
    }
    
    for (Patch *p in availablePatches) {
        if ([p shouldBeInstalled]) {
            progress += 100.0/(patchesToInstall+1);
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.progressIndicator setDoubleValue:progress];
                [self.statusLabel setStringValue:[NSString stringWithFormat:@"%@ %@...", [p getUIActionString], [p getName]]];
            });
            err = [p applyToVolume:volumePath];
            if (err) {
                if (!isInstaller) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self handleError:err];
                    });
                }
                break;
            }
            [installedPatches setObject:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:[p getVersion]] forKey:@"version"] forKey:[p getID]];
            
        }
    }
    
    [installedPatches writeToFile:[volumePath stringByAppendingPathComponent:@"Library/Application Support/macOS Catalina Patcher/installedPatches.plist"] atomically:YES];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.statusLabel setStringValue:@"Setting file permissions..."];
        [self.progressIndicator setIndeterminate:YES];
        [self.progressIndicator startAnimation:self];
    });
    
    
    [[PostInstallHandler sharedInstance] setPermissionsOnDirectory:[NSString stringWithFormat:@"/Volumes/%@/System/Library/Extensions", desiredVolume]];
    [[PostInstallHandler sharedInstance] setPermissionsOnDirectory:[NSString stringWithFormat:@"/Volumes/%@/Library/Extensions", desiredVolume]];
    [[PostInstallHandler sharedInstance] setPermissionsOnDirectory:[NSString stringWithFormat:@"/Volumes/%@/System/Library/Frameworks", desiredVolume]];
    [[PostInstallHandler sharedInstance] setPermissionsOnDirectory:[NSString stringWithFormat:@"/Volumes/%@/System/Library/PrivateFrameworks", desiredVolume]];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.statusLabel setStringValue:@"Updating dyld shared cache..."];
        [self.progressIndicator setIndeterminate:YES];
        [self.progressIndicator startAnimation:self];
    });
    
    [[PostInstallHandler sharedInstance] updateDyldSharedCacheOnVolume:volumePath];
    
    //Install complete
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.progressIndicator setIndeterminate:NO];
        [self.progressIndicator setDoubleValue:[self.progressIndicator maxValue]];
        [self.statusLabel setStringValue:@"Complete!"];
        
        if (!isInstaller) {
            [self.progressIndicator setHidden:YES];
            [self.statusLabel setHidden:YES];
            [self.applyButton setHidden:YES];
            [self.restartButton setHidden:NO];
            [self.forceCacheRebuildButton setHidden:NO];
            [self.autoActionStatusLabel setStringValue:@"The system will be rebooted automatically in 10 seconds."];
            [self.autoActionStatusLabel setHidden:NO];
            remainingTimeToReboot = 10;
            progTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateTimeToReboot:) userInfo:nil repeats:YES];
        }
        else {
            [[PostInstallHandler sharedInstance] beginForceCacheRebuildOnVolume:volumePath];
            [[NSApplication sharedApplication] terminate:nil];
        }
        
    });
    
}
-(void)handleError:(int)err {
    [self.progressIndicator setHidden:YES];
    [self.statusLabel setHidden:YES];
    NSAlert *alert = [[NSAlert alloc] init];
    [alert setAlertStyle:NSCriticalAlertStyle];
    [alert setMessageText:@"Error"];
    [alert setInformativeText:[NSString stringWithFormat:@"An error occurred while applying patches (%d).", err]];
    [alert addButtonWithTitle:@"OK"];
    [alert beginSheetModalForWindow:self.window modalDelegate:self didEndSelector:nil contextInfo:nil];
}
@end
