//
//  AppDelegate.h
//  macOS Catalina Patcher
//
//  Created by Collin Mistr on 6/12/19.
//  Copyright (c) 2019 dosdude1 Apps. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "WizardWindowController.h"

@interface AppDelegate : NSObject <NSApplicationDelegate>
{
    WizardWindowController *windowController;
}

@end
