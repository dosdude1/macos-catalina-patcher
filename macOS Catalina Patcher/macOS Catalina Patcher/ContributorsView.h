//
//  ContributorsView.h
//  macOS Catalina Patcher
//
//  Created by Collin Mistr on 6/22/19.
//  Copyright (c) 2019 dosdude1 Apps. All rights reserved.
//

#import "WizardView.h"

@interface ContributorsView : WizardView
{
    NSString *resourcePath;
}
- (IBAction)goBack:(id)sender;
- (IBAction)goToNext:(id)sender;
@property (strong) IBOutlet NSTextView *contributorsTextView;

@end
