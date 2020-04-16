//
//  APFSManager.m
//  macOS Catalina Patcher
//
//  Created by Collin Mistr on 10/8/19.
//  Copyright (c) 2019 dosdude1 Apps. All rights reserved.
//

#import "APFSManager.h"

@implementation APFSManager

-(id)init {
    self = [super init];
    return self;
}

+ (APFSManager *)sharedInstance {
    static APFSManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

-(NSString *)getAPFSPhysicalStoreForVolumeAtPath:(NSString *)volumePath
{
    NSTask *getDiskInfo = [[NSTask alloc]init];
    [getDiskInfo setLaunchPath:@"/usr/sbin/diskutil"];
    [getDiskInfo setArguments:[NSArray arrayWithObjects:@"list", volumePath, nil]];
    NSPipe * out = [NSPipe pipe];
    [getDiskInfo setStandardOutput:out];
    [getDiskInfo launch];
    [getDiskInfo waitUntilExit];
    NSFileHandle * read = [out fileHandleForReading];
    NSData * dataRead = [read readDataToEndOfFile];
    NSString * stringRead = [[NSString alloc] initWithData:dataRead encoding:NSUTF8StringEncoding];
    NSInteger i = [stringRead rangeOfString:@"Physical Store"].location;
    if (i != NSNotFound)
    {
        NSString *temp = [stringRead substringFromIndex:i];
        temp = [temp substringToIndex:[temp rangeOfString:@"\n"].location];
        NSString *diskName = [[temp substringFromIndex:15] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        return diskName;
    }
    return @"";
}
-(NSString *)getUUIDOfVolumeAtPath:(NSString *)volumePath
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
    NSInteger i = [stringRead rangeOfString:@"Volume UUID:"].location;
    if (i != NSNotFound)
    {
        NSString *temp = [stringRead substringFromIndex:i];
        temp = [temp substringToIndex:[temp rangeOfString:@"\n"].location];
        NSString *UUID = [[temp substringFromIndex:26] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        return UUID;
    }
    return @"";
}
-(NSString *)getPrebootVolumeforAPFSVolumeAtPath:(NSString *)volumePath
{
    NSTask *getDiskInfo = [[NSTask alloc]init];
    [getDiskInfo setLaunchPath:@"/usr/sbin/diskutil"];
    [getDiskInfo setArguments:[NSArray arrayWithObjects:@"list", volumePath, nil]];
    NSPipe * out = [NSPipe pipe];
    [getDiskInfo setStandardOutput:out];
    [getDiskInfo launch];
    [getDiskInfo waitUntilExit];
    NSFileHandle * read = [out fileHandleForReading];
    NSData * dataRead = [read readDataToEndOfFile];
    NSString * stringRead = [[NSString alloc] initWithData:dataRead encoding:NSUTF8StringEncoding];
    NSInteger i = [stringRead rangeOfString:@"Preboot"].location;
    if (i != NSNotFound)
    {
        NSString *temp = [stringRead substringFromIndex:i];
        temp = [temp substringToIndex:[temp rangeOfString:@"\n"].location];
        NSString *diskName = [[temp substringFromIndex:35] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        return diskName;
    }
    return @"";
}
-(NSString *)getRecoveryVolumeforAPFSVolumeAtPath:(NSString *)volumePath
{
    NSTask *getDiskInfo = [[NSTask alloc]init];
    [getDiskInfo setLaunchPath:@"/usr/sbin/diskutil"];
    [getDiskInfo setArguments:[NSArray arrayWithObjects:@"list", volumePath, nil]];
    NSPipe * out = [NSPipe pipe];
    [getDiskInfo setStandardOutput:out];
    [getDiskInfo launch];
    [getDiskInfo waitUntilExit];
    NSFileHandle * read = [out fileHandleForReading];
    NSData * dataRead = [read readDataToEndOfFile];
    NSString * stringRead = [[NSString alloc] initWithData:dataRead encoding:NSUTF8StringEncoding];
    NSInteger i = [stringRead rangeOfString:@"Recovery"].location;
    if (i != NSNotFound)
    {
        NSString *temp = [stringRead substringFromIndex:i];
        temp = [temp substringToIndex:[temp rangeOfString:@"\n"].location];
        NSString *diskName = [[temp substringFromIndex:35] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        return diskName;
    }
    return @"";
}
-(BOOL)romSupportsAPFS {
    io_registry_entry_t romEntry = IORegistryEntryFromPath(kIOMasterPortDefault, "IODeviceTree:/rom@0");
    if (romEntry || (romEntry = IORegistryEntryFromPath(kIOMasterPortDefault, "IODeviceTree:/rom@e0000")) != 0) {
        CFNumberRef apfsProp = IORegistryEntryCreateCFProperty(romEntry, CFSTR("firmware-features"), kCFAllocatorDefault, 0);
        if (!apfsProp) {
            NSLog(@"Could not check for APFS BootROM Support: Failed to create IORegistryEntry.");
            return NO;
        }
        unsigned long long value;
        CFNumberGetValue(apfsProp, kCFNumberSInt64Type, &value);
        NSLog(@"firmware-features: %llx", value);
        CFRelease(apfsProp);
        if ((value & 0x180000) != 0) {
            return YES;
        }
        
    } else {
        NSLog(@"Could not check for APFS BootROM Support: Failed to open IORegistryEntry.");
        return NO;
    }
    return NO;
}
@end
