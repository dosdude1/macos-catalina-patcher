//
//  UpdateController.h
//  macOS Post Install
//
//  Created by Collin Mistr on 7/7/17.
//  Copyright (c) 2017 dosdude1 Apps. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Update.h"
#import "PreferencesHandler.h"

typedef enum {
    connectionDownloadMetadata = 0,
    connectionDownloadUpdate = 1
}connection;

@protocol UpdateControllerDelegate <NSObject>
@optional
-(void)didRecieveUpdateData:(NSArray *)data;
-(void)updateDidFinishInstalling:(Update *)update withError:(int)err;
-(void)willInstallUpdate:(Update *)update;
-(void)installedUpdatesNeedKextcacheRebuild:(BOOL)rebuild;
-(void)kextcacheRebuildComplete;
-(void)connectionErrorOccurred;
@end


@protocol UpdateManagementDelegate <NSObject>
@optional
-(void)updateDidFinishBeingModified:(Update *)update withError:(int)err;
-(void)willModifyUpdate:(Update *)update;
-(void)modifiedUpdatesNeedKextcacheRebuild:(BOOL)rebuild;
-(void)kextcacheRebuildComplete;
-(void)connectionErrorOccurred;
@end

@interface UpdateController : NSObject <NSURLConnectionDelegate, UpdateDelegate>
{
    NSMutableArray *availableUpdates;
    NSDictionary *installedPatches;
    int connectionNum;
    NSMutableData *receivedData;
    long dlSize;
    NSString *applicationSupportDirectory;
    NSMutableArray *updatesToInstall;
    BOOL kextcacheRebuildRequired;
    NSDictionary *settings;
    NSMutableDictionary *installationReceipt;
}
@property (nonatomic, strong) id <UpdateControllerDelegate> delegate;
@property (nonatomic, strong) id <UpdateManagementDelegate> managerDelegate;

+(UpdateController *)sharedInstance;
-(void)updateData;
-(void)installUpdates:(NSArray *)updates;
-(void)rebuildKextcache;
-(NSDictionary *)getInstalledPatches;
-(NSArray *)getAllUpdates;
-(NSArray *)checkPatchIntegrityOfInstalledPatches;

@end
