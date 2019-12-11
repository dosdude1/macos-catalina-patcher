//
//  FirmwareUpdateNeededView.m
//  macOS Catalina Patcher
//
//  Created by Collin Mistr on 12/2/19.
//  Copyright (c) 2019 dosdude1 Apps. All rights reserved.
//

#import "FirmwareUpdateNeededView.h"

@implementation FirmwareUpdateNeededView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

-(void)viewDidMoveToWindow{
    [self.instructionsTextView readRTFDFromFile:[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"FirmwareUpdateInstructions.rtf"]];
    [self.instructionsTextView setTextColor:NSColor.textColor];
}

- (IBAction)goBack:(id)sender {
    [self.delegate transitionToView:lastView withDirection:transitionDirectionLeft];
}

- (IBAction)quitApp:(id)sender {
    [[NSApplication sharedApplication] terminate:nil];
}

- (IBAction)goToNext:(id)sender {
    [self.delegate transitionToView:viewIDInstallerAppOptions withDirection:transitionDirectionRight];
}
@end
