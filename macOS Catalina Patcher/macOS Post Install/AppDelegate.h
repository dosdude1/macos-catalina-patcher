//
//  AppDelegate.h
//  macOS Post Install
//
//  Created by Collin Mistr on 6/21/19.
//  Copyright (c) 2019 dosdude1 Apps. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MainWindowController.h"

@interface AppDelegate : NSObject <NSApplicationDelegate>
{
    MainWindowController *mw;
}
@property (assign) IBOutlet NSWindow *window;

@end
