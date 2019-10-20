//
//  InstallerPatcher.m
//  macOS Catalina Patcher
//
//  Created by Collin Mistr on 6/15/19.
//  Copyright (c) 2019 dosdude1 Apps. All rights reserved.
//

#import "InstallerPatcher.h"

@implementation InstallerPatcher

-(id)init {
    self = [super init];
    return self;
}

-(int)shadowMountDMGAtPath:(NSString *)path toMountpoint:(NSString *)mntpt {
    int err = 0;
    NSString *shadowFilePath = [path stringByAppendingPathExtension:@"shadow"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:shadowFilePath]) {
        [[NSFileManager defaultManager] removeItemAtPath:shadowFilePath error:nil];
    }
    [[NSFileManager defaultManager] createDirectoryAtPath:mntpt withIntermediateDirectories:YES attributes:nil error:nil];
    NSTask *mount = [[NSTask alloc] init];
    [mount setLaunchPath:@"/usr/bin/hdiutil"];
    NSArray *mountArgs = [[NSArray alloc] initWithObjects:@"attach", @"-owners", @"on", path, @"-noverify", @"-nobrowse", @"-mountpoint", mntpt, @"-shadow",nil];
    [mount setArguments:mountArgs];
    NSPipe *out = [NSPipe pipe];
    [mount setStandardOutput:out];
    [mount setStandardError:out];
    [[LoggingManager sharedInstance] setOutputPipe:out];
    [mount launch];
    [mount waitUntilExit];
    err = [mount terminationStatus];
    return err;
}
-(int)copyPatchedBaseSystemFilesFromDirectory:(NSString *)dir toBSMount:(NSString *)mnt {
    
    int err = 0;
    NSString *appPath = [mnt stringByAppendingPathComponent:[self locateInstallerAppAtPath:mnt]];
    
    NSArray *paths = @[[mnt stringByAppendingPathComponent:@"Library/Extensions/DisableLibraryValidation.kext"], [mnt stringByAppendingPathComponent:@"Library/Extensions/LegacyUSBInjector.kext"], [mnt stringByAppendingPathComponent:@"Library/Extensions/SIPManager.kext"], [mnt stringByAppendingPathComponent:@"System/Library/PrelinkedKernels/prelinkedkernel"], [mnt stringByAppendingPathComponent:@"usr/libexec/brtool"], [mnt stringByAppendingPathComponent:@"System/Library/PrivateFrameworks/OSInstaller.framework/Versions/A/OSInstaller"], [appPath stringByAppendingPathComponent:@"Contents/Frameworks/OSInstallerSetup.framework/Versions/A/Frameworks/OSInstallerSetupInternal.framework/Versions/A/OSInstallerSetupInternal"], [appPath stringByAppendingPathComponent:@"Contents/Frameworks/OSInstallerSetup.framework/Versions/A/Resources/osishelperd"], [mnt stringByAppendingPathComponent:@"/sbin/apfsbless"], [mnt stringByAppendingPathComponent:@"/sbin/apfsinsta"], [mnt stringByAppendingPathComponent:@"/sbin/runposti"]];
    
    for (NSString *path in paths) {
        err = [self copyFile:[dir stringByAppendingPathComponent:[path lastPathComponent]] toDirectory:[path stringByDeletingLastPathComponent]];
        if (err) {
            return err;
        }
    }
    
    [self copyFile:[dir stringByAppendingPathComponent:@"macOS Post Install.app"] toDirectory:[mnt stringByAppendingPathComponent:@"Applications/Utilities"]];
    
    [[NSFileManager defaultManager] copyItemAtPath:[dir stringByAppendingPathComponent:@"VolumeIcon.icns"] toPath:[mnt stringByAppendingPathComponent:@".VolumeIcon.icns"] error:nil];
    
    return err;
}
-(int)setBaseSystemPermissionsOnVolume:(NSString *)path {
    
    return [self setPermsOnFile:[path stringByAppendingPathComponent:@"Library/Extensions"]];
    
}
-(int)copyPatchedInstallESDFilesFromDirectory:(NSString *)dir toESDMount:(NSString *)mnt {
    int err = 0;
    NSArray *paths = @[[mnt stringByAppendingPathComponent:@"Packages/OSInstall.mpkg"]];
    for (NSString *path in paths) {
        err = [self copyFile:[dir stringByAppendingPathComponent:[path lastPathComponent]] toDirectory:[path stringByDeletingLastPathComponent]];
        if (err) {
            return err;
        }
    }
    return err;
}
-(int)saveModifiedShadowDMG:(NSString *)dmgPath mountedAt:(NSString *)mountPt toPath:(NSString *)path {
    int err = 0;
    NSString *bsdName = [self getBSDNameForVolumePath:mountPt];
    NSTask *detach  = [[NSTask alloc] init];
    [detach setLaunchPath:@"/usr/bin/hdiutil"];
    [detach setArguments:@[@"detach", bsdName]];
    NSPipe *out = [NSPipe pipe];
    [detach setStandardOutput:out];
    [detach setStandardError:out];
    [[LoggingManager sharedInstance] setOutputPipe:out];
    [detach launch];
    [detach waitUntilExit];
    err = [detach terminationStatus];
    if (err) {
        return err;
    }
    
    NSTask *saveImage = [[NSTask alloc] init];
    [saveImage setLaunchPath:@"/usr/bin/hdiutil"];
    [saveImage setArguments:@[@"convert", @"-format", @"UDZO", @"-o", path, dmgPath, @"-shadow"]];
    out = [NSPipe pipe];
    [saveImage setStandardOutput:out];
    [saveImage setStandardError:out];
    [[LoggingManager sharedInstance] setOutputPipe:out];
    [saveImage launch];
    [saveImage waitUntilExit];
    err = [saveImage terminationStatus];
     
    return err;
}
-(int)restoreBaseSystemDMG:(NSString *)dmgPath toVolume:(NSString *)volumePath {
    int err = 0;
    NSString *volumeBSD = [self getBSDNameForVolumePath:volumePath];
    NSTask *restore = [[NSTask alloc] init];
    [restore setLaunchPath:@"/usr/sbin/asr"];
    NSArray *args = [[NSArray alloc] initWithObjects:@"restore", @"--source", dmgPath, @"--target", volumePath, @"--noprompt", @"--noverify", @"--erase", nil];
    [restore setArguments:args];
    NSPipe *out = [NSPipe pipe];
    [restore setStandardOutput:out];
    [restore setStandardError:out];
    [[LoggingManager sharedInstance] setOutputPipe:out];
    [restore launch];
    [restore waitUntilExit];
    err = [restore terminationStatus];
    if (err) {
        return err;
    }
    
    NSTask *renameVolume = [[NSTask alloc] init];
    [renameVolume setLaunchPath:@"/usr/sbin/diskutil"];
    [renameVolume setArguments:[NSArray arrayWithObjects:@"rename", volumeBSD, [volumePath lastPathComponent], nil]];
    out = [NSPipe pipe];
    [renameVolume setStandardOutput:out];
    [renameVolume setStandardError:out];
    [[LoggingManager sharedInstance] setOutputPipe:out];
    [renameVolume launch];
    [renameVolume waitUntilExit];
    err = [renameVolume terminationStatus];
    return err;
}
-(int)copySharedSupportDirectoryFilesFrom:(NSString *)ssPath toPath:(NSString *)path {
    int err = 0;
    if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    NSArray *files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:ssPath error:nil];
    for (NSString *file in files)
    {
        if ([file rangeOfString:@"BaseSystem.dmg"].location == NSNotFound && [file rangeOfString:@"InstallESD.dmg"].location == NSNotFound)
        {
            err = [self copyFile:[ssPath stringByAppendingPathComponent:file] toDirectory:path];
            if (err) {
                return err;
            }
        }
    }
    return err;
}

