//
//  AppDelegate.m
//  macOS Catalina Patcher
//
//  Created by Collin Mistr on 6/12/19.
//  Copyright (c) 2019 dosdude1 Apps. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    windowController = [[WizardWindowController alloc] initWithWindowNibName:@"WizardWindowController"];
    [windowController showWindow:self];
}
-(BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender {
    return YES;
}

@end
