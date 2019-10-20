//
//  BCM94321Patch.m
//  macOS Catalina Patcher
//
//  Created by Collin Mistr on 6/28/19.
//  Copyright (c) 2019 dosdude1 Apps. All rights reserved.
//

#import "BCM94321Patch.h"

@implementation BCM94321Patch

-(id)init {
    self = [super init];
    [self setID:@"bcm94321Patch"];
    [self setVersion:0];
    [self setName:@"Broadcom BCM4321 WiFi Support Patch"];
    return self;
}
-(int)applyToVolume:(NSString *)volumePath {
    int ret = 0;
    if ([self hasBCM94321]) {
        ret = [self copyFilesFromDirectory:[resourcePath stringByAppendingPathComponent:@"patchedkexts/bcm4321"] toPath:[volumePath stringByAppendingPathComponent:@"System/Library/Extensions"]];
    }
    return ret;
}

-(BOOL)hasBCM94321
{
    CFMutableDictionaryRef matchingDict;
    io_iterator_t iter;
    kern_return_t kr;
    io_registry_entry_t device;
    
    matchingDict = IOServiceMatching("IOService");
    if (matchingDict == NULL)
    {
        printf("Failed to match dict\n");
        return -1;
    }
    
    kr = IOServiceGetMatchingServices(kIOMasterPortDefault, matchingDict, &iter);
    if (kr != KERN_SUCCESS)
    {
        printf("Failed to get matching services\n");
        return -1;
    }
    
    const UInt8 NUM_SUBSYS_IDS = 7;
    const UInt8 vendorMatch [2] = {0xE4, 0x14}; //Broadcom - 0x14E4
    const UInt8 subMatch [NUM_SUBSYS_IDS] = {0x8C, 0x9D, 0x87, 0x88, 0x8B, 0x89, 0x90};
    BOOL match = NO;
    while ((device = IOIteratorNext(iter)))
    {
        CFMutableDictionaryRef serviceDictionary;
        if (IORegistryEntryCreateCFProperties(device,
                                              &serviceDictionary,
                                              kCFAllocatorDefault,
                                              kNilOptions) != kIOReturnSuccess)
        {
            IOObjectRelease(device);
            continue;
        }
        
        CFDataRef vendorID = CFDictionaryGetValue(serviceDictionary, CFSTR("vendor-id"));
        
        if (vendorID)
        {
            
            const UInt8 *ven = CFDataGetBytePtr(vendorID);
            if (ven[0] == vendorMatch[0] && ven[1] == vendorMatch[1])
            {
                CFDataRef subsystemID = CFDictionaryGetValue(serviceDictionary, CFSTR("subsystem-id"));
                const UInt8 *sub = CFDataGetBytePtr(subsystemID);
                for (int i=0; i<NUM_SUBSYS_IDS; i++)
                {
                    if (subMatch[i] == sub[0])
                    {
                        printf("FOUND MATCH: VEN: %X%X, DEV: %X\n", ven[0], ven[1], sub[0]);
                        match = YES;
                    }
                }
            }
        }
        CFRelease(serviceDictionary);
        IOObjectRelease(device);
    }
    IOObjectRelease(iter);
    return match;
}
@end