-(NSString *)getBSDNameForVolumePath:(NSString *)volumePath
{
    NSTask *getDiskInfo = [[NSTask alloc]init];
    [getDiskInfo setLaunchPath:@"/usr/sbin/diskutil"];
    [getDiskInfo setArguments:[NSArray arrayWithObjects:@"info", volumePath, nil]];
    NSPipe * out = [NSPipe pipe];
    [getDiskInfo setStandardOutput:out];
    [getDiskInfo launch];
    [getDiskInfo waitUntilExit];
    NSFileHandle * read = [out fileHandleForReading];
    NSData * dataRead = [read readDataToEndOfFile];
    NSString * stringRead = [[NSString alloc] initWithData:dataRead encoding:NSUTF8StringEncoding];
    NSInteger i = [stringRead rangeOfString:@"Device Identifier:"].location;
    if (i != NSNotFound)
    {
        NSString *temp = [stringRead substringFromIndex:i];
        temp = [temp substringToIndex:[temp rangeOfString:@"\n"].location];
        NSString *bsdName = [[temp substringFromIndex:26] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        return bsdName;
    }
    return @"";
}
-(NSString *)locateInstallerAppAtPath:(NSString *)path {
    NSArray *files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:nil];
    for (NSString *file in files)
    {
        if ([file rangeOfString:@"Install macOS"].location != NSNotFound)
        {
            return file;
        }
    }
    return @"";
}
-(int)preventVolumeFromDisplayingWindowOnMount:(NSString *)volumePath {
    NSTask *bless = [[NSTask alloc] init];
    [bless setLaunchPath:@"/usr/sbin/bless"];
    [bless setArguments:@[@"-folder", volumePath]];
    [bless launch];
    [bless waitUntilExit];
    return 0;
}

-(int)addPostInstallEntryToUtilitiesOnVolume:(NSString *)volumePath {
    NSString *utilitiesFile = [volumePath stringByAppendingPathComponent:@"System/Installation/CDIS/macOS Utilities.app/Contents/Resources/Utilities.plist"];
    NSMutableDictionary *utilities = [[NSMutableDictionary alloc] initWithContentsOfFile:utilitiesFile];
    NSMutableArray *buttons = [utilities objectForKey:@"Buttons"];
    NSDictionary *postInstallButton = [[NSDictionary alloc] initWithObjects:@[@"/Applications/Utilities/macOS Post Install.app", @"Apply post-install patches to a volume containing a Catalina install.", @"/Applications/Utilities/macOS Post Install.app/Contents/MacOS/macOS Post Install", @"macOS Post Install"] forKeys:@[@"BundlePath", @"DescriptionKey", @"Path", @"TitleKey"]];
    [buttons addObject:postInstallButton];
    [utilities setObject:buttons forKey:@"Buttons"];
    [utilities writeToFile:utilitiesFile atomically:YES];
    return 0;
}
-(int)setBootPlistOnVolume:(NSString *)volumePath {
    NSString *bootPlistFile = [volumePath stringByAppendingPathComponent:@"Library/Preferences/SystemConfiguration/com.apple.Boot.plist"];
    NSMutableDictionary *bootPlist = [[NSMutableDictionary alloc] initWithContentsOfFile:bootPlistFile];
    [bootPlist setObject:@"-no_compat_check" forKey:@"Kernel Flags"];
    [bootPlist writeToFile:bootPlistFile atomically:YES];
    return 0;
}
@end
