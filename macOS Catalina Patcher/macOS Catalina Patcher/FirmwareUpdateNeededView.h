//
//  FirmwareUpdateNeededView.h
//  macOS Catalina Patcher
//
//  Created by Collin Mistr on 12/2/19.
//  Copyright (c) 2019 dosdude1 Apps. All rights reserved.
//

#import "WizardView.h"

@interface FirmwareUpdateNeededView : WizardView

- (IBAction)goBack:(id)sender;
- (IBAction)quitApp:(id)sender;
@property (strong) IBOutlet NSTextView *instructionsTextView;
- (IBAction)goToNext:(id)sender;

@end
