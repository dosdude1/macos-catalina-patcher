//
//  CreateISOView.h
//  macOS Catalina Patcher
//
//  Created by Collin Mistr on 7/22/19.
//  Copyright (c) 2019 dosdude1 Apps. All rights reserved.
//

#import "WizardView.h"

@interface CreateISOView : WizardView <CatalinaPatcherControllerDelegate>

- (IBAction)goBack:(id)sender;
- (IBAction)startOperation:(id)sender;

@property (strong) IBOutlet NSButton *backButton;
@property (strong) IBOutlet NSButton *startButton;
@property (strong) IBOutlet NSProgressIndicator *progressIndicator;
@property (strong) IBOutlet NSTextField *statusLabel;


@end
