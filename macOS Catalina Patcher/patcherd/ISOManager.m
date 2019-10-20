//
//  ISOManager.m
//  macOS Catalina Patcher
//
//  Created by Collin Mistr on 7/22/19.
//  Copyright (c) 2019 dosdude1 Apps. All rights reserved.
//

#import "ISOManager.h"

@implementation ISOManager

-(id)init {
    self = [super init];
    return self;
}

-(int)createISOImageAtPath:(NSString *)path withVolumeName:(NSString *)name usingContentsOfDirectory:(NSString *)dirPath {
    //hdiutil create ~/Desktop/newimage.dmg -volname "New Disk Image" -size 1g -format UDRW -srcfolder ~/Desktop/myfolder
    NSTask *createImg = [[NSTask alloc] init];
    [createImg setLaunchPath:@"/usr/bin/hdiutil"];
    [createImg setArguments:@[@"create", path, @"-volname", name, @"-format", @"UDTO", @"-srcfolder", dirPath]];
    NSPipe *out = [NSPipe pipe];
    [createImg setStandardOutput:out];
    [createImg setStandardError:out];
    [[LoggingManager sharedInstance] setOutputPipe:out];
    [createImg launch];
    [createImg waitUntilExit];
    if ([createImg terminationStatus] != 0)
    {
        return isoErrCreatingBaseImage;
    }
    return 0;
}
-(int)copyBaseSystemInstallerFilesFromDirectory:(NSString *)dir toDirectory:(NSString *)targetDir {
    int err = 0;
    NSString *appFile = [self locateInstallerAppAtPath:dir];
    
    NSFileManager *man = [NSFileManager defaultManager];
    [man createDirectoryAtPath:[targetDir stringByAppendingPathComponent:@"Library/Preferences/SystemConfiguration"] withIntermediateDirectories:YES attributes:nil error:nil];
    [man createDirectoryAtPath:[targetDir stringByAppendingPathComponent:@"System/Library/CoreServices"] withIntermediateDirectories:YES attributes:nil error:nil];
    [man createDirectoryAtPath:[targetDir stringByAppendingPathComponent:@"usr/standalone/i386"] withIntermediateDirectories:YES attributes:nil error:nil];
    
    NSArray *paths = @[appFile, @"System/Library/PrelinkedKernels", @"System/Library/CoreServices/SystemVersion.plist", @"System/Library/CoreServices/BridgeVersion.bin", @"System/Library/CoreServices/PlatformSupport.plist", @"usr/standalone/i386/SecureBoot.bundle"];
    
    for (NSString *path in paths) {
        err = [self copyFile:[dir stringByAppendingPathComponent:path] toDirectory:[targetDir stringByAppendingPathComponent:[path stringByDeletingLastPathComponent]]];
        if (err) {
            return err;
        }
    }
    
    NSArray *csFiles = [man contentsOfDirectoryAtPath:[dir stringByAppendingPathComponent:@"System/Library/CoreServices"] error:nil];
    for (NSString *file in csFiles) {
        if ([file rangeOfString:@"boot"].location != NSNotFound) {
            err = [self copyFile:[[dir stringByAppendingPathComponent:@"System/Library/CoreServices"] stringByAppendingPathComponent:file] toDirectory:[targetDir stringByAppendingPathComponent:@"System/Library/CoreServices"]];
            if (err) {
                return err;
            }
        }
    }

    return err;
}
-(int)setupBootPlistForBSBootOnVolume:(NSString *)path {
    NSMutableDictionary *boot = [[NSMutableDictionary alloc] init];
    NSString *appName = [self locateInstallerAppAtPath:path];
    NSString *BSPath = [@"/" stringByAppendingPathComponent:[appName stringByAppendingPathComponent:@"Contents/SharedSupport/BaseSystem.dmg"]];
    NSString *bootArgs = [NSString stringWithFormat:@"-no_compat_check root-dmg=file://%@", [BSPath stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    [boot setObject:bootArgs forKey:@"Kernel Flags"];
    [boot writeToFile:[path stringByAppendingPathComponent:@"Library/Preferences/SystemConfiguration/com.apple.Boot.plist"] atomically:YES];
    return 0;
}
-(int)writeIAPhysicalMediaFlagWithAppName:(NSString *)name toVolume:(NSString *)path {
    NSMutableDictionary *IAFlags = [[NSMutableDictionary alloc] init];
    [IAFlags setObject:name forKey:@"AppName"];
    [IAFlags writeToFile:[path stringByAppendingPathComponent:@".IAPhysicalMedia"] atomically:YES];
    return 0;
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
@end
