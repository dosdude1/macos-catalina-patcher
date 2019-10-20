//
//  APFS_Boot_Selector.m
//  APFS Boot Selector
//
//  Created by Collin Mistr on 8/8/19.
//  Copyright (c) 2019 dosdude1 Apps. All rights reserved.
//

#import "APFS_Boot_Selector.h"

@implementation APFS_Boot_Selector

- (void)mainViewDidLoad {
    [self initHelper];
}
-(void)didSelect {
    if ([[self.volumeSelectionView content] count] > 0) {
        for (NSUInteger itemIndex = 0; itemIndex < [[self.volumeSelectionView content] count]; itemIndex++) {
            APFSVolumeViewItem *item = (APFSVolumeViewItem *)[self.volumeSelectionView itemAtIndex:itemIndex];
            [item setTextHighlightColor:[[NSColor selectedControlColor] colorUsingColorSpaceName:NSCalibratedRGBColorSpace]];
        }
    }
    [self loadVolumes];
}
-(void)initHelper {
    helper = (APFSPrefpaneHelper *)[NSConnection rootProxyForConnectionWithRegisteredName:@SERVER_ID host:nil];
    if (!helper) {
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setAlertStyle:NSCriticalAlertStyle];
        [alert setMessageText:@"Error Communicating with Helper"];
        [alert setInformativeText:@"Could not communicate with helper process."];
        [alert addButtonWithTitle:@"OK"];
        [alert beginSheetModalForWindow:[[self mainView] window] modalDelegate:self didEndSelector:nil contextInfo:nil];
        [self disableUI];
    }
    [helper setResourcesPath:[[NSBundle bundleForClass:[self class]] resourcePath]];
    helper.delegate = self;
}
-(void)disableUI {
    [self.restartButton setEnabled:NO];
    for (NSUInteger itemIndex = 0; itemIndex < [[self.volumeSelectionView content] count]; itemIndex++) {
        APFSVolumeViewItem *item = (APFSVolumeViewItem *)[self.volumeSelectionView itemAtIndex:itemIndex];
        [item.selectButton setEnabled:NO];
        [item.selectButtonLabel setEnabled:NO];
    }
}
-(void)enableUI {
    [self.restartButton setEnabled:YES];
    for (NSUInteger itemIndex = 0; itemIndex < [[self.volumeSelectionView content] count]; itemIndex++) {
        APFSVolumeViewItem *item = (APFSVolumeViewItem *)[self.volumeSelectionView itemAtIndex:itemIndex];
        [item.selectButton setEnabled:YES];
        [item.selectButtonLabel setEnabled:YES];
    }
}

- (IBAction)beginReboot:(id)sender {
    NSAlert *alert = [[NSAlert alloc] init];
    [alert setMessageText:@"Are you sure you want to restart the computer?"];
    [alert setInformativeText:[NSString stringWithFormat:@"Your computer will start up from the volume \"%@\".", selectedVolume]];
    [alert addButtonWithTitle:@"Yes"];
    [alert addButtonWithTitle:@"Cancel"];
    [alert beginSheetModalForWindow:[[self mainView] window] modalDelegate:self didEndSelector:@selector(rebootConfirmAlertDidEnd:returnCode:contextInfo:) contextInfo:nil];
}
- (void)rebootConfirmAlertDidEnd:(NSAlert *)alert returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo {
    if (returnCode == NSAlertFirstButtonReturn) {
        NSAppleScript *reboot = [[NSAppleScript alloc] initWithSource:@"tell app \"System Events\" to restart"];
        [reboot executeAndReturnError:nil];
    }
}
-(void)setSelectedVolumeLabelWithVolumeName:(NSString *)volName {
    if ([volName isEqualToString:@""]) {
        [self.selectedVolumeLabel setStringValue:[NSString stringWithFormat:@"No APFS volume selected."]];
    } else {
        [self.selectedVolumeLabel setStringValue:[NSString stringWithFormat:@"You have selected \"%@\" as the Startup Volume.", volName]];
    }
}
-(void)didSelectVolumeWithName:(NSString *)name {
    selectedVolume = name;
    [self setSelectedVolumeLabelWithVolumeName:name];
    for (NSUInteger itemIndex = 0; itemIndex < [[self.volumeSelectionView content] count]; itemIndex++) {
        APFSVolumeViewItem *item = (APFSVolumeViewItem *)[self.volumeSelectionView itemAtIndex:itemIndex];
        if (![[item getVolumeName] isEqualToString:name]) {
            [item setButtonState:NSOffState];
        }
    }
    
    [self disableUI];
    [self.statusLabel setStringValue:@"Setting Startup..."];
    [self.statusLabel setHidden:NO];
    [self.progressIndicator startAnimation:self];
    [self.progressIndicator setHidden:NO];
    [helper performSelectorInBackground:@selector(beginSettingBootVolume:) withObject:selectedVolume];
}

-(void)loadVolumes {
    [self disableUI];
    [self.statusLabel setStringValue:@"Loading..."];
    [self.statusLabel setHidden:NO];
    [self.progressIndicator startAnimation:self];
    [self.progressIndicator setHidden:NO];
    [helper performSelectorInBackground:@selector(beginLoadingAvailableVolumesForRoot) withObject:nil];
}
-(void)didSetStartupVolumeWithError:(err)errID {
    [self.statusLabel setHidden:YES];
    [self.progressIndicator stopAnimation:self];
    [self.progressIndicator setHidden:YES];
    [self enableUI];
}
-(void)didLoadVolumes:(NSArray *)volumes withCurrentBootVolume:(NSString *)currentVol withError:(err)errID {
    availableVolumes = volumes;
    selectedVolume = currentVol;
    APFSVolumeViewItem *itm = [[APFSVolumeViewItem alloc] initWithNibName:@"APFSVolumeViewItem" bundle:[NSBundle bundleForClass:[self class]]];
    [self.volumeSelectionView setDelegate:self];
    [self.volumeSelectionView setItemPrototype:itm];
    NSMutableArray *volumeItems = [[NSMutableArray alloc] init];
    for (NSString *volume in availableVolumes) {
        [volumeItems addObject:@{@"volumeName": volume}];
    }
    [self.volumeSelectionView setContent:volumeItems];
    for (NSUInteger itemIndex = 0; itemIndex < [[self.volumeSelectionView content] count]; itemIndex++) {
        APFSVolumeViewItem *item = (APFSVolumeViewItem *)[self.volumeSelectionView itemAtIndex:itemIndex];
        item.delegate = self;
        if ([[item getVolumeName] isEqualToString:currentVol]) {
            [item setButtonState:NSOnState];
            [self setSelectedVolumeLabelWithVolumeName:currentVol];
        }
    }
    [self.statusLabel setHidden:YES];
    [self.progressIndicator stopAnimation:self];
    [self.progressIndicator setHidden:YES];
    [self enableUI];
}
@end
