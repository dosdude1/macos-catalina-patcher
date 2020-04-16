//
//  FirmwareVerificationWindowController.h
//  macOS Catalina Patcher
//
//  Created by Collin Mistr on 4/16/20.
//  Copyright (c) 2020 dosdude1 Apps. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface FirmwareVerificationWindowController : NSWindowController

@property (strong) IBOutlet NSTextView *instructionsTextView;

- (IBAction)rebootSystem:(id)sender;
- (IBAction)quitApp:(id)sender;

@end
