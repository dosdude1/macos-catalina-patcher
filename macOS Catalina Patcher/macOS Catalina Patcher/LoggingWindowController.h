//
//  LoggingWindowController.h
//  macOS Catalina Patcher
//
//  Created by Collin Mistr on 7/22/19.
//  Copyright (c) 2019 dosdude1 Apps. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "CatalinaPatcherLoggingManager.h"

@interface LoggingWindowController : NSWindowController <CatalinaPatcherLoggingDelegate>

@property (strong) IBOutlet NSTextView *logTextView;
- (IBAction)saveLog:(id)sender;

@end
