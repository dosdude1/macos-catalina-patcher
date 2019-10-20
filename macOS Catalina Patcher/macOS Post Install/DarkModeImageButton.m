//
//  DarkModeImageButton.m
//  macOS Catalina Patcher
//
//  Created by Collin Mistr on 6/24/19.
//  Copyright (c) 2019 dosdude1 Apps. All rights reserved.
//

#import "DarkModeImageButton.h"

@implementation DarkModeImageButton

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];
    
}
-(void)viewDidMoveToWindow {
    [self.image setTemplate:YES];
    [self.alternateImage setTemplate:YES];
}
@end
