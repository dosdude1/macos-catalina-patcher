//
//  InPlaceInstallationPreparationView.m
//  macOS Catalina Patcher
//
//  Created by Collin Mistr on 7/23/19.
//  Copyright (c) 2019 dosdude1 Apps. All rights reserved.
//

#import "InPlaceInstallationPreparationView.h"

@implementation InPlaceInstallationPreparationView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    return self;
}
-(void)setUI {
    
    [self.backButton setHidden:YES];
    [self.startButton setHidden:YES];
    [self.statusLabel setHidden:NO];
    [self.progressIndicator setHidden:NO];
}
-(void)resetUI {
    
    [self.backButton setHidden:NO];
    [self.startButton setHidden:NO];
    [self.statusLabel setHidden:YES];
    [self.progressIndicator setHidden:YES];
}
- (void)drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}
- (IBAction)goBack:(id)sender {
    [self.delegate transitionToView:lastView withDirection:transitionDirectionLeft];
}

- (IBAction)startOperation:(id)sender {
    if (![[PatcherFlags sharedInstance] shouldAutoApplyPostInstall]) {
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:@"Post-Install Patches"];
        [alert setInformativeText:@"When using this installation method, post-install patches must be automatically installed, as there is no way to install them manually. Are you sure you'd like to continue without post-install patches being applied?"];
        [alert addButtonWithTitle:@"Cancel"];
        [alert addButtonWithTitle:@"Yes"];
        [alert beginSheetModalForWindow:self.window modalDelegate:self didEndSelector:@selector(confirmationAlertDidEnd:returnCode:contextInfo:) contextInfo:nil];
    }
    else {
        [self startConfirmedOperation];
    }
}
-(void)startConfirmedOperation {
    [[CatalinaPatcherController sharedInstance] setTargetPatchedAppPath:@"/private/tmp"];
    [self setUI];
    [self.progressIndicator setIndeterminate:YES];
    [self.progressIndicator startAnimation:self];
    [self.statusLabel setStringValue:@"Starting Helper..."];
    [CatalinaPatcherController sharedInstance].delegate = self;
    [[CatalinaPatcherController sharedInstance] startProcessInMode:modeInstallToSameMachine];
}
-(void)updateProgressWithValue:(double)percent {
    if ([self.progressIndicator isIndeterminate]) {
        [self.progressIndicator stopAnimation:self];
        [self.progressIndicator setIndeterminate:NO];
        [self.progressIndicator setMinValue:0.0];
        [self.progressIndicator setDoubleValue:0.0];
    }
    [self.progressIndicator setDoubleValue:percent];
}
-(void)updateProgressStatus:(NSString *)status {
    [self.statusLabel setStringValue:status];
}
-(void)operationDidComplete {
    [self.progressIndicator setDoubleValue:[self.progressIndicator maxValue]];
    [self resetUI];
    [self.delegate transitionToView:viewIDInPlaceInstallationPreparationSuccess withDirection:transitionDirectionRight];
}
-(void)operationDidFailWithError:(err)error {
    [self resetUI];
}
-(void)setProgBarMaxValue:(double)maxValue {
    [self.progressIndicator setMaxValue:maxValue];
}
-(void)helperFailedLaunchWithError:(OSStatus)err {
    switch (err) {
        case errAuthorizationCanceled:
            [self resetUI];
            break;
            
        default: {
            [self resetUI];
            NSAlert *alert = [[NSAlert alloc] init];
            [alert setAlertStyle:NSCriticalAlertStyle];
            [alert setMessageText:@"Authentication Error"];
            [alert setInformativeText:@"An error occurred while processing authentication"];
            [alert addButtonWithTitle:@"OK"];
            [alert beginSheetModalForWindow:self.window modalDelegate:self didEndSelector:nil contextInfo:nil];
            break; }
    }
}
-(void)displayHelperError:(NSString *)message withInfo:(NSString *)info {
    NSAlert *alert = [[NSAlert alloc] init];
    [alert setAlertStyle:NSCriticalAlertStyle];
    [alert setMessageText:message];
    [alert setInformativeText:info];
    [alert addButtonWithTitle:@"OK"];
    [alert addButtonWithTitle:@"View Log"];
    [alert beginSheetModalForWindow:self.window modalDelegate:self didEndSelector:@selector(helperErrorAlertDidEnd:returnCode:contextInfo:) contextInfo:nil];
}
- (void)helperErrorAlertDidEnd:(NSAlert *)alert returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo {
    switch (returnCode) {
        case NSAlertSecondButtonReturn:
            [self.delegate showLogWindow];
            break;
    }
}
- (void)confirmationAlertDidEnd:(NSAlert *)alert returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo {
    switch (returnCode) {
        case NSAlertSecondButtonReturn:
            [self startConfirmedOperation];
            break;
    }
}
@end
