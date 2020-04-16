//
//  FirmwareVerificationController.m
//  macOS Catalina Patcher
//
//  Created by Collin Mistr on 4/16/20.
//  Copyright (c) 2020 dosdude1 Apps. All rights reserved.
//

#import "FirmwareVerificationController.h"

@implementation FirmwareVerificationController

-(id)init {
    self = [super init];
    return self;
}

+ (FirmwareVerificationController *)sharedInstance {
    static FirmwareVerificationController *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}
-(BOOL)systemNeedsAPFSROMUpdate {
    NSString *macModel=@"";
    size_t len=0;
    sysctlbyname("hw.model", nil, &len, nil, 0);
    if (len)
    {
        char *model = malloc(len*sizeof(char));
        sysctlbyname("hw.model", model, &len, nil, 0);
        macModel=[NSString stringWithFormat:@"%s", model];
        free(model);
    }
    if (![macModel isEqualToString:@""]) {
        NSDictionary *macModels = [NSDictionary dictionaryWithContentsOfFile:[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@systemCompatibilityFile]];
        NSDictionary *supportedModels = [macModels objectForKey:@"supportedModels"];
        NSDictionary *modelFlags = [supportedModels objectForKey:macModel];
        if (modelFlags) {
            if ([modelFlags objectForKey:@kSystemNeedsAPFSROMUpdate]) {
                if ([[modelFlags objectForKey:@kSystemNeedsAPFSROMUpdate] boolValue]) {
                    if (![[APFSManager sharedInstance] romSupportsAPFS]) {
                        return YES;
                    }
                }
            }
        }
    }
    return NO;
}

-(void)showAlertWindow {
    if (!alertWindow) {
        alertWindow = [[FirmwareVerificationWindowController alloc] initWithWindowNibName:@"FirmwareVerificationWindowController"];
    }
    [alertWindow showWindow:self];
    [alertWindow.window makeKeyAndOrderFront:self];
}

@end
