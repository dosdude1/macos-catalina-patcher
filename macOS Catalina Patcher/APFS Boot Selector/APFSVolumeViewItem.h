//
//  APFSVolumeViewItem.h
//  macOS Catalina Patcher
//
//  Created by Collin Mistr on 8/9/19.
//  Copyright (c) 2019 dosdude1 Apps. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@protocol APFSVolumeViewItemDelegate <NSObject>

-(void)didSelectVolumeWithName:(NSString *)name;

@end

@interface APFSVolumeViewItem : NSCollectionViewItem
{
    NSString *volumeName;
    NSColor *highlightColor;
}

@property (strong) id <APFSVolumeViewItemDelegate> delegate;
@property (strong) IBOutlet NSButton *selectButton;
@property (strong) IBOutlet NSTextField *selectButtonLabel;
-(void)setRepresentedObject:(id)representedObject;
-(NSString *)getVolumeName;
-(void)setButtonState:(NSInteger)state;
- (IBAction)setSelected:(id)sender;
-(void)setTextHighlightColor:(NSColor *)color;

@end
