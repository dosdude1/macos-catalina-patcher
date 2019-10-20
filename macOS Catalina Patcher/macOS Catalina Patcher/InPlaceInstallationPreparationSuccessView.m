//
//  InPlaceInstallationPreparationSuccessView.m
//  macOS Catalina Patcher
//
//  Created by Collin Mistr on 7/23/19.
//  Copyright (c) 2019 dosdude1 Apps. All rights reserved.
//

#import "InPlaceInstallationPreparationSuccessView.h"

@implementation InPlaceInstallationPreparationSuccessView

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

- (IBAction)goBack:(id)sender {
    [self.delegate transitionToView:lastView withDirection:transitionDirectionLeft];
}

- (IBAction)quitApp:(id)sender {
    [[NSApplication sharedApplication] terminate:nil];
}
@end
