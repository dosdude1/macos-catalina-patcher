//
//  APFS_Boot_Selector.h
//  APFS Boot Selector
//
//  Created by Collin Mistr on 8/8/19.
//  Copyright (c) 2019 dosdude1 Apps. All rights reserved.
//

#import <PreferencePanes/PreferencePanes.h>
#import "APFSPrefpaneHelper.h"
#import "APFSVolumeViewItem.h"


@interface APFS_Boot_Selector : NSPreferencePane <APFSVolumeViewItemDelegate, NSCollectionViewDelegate, APFSPrefHelperDelegate>
{
    APFSPrefpaneHelper *helper;
    NSArray *availableVolumes;
    NSString *selectedVolume;
}
- (void)mainViewDidLoad;
@property (strong) IBOutlet NSTextField *selectedVolumeLabel;
@property (strong) IBOutlet NSTextField *statusLabel;
@property (strong) IBOutlet NSProgressIndicator *progressIndicator;
@property (strong) IBOutlet NSButton *restartButton;
- (IBAction)beginReboot:(id)sender;
@property (strong) IBOutlet NSCollectionView *volumeSelectionView;


@end
