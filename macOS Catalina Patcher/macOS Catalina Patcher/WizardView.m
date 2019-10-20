//
//  WizardView.m
//  macOS Catalina Patcher
//
//  Created by Collin Mistr on 6/22/19.
//  Copyright (c) 2019 dosdude1 Apps. All rights reserved.
//

#import "WizardView.h"

@implementation WizardView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        lastView = -1;
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

-(void)setLastView:(viewID)view {
    lastView = view;
}

-(viewID)getLastView {
    return lastView;
}

@end
