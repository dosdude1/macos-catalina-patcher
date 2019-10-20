//
//  WizardWindowController.m
//  macOS Catalina Patcher
//
//  Created by Collin Mistr on 6/18/19.
//  Copyright (c) 2019 dosdude1 Apps. All rights reserved.
//

#import "WizardWindowController.h"

@interface WizardWindowController ()

@end

@implementation WizardWindowController

- (id)initWithWindow:(NSWindow *)window {
    self = [super initWithWindow:window];
    if (self) {
        currentViewIndex = 0;
        resourcePath = [[NSBundle mainBundle] resourcePath];
        shouldVerifyApp = YES;
        
    }
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    self.mainView.delegate = self;
    self.contributorsView.delegate = self;
    self.installerOptionsView.delegate = self;
    self.downloadMacOSView.delegate = self;
    self.patchOptionsView.delegate = self;
    self.createBootableInstallerView.delegate = self;
    self.installerVolumeSuccessView.delegate = self;
    self.createISOView.delegate = self;
    self.isoCreationSuccessView.delegate = self;
    self.inPlacePreparationView.delegate = self;
    self.inPlacePreparationSuccessView.delegate = self;
    currentView = viewIDMain;
    [self.window.contentView addSubview:self.mainView];
    [self.window.contentView setWantsLayer:YES];
    
}
-(void)transitionToDirection:(transitionDirection)direction withView:(NSView *)view  {
    CATransition *transition = [CATransition animation];
    [transition setType:kCATransitionPush];
    if (direction == transitionDirectionLeft) {
        [transition setSubtype:kCATransitionFromLeft];
    }
    else {
        [transition setSubtype:kCATransitionFromRight];
    }
    
    [self.window.contentView setAnimations:@{@"subviews":transition}];
    [[self.window.contentView animator] replaceSubview:[[self.window.contentView subviews] objectAtIndex:0] with:view];
}



-(void)transitionToView:(viewID)view withDirection:(transitionDirection)dir {
    WizardView *desiredView;
    switch (view) {
        case viewIDMain:
            desiredView = self.mainView;
            break;
        case viewIDContrib:
            desiredView = self.contributorsView;
            break;
        case viewIDDownload:
            desiredView = self.downloadMacOSView;
            break;
        case viewIDInstallerAppOptions:
            desiredView = self.installerOptionsView;
            break;
        case viewIDPatchOptions:
            desiredView = self.patchOptionsView;
            break;
        case viewIDCreateBootableInstaller:
            desiredView = self.createBootableInstallerView;
            break;
        case viewIDInstallerVolumeSuccess:
            desiredView = self.installerVolumeSuccessView;
            break;
        case viewIDCreateISO:
            desiredView = self.createISOView;
            break;
        case viewIDISOCreationSuccess:
            desiredView = self.isoCreationSuccessView;
            break;
        case viewIDInPlaceInstallationPreparation:
            desiredView = self.inPlacePreparationView;
            break;
        case viewIDInPlaceInstallationPreparationSuccess:
            desiredView = self.inPlacePreparationSuccessView;
            break;
        case viewIDNA:
            break;
    }
    if ([desiredView getLastView] == viewIDNA) {
        [desiredView setLastView:currentView];
    }
    [self transitionToDirection:dir withView:desiredView];
    currentView = view;
}

-(IBAction)toggleDisableAPFSBooterMenu:(id)sender {
    if([self.disableAPFSBooterMenu state] == NSOnState) {
        [self.disableAPFSBooterMenu setState:NSOffState];
        [[PatcherFlags sharedInstance] setShouldUseAPFSBooter:YES];
    }
    else {
        [self.disableAPFSBooterMenu setState:NSOnState];
        [[PatcherFlags sharedInstance] setShouldUseAPFSBooter:NO];
    }
}

- (IBAction)toggleAutoApplyPostInstallMenu:(id)sender {
    if ([self.autoApplyPostInstallMenu state] == NSOnState) {
        [self.autoApplyPostInstallMenu setState:NSOffState];
        [[PatcherFlags sharedInstance] setShouldAutoApplyPostInstall:NO];
    }
    else {
        [self.autoApplyPostInstallMenu setState:NSOnState];
        [[PatcherFlags sharedInstance] setShouldAutoApplyPostInstall:YES];
    }
}

- (IBAction)showLogWindow:(id)sender {
    [self showLogWindow];
}

-(void)showLogWindow {
    if (!logWindow) {
        logWindow = [[LoggingWindowController alloc] initWithWindowNibName:@"LoggingWindowController"];
    }
    [logWindow showWindow:self];
}
@end
