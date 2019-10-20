//
//  PostInstallHandler.m
//  macOS Catalina Patcher
//
//  Created by Collin Mistr on 6/27/19.
//  Copyright (c) 2019 dosdude1 Apps. All rights reserved.
//

#import "PostInstallHandler.h"

@implementation PostInstallHandler

-(void)checkVolume {
    if (![[self.volumeSelection titleOfSelectedItem]isEqualToString:@"Select Volume..."])
    {
        BOOL isValid=NO;
        NSString *volumePath = [@"/Volumes/"stringByAppendingString:[self.volumeSelection titleOfSelectedItem]];
        if ([[NSFileManager defaultManager]fileExistsAtPath:[volumePath stringByAppendingString:@"/System/Library/CoreServices/SystemVersion.plist"]] && ![[NSFileManager defaultManager]fileExistsAtPath:[volumePath stringByAppendingString:@"/System/Installation"]])
        {
            NSDictionary *dict = [[NSDictionary alloc]initWithContentsOfFile:[volumePath stringByAppendingString:@"/System/Library/CoreServices/SystemVersion.plist"]];
            if ([[dict objectForKey:@"ProductVersion"]rangeOfString:@"10.15"].location != NSNotFound)
            {
                isValid=YES;
            }
        }
        if (!isValid)
        {
            NSAlert *alert = [[NSAlert alloc] init];
            [alert setMessageText:@"Warning"];
            [alert setInformativeText:[[@"The volume \"" stringByAppendingString:[self.volumeSelection titleOfSelectedItem]]stringByAppendingString:@"\" does not appear to contain a valid copy of macOS Catalina."]];
            [alert addButtonWithTitle:@"OK"];
            [alert beginSheetModalForWindow:self.window modalDelegate:self didEndSelector:nil contextInfo:nil];
        }
    }
}
-(void)setUI {
    [self.patchButton setEnabled:NO];
    [self.installVideoCardPatches setEnabled:NO];
    [self.volumeSelection setEnabled:NO];
}
- (IBAction)beginPatching:(id)sender {
    if (![[self.volumeSelection titleOfSelectedItem]isEqualToString:@"Select Volume..."])
    {
        [self setUI];
        [self.progressIndicator setHidden:NO];
        [self.progressIndicator startAnimation:self];
        [self.statusLabel setHidden:NO];
        [self.statusLabel setStringValue:@"Applying Main Patches..."];
        [self performSelectorInBackground:@selector(applyPatches) withObject:nil];
    }
    else {
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:@"No Volume Selected"];
        [alert setInformativeText:@"Please select a volume containing a copy of macOS Catalina to continue."];
        [alert addButtonWithTitle:@"OK"];
        [alert beginSheetModalForWindow:self.window modalDelegate:self didEndSelector:nil contextInfo:nil];
    }
}
-(void)applyPatches {
    
    NSString *targetVolumePath = [@"/Volumes" stringByAppendingPathComponent:[self.volumeSelection titleOfSelectedItem]];
    [self copyFilesFromDirectory:[resourcePath stringByAppendingPathComponent:@"addonkexts"] toPath:[targetVolumePath stringByAppendingPathComponent:@"Library/Extensions"]];
    
    [self copyFile:[resourcePath stringByAppendingPathComponent:@"patchedkexts/IO80211Family.kext"] toDirectory:[targetVolumePath stringByAppendingPathComponent:@"System/Library/Extensions"]];
    [self copyFile:[resourcePath stringByAppendingPathComponent:@"patchedkexts/IO80211FamilyV2.kext"] toDirectory:[targetVolumePath stringByAppendingPathComponent:@"System/Library/Extensions"]];
    [self copyFile:[resourcePath stringByAppendingPathComponent:@"patchedkexts/AppleHDA.kext"] toDirectory:[targetVolumePath stringByAppendingPathComponent:@"System/Library/Extensions"]];
    [self copyFile:[resourcePath stringByAppendingPathComponent:@"patchedkexts/nvenet.kext"] toDirectory:[targetVolumePath stringByAppendingPathComponent:@"System/Library/Extensions/IONetworkingFamily.kext/Contents/PlugIns"]];
    [self copyFile:[resourcePath stringByAppendingPathComponent:@"patchedkexts/IOHIDFamily"] toDirectory:[targetVolumePath stringByAppendingPathComponent:@"System/Library/Extensions/IOHIDFamily.kext/Contents/MacOS"]];
    [[NSFileManager defaultManager] removeItemAtPath:[targetVolumePath stringByAppendingPathComponent:@"System/Library/UserEventPlugins/com.apple.telemetry.plugin"] error:nil];
    
    NSMutableDictionary *bootPlist = [[NSMutableDictionary alloc]initWithContentsOfFile:[targetVolumePath stringByAppendingString:@"/Library/Preferences/SystemConfiguration/com.apple.Boot.plist"]];
    NSString *kernelFlags = [bootPlist objectForKey:@"Kernel Flags"];
    if ([kernelFlags isEqualToString:@""])
    {
        kernelFlags = @"-no_compat_check";
    }
    else if ([kernelFlags rangeOfString:@"-no_compat_check"].location == NSNotFound)
    {
        kernelFlags = [kernelFlags stringByAppendingString:@" -no_compat_check"];
    }
    [bootPlist setObject:kernelFlags forKey:@"Kernel Flags"];
    [bootPlist writeToFile:[targetVolumePath stringByAppendingString:@"/Library/Preferences/SystemConfiguration/com.apple.Boot.plist"] atomically:YES];
    
    if (self.installVideoCardPatches.state == NSOnState) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.statusLabel setStringValue:@"Applying Video Card Patches..."];
        });
        
        [self copyFilesFromDirectory:[resourcePath stringByAppendingPathComponent:@"videocardpatches/gfxshared/kexts"] toPath:[targetVolumePath stringByAppendingPathComponent:@"System/Library/Extensions"]];
        [self copyFilesFromDirectory:[resourcePath stringByAppendingPathComponent:@"videocardpatches/gfxshared/frameworks"] toPath:[targetVolumePath stringByAppendingPathComponent:@"System/Library/Frameworks"]];
        [self copyFilesFromDirectory:[resourcePath stringByAppendingPathComponent:@"videocardpatches/gfxshared/privateframeworks"] toPath:[targetVolumePath stringByAppendingPathComponent:@"System/Library/PrivateFrameworks"]];
        [self copyFile:[resourcePath stringByAppendingPathComponent:@"videocardpatches/gfxshared/IOSurface"] toDirectory:[targetVolumePath stringByAppendingPathComponent:@"System/Library/Extensions/IOSurface.kext/Contents/MacOS"]];
        [self copyFilesFromDirectory:[resourcePath stringByAppendingPathComponent:@"videocardpatches/intelarrandalegraphics"] toPath:[targetVolumePath stringByAppendingPathComponent:@"System/Library/Extensions"]];
        [self copyFilesFromDirectory:[resourcePath stringByAppendingPathComponent:@"videocardpatches/intelsandybridgegraphics"] toPath:[targetVolumePath stringByAppendingPathComponent:@"System/Library/Extensions"]];
        [self copyFilesFromDirectory:[resourcePath stringByAppendingPathComponent:@"videocardpatches/legacyamd"] toPath:[targetVolumePath stringByAppendingPathComponent:@"System/Library/Extensions"]];
        [self copyFilesFromDirectory:[resourcePath stringByAppendingPathComponent:@"videocardpatches/legacynvidia"] toPath:[targetVolumePath stringByAppendingPathComponent:@"System/Library/Extensions"]];
        
    }
    
    [self setPermissionsOnDirectory:[targetVolumePath stringByAppendingPathComponent:@"Library/Extensions"]];
    [self setPermissionsOnDirectory:[targetVolumePath stringByAppendingPathComponent:@"System/Library/Extensions"]];
    [self setPermissionsOnDirectory:[targetVolumePath stringByAppendingPathComponent:@"System/Library/Frameworks"]];
    [self setPermissionsOnDirectory:[targetVolumePath stringByAppendingPathComponent:@"System/Library/PrivateFrameworks"]];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.statusLabel setStringValue:@"Complete!"];
        [self.progressIndicator stopAnimation:self];
        [self.progressIndicator setHidden:YES];
        [self.patchButton setHidden:YES];
        [self.rebootButton setHidden:NO];
        [self.forceCacheRebuild setHidden:NO];
    });
}
-(void)copyFile:(NSString *)filePath toDirectory:(NSString *)dirPath {
    NSTask *copy = [[NSTask alloc] init];
    [copy setLaunchPath:@"/bin/cp"];
    [copy setArguments:@[@"-r", filePath, dirPath]];
    [copy launch];
    [copy waitUntilExit];
}
-(void)copyFilesFromDirectory:(NSString *)dirPath toPath:(NSString *)targetPath {
    
    NSArray *filesToCopy = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:dirPath error:nil];
    
    for (NSString *file in filesToCopy) {
        NSTask *copy = [[NSTask alloc] init];
        [copy setLaunchPath:@"/bin/cp"];
        [copy setArguments:@[@"-r", [dirPath stringByAppendingPathComponent:file], targetPath]];
        [copy launch];
        [copy waitUntilExit];
    }
    
}
-(void)setPermissionsOnDirectory:(NSString *)path {
    NSTask *chmod = [[NSTask alloc] init];
    [chmod setLaunchPath:@"/bin/chmod"];
    [chmod setArguments:@[@"-R", @"755", path]];
    [chmod launch];
    [chmod waitUntilExit];
    
    NSTask *chown = [[NSTask alloc] init];
    [chown setLaunchPath:@"/usr/sbin/chown"];
    [chown setArguments:@[@"-R", @"0:0", path]];
    [chown launch];
    [chown waitUntilExit];
}
- (IBAction)rebootSystem:(id)sender {
    if ([self.forceCacheRebuild state]==NSOnState)
    {
        NSString *volumePath = [@"/Volumes/"stringByAppendingString:[self.volumeSelection titleOfSelectedItem]];
        NSTask *deletePreLink = [[NSTask alloc] init];
        [deletePreLink setLaunchPath:@"/bin/rm"];
        [deletePreLink setArguments:[NSArray arrayWithObject:[volumePath stringByAppendingString:@"/System/Library/prelinkedkernels/prelinkedkernel"]]];
        [deletePreLink launch];
        [deletePreLink waitUntilExit];
    }
    [self.rebootButton setEnabled:NO];
    NSTask *task = [[NSTask alloc] init];
    [task setLaunchPath:@"/sbin/reboot"];
    [task launch];
    [self.statusLabel setStringValue:@"Rebuilding caches..."];
    [self.progressIndicator setHidden:NO];
    [self.progressIndicator startAnimation:self];
}

@end
