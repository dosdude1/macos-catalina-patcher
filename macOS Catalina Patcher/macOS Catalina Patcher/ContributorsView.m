//
//  ContributorsView.m
//  macOS Catalina Patcher
//
//  Created by Collin Mistr on 6/22/19.
//  Copyright (c) 2019 dosdude1 Apps. All rights reserved.
//

#import "ContributorsView.h"

@implementation ContributorsView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        resourcePath = [[NSBundle mainBundle] resourcePath];
        
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}
-(void)viewDidMoveToWindow{
    [self.contributorsTextView readRTFDFromFile:[resourcePath stringByAppendingPathComponent:@"Contributions.rtf"]];
    [self.contributorsTextView setTextColor:NSColor.textColor];
}
- (IBAction)goBack:(id)sender {
    [self.delegate transitionToView:lastView withDirection:transitionDirectionLeft];
}

- (IBAction)goToNext:(id)sender {
    compatibilityState s = [[CatalinaPatcherController sharedInstance] checkSystemCompatibility];
    switch (s) {
        case compatibilityStateNeedsAPFSROMUpdate:
            [self.delegate transitionToView:viewIDFirmwareUpdateNeeded withDirection:transitionDirectionRight];
            break;
        case compatibilityStateIsSupportedMachine:
            [self.delegate transitionToView:viewIDInstallerAppOptions withDirection:transitionDirectionRight];
            break;
        case compatibilityStateIsNativelySupportedMachine: {
            /*NSAlert *alert = [[NSAlert alloc] init];
            [alert setMessageText:@"Natively Supported Machine"];
            [alert setInformativeText:@"This machine supports Catalina natively; you do not need to use this patch. You can still use it to create a patched Catalina installer to be used on another machine."];
            [alert addButtonWithTitle:@"OK"];
            [alert beginSheetModalForWindow:self.window modalDelegate:nil didEndSelector:nil contextInfo:nil];*/
            [self.delegate transitionToView:viewIDInstallerAppOptions withDirection:transitionDirectionRight];
            break;
        }
        case compatibilityStateIsUnsupportedMachine: {
            /*NSAlert *alert = [[NSAlert alloc] init];
            [alert setMessageText:@"Unsupported Machine"];
            [alert setInformativeText:@"This machine is not compatible with Catalina using this patch. You can still create a patched installer drive, but it will not be bootable on this machine."];
            [alert addButtonWithTitle:@"OK"];
            [alert beginSheetModalForWindow:self.window modalDelegate:nil didEndSelector:nil contextInfo:nil];*/
            [self.delegate transitionToView:viewIDInstallerAppOptions withDirection:transitionDirectionRight];
            break;
        }
    }
}
@end
