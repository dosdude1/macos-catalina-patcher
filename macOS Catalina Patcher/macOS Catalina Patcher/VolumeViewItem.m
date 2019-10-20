//
//  VolumeViewItem.m
//  macOS Catalina Patcher
//
//  Created by Collin Mistr on 6/23/19.
//  Copyright (c) 2019 dosdude1 Apps. All rights reserved.
//

#import "VolumeViewItem.h"

@interface VolumeViewItem ()

@end

@implementation VolumeViewItem

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
    }
    return self;
}

-(NSString *)getVolumeName {
    return volumeName;
}
-(void)setButtonState:(NSInteger)state {
    [self.selectButton setState:state];
    if (self.selectButton.state == NSOnState) {
        [self.viewBox setTransparent:NO];
    }
    else {
        [self.viewBox setTransparent:YES];
    }
}
-(void)setRepresentedObject:(id)representedObject {
    [self.view setWantsLayer:YES];
    volumeName = [representedObject objectForKey:@"volumeName"];
    [self.selectButton setImage:[[NSWorkspace sharedWorkspace] iconForFile:[@"/Volumes" stringByAppendingPathComponent:volumeName]]];
    [self.selectButton setTitle:volumeName];
}
- (IBAction)selectVolume:(id)sender {
    [self.view.layer setBackgroundColor:(__bridge CGColorRef)([NSColor grayColor])];
    [self.delegate didSelectVolumeWithName:volumeName];
    if (self.selectButton.state == NSOnState) {
        [self.viewBox setTransparent:NO];
    }
    else {
        [self.selectButton setState:NSOnState];
    }
}
@end
