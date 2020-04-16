//
//  FirmwareVerificationWindowController.m
//  macOS Catalina Patcher
//
//  Created by Collin Mistr on 4/16/20.
//  Copyright (c) 2020 dosdude1 Apps. All rights reserved.
//

#import "FirmwareVerificationWindowController.h"

@interface FirmwareVerificationWindowController ()

@end

@implementation FirmwareVerificationWindowController

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    [self.instructionsTextView readRTFDFromFile:[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"FirmwareUpdateInstructions.rtf"]];
    [self.instructionsTextView setTextColor:NSColor.textColor];
    [self.window setLevel:NSStatusWindowLevel];
}

- (IBAction)rebootSystem:(id)sender {
    NSTask *reboot = [[NSTask alloc] init];
    [reboot setLaunchPath:@"/sbin/shutdown"];
    [reboot setArguments:@[@"-r", @"now"]];
    [reboot launch];
}

- (IBAction)quitApp:(id)sender {
    [[NSApplication sharedApplication] terminate:nil];
}
@end
