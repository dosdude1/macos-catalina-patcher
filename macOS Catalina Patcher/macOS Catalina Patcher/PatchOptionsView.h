//
//  PatchOptionsView.h
//  macOS Catalina Patcher
//
//  Created by Collin Mistr on 6/23/19.
//  Copyright (c) 2019 dosdude1 Apps. All rights reserved.
//

#import "WizardView.h"

@interface PatchOptionsView : WizardView
- (IBAction)goBack:(id)sender;
- (IBAction)installToThisMachine:(id)sender;
- (IBAction)createBootableInstaller:(id)sender;
- (IBAction)createISOImage:(id)sender;
@property (strong) IBOutlet NSButton *installToMachineButton;

@end
