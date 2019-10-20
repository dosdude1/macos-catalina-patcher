//
//  LoggingWindowController.m
//  macOS Catalina Patcher
//
//  Created by Collin Mistr on 7/22/19.
//  Copyright (c) 2019 dosdude1 Apps. All rights reserved.
//

#import "LoggingWindowController.h"

@interface LoggingWindowController ()

@end

@implementation LoggingWindowController

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
    [CatalinaPatcherLoggingManager sharedInstance].delegate = self;
    [self.logTextView setFont:[NSFont fontWithName:@"Courier" size:12]];
    [self.logTextView setString:[[CatalinaPatcherLoggingManager sharedInstance] getCurrentLogText]];
    
}
-(void)logDidUpdateWithText:(NSString *)text {
    [self.logTextView setString:text];
}
- (IBAction)saveLog:(id)sender {
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-HHmmssZ"];
    NSDate *currentDate = [NSDate date];
    NSString *dateString = [formatter stringFromDate:currentDate];
    NSString *defaultFileName = [NSString stringWithFormat:@"CatalinaPatcher-Log-%@", dateString];
    
    NSSavePanel *save = [[NSSavePanel alloc] init];
    [save setTitle:@"Save Patcher Log"];
    [save setPrompt:@"Save"];
    [save setAllowedFileTypes:@[@"txt"]];
    [save setNameFieldStringValue:defaultFileName];
    [save beginSheetModalForWindow:self.window completionHandler:^(NSInteger result){
        if (result == NSOKButton)
        {
            NSString *path = [[save URL] path];
            [[CatalinaPatcherLoggingManager sharedInstance] saveLogToPath:path];
        }
    }];
}
@end
