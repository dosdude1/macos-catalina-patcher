//
//  InstallerAppOptionsView.h
//  macOS Catalina Patcher
//
//  Created by Collin Mistr on 6/22/19.
//  Copyright (c) 2019 dosdude1 Apps. All rights reserved.
//

#import "WizardView.h"

@interface InstallerAppOptionsView : WizardView
{
    BOOL shouldVerifyApp;
}
- (IBAction)goToDownloadView:(id)sender;

- (IBAction)browseForApp:(id)sender;
- (IBAction)goBack:(id)sender;
@end
