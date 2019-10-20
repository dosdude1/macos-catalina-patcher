//
//  UpdateManager.h
//  macOS Post Install
//
//  Created by Collin Mistr on 10/5/17.
//  Copyright (c) 2017 dosdude1 Apps. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "UpdateController.h"


@protocol UpdateManagerDelegate <NSObject>
@optional
-(void)beginReInstallingUpdates:(NSArray *)updatesToInstall;
@end

@interface UpdateManager : NSWindowController <NSTableViewDataSource, NSTableViewDelegate, NSMenuDelegate>
{
    NSArray *allDownloadableUpdates;
    NSDictionary *installedPatches;
    NSMutableArray *updatesToShow;
}

@property (nonatomic, strong) id <UpdateManagerDelegate> delegate;
@property (strong) IBOutlet NSTableView *installedPatchesTable;
@property (strong) IBOutlet NSProgressIndicator *progressIndicator;
@property (strong) IBOutlet NSTextField *uninstallStatusLabel;

-(id)init;
-(void)showWindow;
- (IBAction)reInstallAllPatches:(id)sender;

@end
