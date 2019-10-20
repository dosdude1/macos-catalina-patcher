//
//  APFSVolumeViewItem.m
//  macOS Catalina Patcher
//
//  Created by Collin Mistr on 8/9/19.
//  Copyright (c) 2019 dosdude1 Apps. All rights reserved.
//

#import "APFSVolumeViewItem.h"

@interface APFSVolumeViewItem ()

@end

@implementation APFSVolumeViewItem

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        highlightColor = [[NSColor selectedControlColor] colorUsingColorSpaceName:NSCalibratedRGBColorSpace];
    }
    return self;
}
-(void)setTextHighlightColor:(NSColor *)color {
    highlightColor = color;
}
-(void)setRepresentedObject:(id)representedObject {
    [self.view setWantsLayer:YES];
    volumeName = [representedObject objectForKey:@"volumeName"];
    if (volumeName) {
        [self.selectButton setImage:[[NSWorkspace sharedWorkspace] iconForFile:[@"/Volumes" stringByAppendingPathComponent:volumeName]]];
        [self.selectButtonLabel setStringValue:volumeName];
    }
}

- (IBAction)setSelected:(id)sender {
    if ([self.selectButton state] == NSOnState) {
        [self setButtonState:[self.selectButton state]];
    }
    [self.delegate didSelectVolumeWithName:volumeName];
}
-(void)setButtonState:(NSInteger)state {
    [self.selectButton setState:state];
    NSMutableAttributedString *as = [[NSMutableAttributedString alloc] initWithAttributedString:[self.selectButtonLabel attributedStringValue]];
    if (self.selectButton.state == NSOnState) {
        [as addAttribute:NSBackgroundColorAttributeName value:highlightColor range:NSMakeRange(0, [self.selectButtonLabel stringValue].length)];
    }
    else {
        [as removeAttribute:NSBackgroundColorAttributeName range:NSMakeRange(0, [self.selectButtonLabel stringValue].length)];
    }
    [self.selectButtonLabel setAttributedStringValue:as];
}
-(NSString *)getVolumeName {
    return volumeName;
}
@end
