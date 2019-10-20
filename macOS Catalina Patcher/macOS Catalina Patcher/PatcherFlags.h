//
//  PatcherFlags.h
//  macOS Catalina Patcher
//
//  Created by Collin Mistr on 8/20/19.
//  Copyright (c) 2019 dosdude1 Apps. All rights reserved.
//

#import <Foundation/Foundation.h>

#define PatcherFlagsFile "CatalinaPatcherFlags.plist"
#define kShouldUseAPFSBooter "shouldUseAPFSBooter"
#define kShouldAutoApplyPostInstall "shouldAutoApplyPostInstallPatches"

@interface PatcherFlags : NSObject
{
    BOOL shouldUseAPFSBooter;
    BOOL shouldAutoApplyPostInstall;
}

-(id)init;
-(id)initWithPatcherFlags:(PatcherFlags *)o;
+ (PatcherFlags *)sharedInstance;
-(void)setShouldUseAPFSBooter:(BOOL)shouldUse;
-(void)setShouldAutoApplyPostInstall:(BOOL)shouldAutoApply;
-(BOOL)shouldUseAPFSBooter;
-(BOOL)shouldAutoApplyPostInstall;
-(void)saveToDirectory:(NSString *)path;
-(void)loadFromDirectory:(NSString *)path;

@end
