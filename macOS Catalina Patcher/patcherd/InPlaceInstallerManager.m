//
//  InPlaceInstallerManager.m
//  macOS Catalina Patcher
//
//  Created by Collin Mistr on 7/23/19.
//  Copyright (c) 2019 dosdude1 Apps. All rights reserved.
//

#import "InPlaceInstallerManager.h"

@implementation InPlaceInstallerManager

-(id)init {
    self = [super init];
    return self;
}
-(int)launchInstallerAppAtPath:(NSString *)appPath {
    NSTask *open = [[NSTask alloc] init];
    [open setLaunchPath:@"/usr/bin/open"];
    [open setArguments:@[appPath]];
    NSPipe *out = [NSPipe pipe];
    [open setStandardOutput:out];
    [open setStandardError:out];
    [[LoggingManager sharedInstance] setOutputPipe:out];
    [open launch];
    [open waitUntilExit];
    return [open terminationStatus];
}
-(int)loadDisableLibValKext:(NSString *)kextPath {
    
    int err = 0;
    
    NSString *tmpKextDir = @"/private/tmp/lbv.kext";
    if ([[NSFileManager defaultManager] fileExistsAtPath:tmpKextDir]) {
        [[NSFileManager defaultManager] removeItemAtPath:tmpKextDir error:nil];
    }
    [[NSFileManager defaultManager] copyItemAtPath:kextPath toPath:tmpKextDir error:nil];
    
    err = [self setPermsOnFile:tmpKextDir];
    
    if (err) {
        return err;
    }
    
    NSTask *kextload = [[NSTask alloc] init];
    [kextload setLaunchPath:@"/sbin/kextload"];
    [kextload setArguments:@[tmpKextDir]];
    NSPipe *out = [NSPipe pipe];
    [kextload setStandardOutput:out];
    [kextload setStandardError:out];
    [[LoggingManager sharedInstance] setOutputPipe:out];
    [kextload launch];
    [kextload waitUntilExit];
    err = [kextload terminationStatus];
    return err;
}
-(BOOL)systemNeedsDisableLibVal {
    SInt32 versMin;
    Gestalt(gestaltSystemVersionMinor, &versMin);
    return (versMin >= 12);
}
-(int)prepareRootFSForInstallationUsingResources:(NSString *)resourcePath {
    int err = 0;
    SInt32 versMin;
    Gestalt(gestaltSystemVersionMinor, &versMin);
    if (versMin >= 15) {
        err = [self mountRootFSReadWrite];
        if (err) {
            return err;
        }
    }
    err = [self copyFile:[resourcePath stringByAppendingPathComponent:@"apfsbless"] toDirectory:@"/sbin"];
    if (err) {
        return err;
    }
    err = [self copyFile:[resourcePath stringByAppendingPathComponent:@"apfsinsta"] toDirectory:@"/sbin"];
    if (err) {
        return err;
    }
    err = [self copyFile:[resourcePath stringByAppendingPathComponent:@"BOOTX64.efi"] toDirectory:@"/private/tmp"];
    if (err) {
        return err;
    }
    err = [self copyFile:[resourcePath stringByAppendingPathComponent:@"EFIScriptHeader.txt"] toDirectory:@"/private/tmp"];
    if (err) {
        return err;
    }
    err = [self copyFile:[resourcePath stringByAppendingPathComponent:@"EFIScriptMain.txt"] toDirectory:@"/private/tmp"];
    if (err) {
        return err;
    }
    err = [self copyFile:[resourcePath stringByAppendingPathComponent:@"macmodels.plist"] toDirectory:@"/private/tmp"];
    if (err) {
        return err;
    }
    return err;
}
-(BOOL)isSIPEnabled {
    if ([[NSFileManager defaultManager] fileExistsAtPath:@"/usr/bin/csrutil"]) {
        NSTask *csrutil = [[NSTask alloc]init];
        [csrutil setLaunchPath:@"/usr/bin/csrutil"];
        [csrutil setArguments:[NSArray arrayWithObject:@"status"]];
        NSPipe * out = [NSPipe pipe];
        [csrutil setStandardOutput:out];
        [csrutil launch];
        [csrutil waitUntilExit];
        NSFileHandle * read = [out fileHandleForReading];
        NSData * dataRead = [read readDataToEndOfFile];
        NSString * stringRead = [[NSString alloc] initWithData:dataRead encoding:NSUTF8StringEncoding];
        if ([stringRead rangeOfString:@"Custom Configuration"].location != NSNotFound) {
            if ([stringRead rangeOfString:@"Kext Signing: disabled"].location == NSNotFound) {
                return YES;
            }
        }
        else if ([stringRead rangeOfString:@"enabled"].location != NSNotFound) {
            return YES;
        }
    }
    return NO;
}
-(int)mountRootFSReadWrite {
    int err = 0;
    NSTask *mount = [[NSTask alloc] init];
    [mount setLaunchPath:@"/sbin/mount"];
    [mount setArguments:@[@"-uw", @"/"]];
    [mount launch];
    [mount waitUntilExit];
    err = [mount terminationStatus];
    return err;
}
@end
