//
//  APFSPatch.m
//  macOS Catalina Patcher
//
//  Created by Collin Mistr on 7/12/19.
//  Copyright (c) 2019 dosdude1 Apps. All rights reserved.
//

#import "APFSPatch.h"

@implementation APFSPatch

-(id)init {
    self = [super init];
    [self setID:@"needsAPFSPatch"];
    [self setVersion:0];
    [self setName:@"APFS Patch"];
    return self;
}
-(int)applyToVolume:(NSString *)volumePath {
    int ret = 0;
    
    
    NSString *bsdName = [[APFSManager sharedInstance] getAPFSPhysicalStoreForVolumeAtPath:volumePath];
    NSString *diskName = [bsdName substringFromIndex:4];
    NSInteger diskNum = [diskName substringToIndex:[bsdName rangeOfString:@"s"].location-1].integerValue;
    NSString *ESPDisk = [NSString stringWithFormat:@"disk%lds1", diskNum];
    NSString *volumeUUID = [[APFSManager sharedInstance] getUUIDOfVolumeAtPath:volumePath];
    
    NSString *scriptHeader = [NSString stringWithContentsOfFile:[resourcePath stringByAppendingPathComponent:@"EFIScriptHeader.txt"] encoding:NSUTF8StringEncoding error:nil];
    NSString *mainScript = [NSString stringWithContentsOfFile:[resourcePath stringByAppendingPathComponent:@"EFIScriptMain.txt"] encoding:NSUTF8StringEncoding error:nil];
    NSString *scriptToWrite = [NSString stringWithFormat:@"%@\nset macOSBootFile \"%@\"\nset targetUUID \"%@\"\n%@", scriptHeader, @BootFileLocation, volumeUUID, mainScript];
    

    NSTask *mount = [[NSTask alloc] init];
    [mount setLaunchPath:@"/usr/sbin/diskutil"];
    [mount setArguments:@[@"mount", ESPDisk]];
    [mount launch];
    [mount waitUntilExit];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:@"/Volumes/EFI/EFI/BOOT"])
    {
        [[NSFileManager defaultManager] createDirectoryAtPath:@"/Volumes/EFI/EFI/BOOT" withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    [scriptToWrite writeToFile:@"/Volumes/EFI/EFI/BOOT/startup.nsh" atomically:YES encoding:NSUnicodeStringEncoding error:nil];
    [self copyFile:[resourcePath stringByAppendingPathComponent:@"BOOTX64.efi"] toDirectory:@"/Volumes/EFI/EFI/BOOT"];
    [self copyFile:[volumePath stringByAppendingPathComponent:@"usr/standalone/i386/apfs.efi"] toDirectory:@"/Volumes/EFI/EFI"];
    
    NSTask *bless = [[NSTask alloc] init];
    [bless setLaunchPath:@"/usr/sbin/bless"];
    [bless setArguments:@[@"--mount", @"/Volumes/EFI", @"--setBoot", @"--file", @"/Volumes/EFI/EFI/BOOT/BOOTX64.efi", @"--shortform"]];
    [bless launch];
    [bless waitUntilExit];
    
    NSTask *unmount = [[NSTask alloc] init];
    [unmount setLaunchPath:@"/usr/sbin/diskutil"];
    [unmount setArguments:@[@"unmount", ESPDisk]];
    [unmount launch];
    [unmount waitUntilExit];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:[volumePath stringByAppendingPathComponent:@"usr/local/sbin"]]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:[volumePath stringByAppendingPathComponent:@"usr/local/sbin"] withIntermediateDirectories:YES attributes:nil error:nil];
    }
    [self copyFile:[resourcePath stringByAppendingPathComponent:@"apfshelperd"] toDirectory:[volumePath stringByAppendingPathComponent:@"usr/local/sbin"]];
    [self copyFile:[resourcePath stringByAppendingPathComponent:@"com.dosdude1.apfshelperd.plist"] toDirectory:[volumePath stringByAppendingPathComponent:@"Library/LaunchDaemons"]];
    [self copyFile:[resourcePath stringByAppendingPathComponent:@"APFS Boot Selector.prefPane"] toDirectory:[volumePath stringByAppendingPathComponent:@"Library/PreferencePanes"]];
    
    [self setPermissionsOnDirectory:[volumePath stringByAppendingPathComponent:@"Library/LaunchDaemons/com.dosdude1.apfshelperd.plist"]];
    
    return ret;
}
-(BOOL)shouldInstallOnMachineModel:(NSString *)model {
    NSDictionary *machinePatches = [macModels objectForKey:model];
    if (machinePatches) {
        if ([[machinePatches objectForKey:identifier] boolValue]) {
            [[PatcherFlags sharedInstance] loadFromDirectory:@"/"];
            if ([[PatcherFlags sharedInstance] shouldUseAPFSBooter]) {
                return YES;
            } else {
                return NO;
            }
        }
    }
    return NO;
}
@end
