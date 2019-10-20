//
//  AppDelegate.m
//  macOS Post Install
//
//  Created by Collin Mistr on 6/21/19.
//  Copyright (c) 2019 dosdude1 Apps. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    mw = [[MainWindowController alloc] initWithWindowNibName:@"MainWindowController"];
    [mw showWindow:self];
}
-(BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender {
    return YES;
}
@end
