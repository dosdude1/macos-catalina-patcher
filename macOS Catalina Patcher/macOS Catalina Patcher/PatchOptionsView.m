//
//  PatchOptionsView.m
//  macOS Catalina Patcher
//
//  Created by Collin Mistr on 6/23/19.
//  Copyright (c) 2019 dosdude1 Apps. All rights reserved.
//

#import "PatchOptionsView.h"

@implementation PatchOptionsView

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

- (IBAction)installToThisMachine:(id)sender {
    [self.delegate transitionToView:viewIDInPlaceInstallationPreparation withDirection:transitionDirectionRight];
}

- (IBAction)createBootableInstaller:(id)sender {
    [self.delegate transitionToView:viewIDCreateBootableInstaller withDirection:transitionDirectionRight];
}

- (IBAction)createISOImage:(id)sender {
    [self.delegate transitionToView:viewIDCreateISO withDirection:transitionDirectionRight];
}
-(void)viewDidMoveToWindow {
    SInt32 versMin;
    Gestalt(gestaltSystemVersionMinor, &versMin);
    if (versMin >= 11) {
        [self.installToMachineButton setEnabled:YES];
    }
    else {
        [self.installToMachineButton setEnabled:NO];
    }
}
@end
