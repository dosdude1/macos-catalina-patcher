//
//  ContributorsView.m
//  macOS Catalina Patcher
//
//  Created by Collin Mistr on 6/22/19.
//  Copyright (c) 2019 dosdude1 Apps. All rights reserved.
//

#import "ContributorsView.h"

@implementation ContributorsView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        resourcePath = [[NSBundle mainBundle] resourcePath];
        
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}
-(void)viewDidMoveToWindow{
    [self.contributorsTextView readRTFDFromFile:[resourcePath stringByAppendingPathComponent:@"Contributions.rtf"]];
    [self.contributorsTextView setTextColor:NSColor.textColor];
}
- (IBAction)goBack:(id)sender {
    [self.delegate transitionToView:lastView withDirection:transitionDirectionLeft];
}

- (IBAction)goToNext:(id)sender {
    [self.delegate transitionToView:viewIDInstallerAppOptions withDirection:transitionDirectionRight];
}
@end
