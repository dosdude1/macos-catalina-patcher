//
//  InstallerAppOptionsView.m
//  macOS Catalina Patcher
//
//  Created by Collin Mistr on 6/22/19.
//  Copyright (c) 2019 dosdude1 Apps. All rights reserved.
//

#import "InstallerAppOptionsView.h"

@implementation InstallerAppOptionsView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        shouldVerifyApp = YES;
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

- (IBAction)goToDownloadView:(id)sender {
    [self.delegate transitionToView:viewIDDownload withDirection:transitionDirectionRight];
}

- (IBAction)browseForApp:(id)sender {
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    [panel setCanChooseFiles:YES];
    [panel setCanChooseDirectories:NO];
    [panel setAllowsMultipleSelection:NO];
    [panel setAllowedFileTypes:[NSArray arrayWithObject:@"app"]];
    
    
    [panel beginSheetModalForWindow:self.window completionHandler:^(NSInteger result){
        if (result == NSFileHandlingPanelOKButton) {
            NSArray* files = [panel URLs];
            NSString *appPath = [[files objectAtIndex:0]path];
            if ([[CatalinaPatcherController sharedInstance] setInstallerAppPath:appPath withVerification:YES]) {
                [self.delegate transitionToView:viewIDPatchOptions withDirection:transitionDirectionRight];
            }
            else {
                NSAlert *alert = [[NSAlert alloc] init];
                [alert setMessageText:@"Not Valid"];
                [alert setInformativeText:@"The application you have selected is not a valid copy of macOS Catalina."];
                [alert addButtonWithTitle:@"OK"];
                [alert beginSheetModalForWindow:self.window modalDelegate:self didEndSelector:nil contextInfo:nil];
            }
        }
        
    }];

}

- (IBAction)goBack:(id)sender {
    [self.delegate transitionToView:lastView withDirection:transitionDirectionLeft];
}
@end
