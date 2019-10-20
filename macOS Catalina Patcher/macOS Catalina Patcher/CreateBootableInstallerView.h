//
//  CreateBootableInstallerView.h
//  macOS Catalina Patcher
//
//  Created by Collin Mistr on 6/23/19.
//  Copyright (c) 2019 dosdude1 Apps. All rights reserved.
//

#import "WizardView.h"
#import "VolumeViewItem.h"

typedef enum {
    alertConfirmErase = 0
}alert;

@interface CreateBootableInstallerView : WizardView <NSCollectionViewDelegate, VolumeViewItemDelegate, CatalinaPatcherControllerDelegate>
{
    NSMutableArray *availableVolumes;
    NSString *selectedVolume;
}
- (IBAction)goBack:(id)sender;
- (IBAction)startOperation:(id)sender;
- (IBAction)cancelOperation:(id)sender;
@property (strong) IBOutlet NSButton *backButton;
@property (strong) IBOutlet NSButton *startButton;
@property (strong) IBOutlet NSButton *cancelButton;
@property (strong) IBOutlet NSProgressIndicator *progressIndicator;
@property (strong) IBOutlet NSTextField *statusLabel;
@property (strong) IBOutlet NSCollectionView *volumeSelectionView;
@property (strong) IBOutlet NSTextField *actionSummaryField;


@end
