//
//  VolumeViewItem.h
//  macOS Catalina Patcher
//
//  Created by Collin Mistr on 6/23/19.
//  Copyright (c) 2019 dosdude1 Apps. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@protocol VolumeViewItemDelegate <NSObject>

-(void)didSelectVolumeWithName:(NSString *)name;

@end

@interface VolumeViewItem : NSCollectionViewItem
{
    NSString *volumeName;
}

@property (strong) id <VolumeViewItemDelegate> delegate;
-(NSString *)getVolumeName;
-(void)setButtonState:(NSInteger)state;
-(void)setRepresentedObject:(id)representedObject;
@property (strong) IBOutlet NSButton *selectButton;
- (IBAction)selectVolume:(id)sender;
@property (strong) IBOutlet NSBox *viewBox;


@end
