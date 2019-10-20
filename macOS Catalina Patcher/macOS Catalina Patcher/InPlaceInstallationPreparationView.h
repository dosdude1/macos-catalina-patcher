//
//  InPlaceInstallationPreparationView.h
//  macOS Catalina Patcher
//
//  Created by Collin Mistr on 7/23/19.
//  Copyright (c) 2019 dosdude1 Apps. All rights reserved.
//

#import "WizardView.h"

@interface InPlaceInstallationPreparationView : WizardView <CatalinaPatcherControllerDelegate>

- (IBAction)goBack:(id)sender;
- (IBAction)startOperation:(id)sender;
@property (strong) IBOutlet NSButton *backButton;
@property (strong) IBOutlet NSButton *startButton;
@property (strong) IBOutlet NSTextField *statusLabel;
@property (strong) IBOutlet NSProgressIndicator *progressIndicator;

@end
