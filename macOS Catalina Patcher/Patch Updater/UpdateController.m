//
//  UpdateController.m
//  macOS Post Install
//
//  Created by Collin Mistr on 7/7/17.
//  Copyright (c) 2017 dosdude1 Apps. All rights reserved.
//

#import "UpdateController.h"


@implementation UpdateController


-(id)init
{
    self=[super init];
    kextcacheRebuildRequired = NO;
    installedPatches = [[NSDictionary alloc] initWithContentsOfFile:@"/Library/Application Support/macOS Catalina Patcher/installedPatches.plist"];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    applicationSupportDirectory = [[paths firstObject] stringByAppendingPathComponent:@"macOS Catalina Patcher"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:applicationSupportDirectory])
    {
        [[NSFileManager defaultManager] createDirectoryAtPath:applicationSupportDirectory withIntermediateDirectories:YES attributes:nil error:nil];
    }
    settings = [[NSDictionary alloc] initWithContentsOfFile:[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"settings.plist"]];
    [[PreferencesHandler sharedInstance] setUpdateDataURL:[settings objectForKey:@"updateDataURL"]];
    return self;
}

+(UpdateController *)sharedInstance
{
    static dispatch_once_t pred = 0;
    __strong static UpdateController *sharedObject = nil;
    dispatch_once(&pred, ^{
        sharedObject = [[self alloc] init];
    });
    return sharedObject;
}
-(void)updateData
{
    connectionNum = connectionDownloadMetadata;
    NSURL* url = [NSURL URLWithString:[[PreferencesHandler sharedInstance] getUpdateDataURL]];
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:60];
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:NO];
    [connection start];
}
-(NSArray *)getAvailableUpdates
{
    NSMutableArray *updates = [[NSMutableArray alloc] init];
    for (Update *u in availableUpdates)
    {
        BOOL added=NO;
        if ([installedPatches objectForKey:[u getName]])
        {
            added=YES;
            if ([u getVersion] > [[[installedPatches objectForKey:[u getName]] objectForKey:@"version"] intValue])
            {
                [updates addObject:u];
            }
        }
        if (!added && [u isCompatibleWithThisMachine])
        {
            [updates addObject:u];
        }
    }
    return updates;
}
- (void)connection: (NSURLConnection*) connection didReceiveResponse: (NSHTTPURLResponse*) response
{
    receivedData = [[NSMutableData alloc] initWithLength:0];
    dlSize = [response expectedContentLength];
}
- (void) connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [receivedData appendData:data];
}
- (void) connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSString *localFile=@"";
    switch (connectionNum)
    {
        case connectionDownloadMetadata:
            localFile = [applicationSupportDirectory stringByAppendingPathComponent:@"updates.plist"];
            [receivedData writeToFile:localFile atomically:YES];
            availableUpdates = [[NSMutableArray alloc] init];
            [self loadUpdatesFromData:[[NSArray alloc] initWithContentsOfFile:[applicationSupportDirectory stringByAppendingPathComponent:@"updates.plist"]]];
            [[NSFileManager defaultManager] removeItemAtPath:[applicationSupportDirectory stringByAppendingPathComponent:@"updates.plist"] error:nil];
            [self.delegate didRecieveUpdateData:[self getAvailableUpdates]];
            break;
    }
}
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    [self.delegate connectionErrorOccurred];
}
-(void)loadUpdatesFromData:(NSArray *)updatesTemp
{
    for (NSDictionary *update in updatesTemp)
    {
        Update *obj = [[Update alloc] initWithName:[update objectForKey:@"patchName"] withUserVisiableName:[update objectForKey:@"userVisibleName"] withVersion:[[update objectForKey:@"version"] integerValue] withDescription:[update objectForKey:@"description"] withSize:[update objectForKey:@"size"] withURL:[update objectForKey:@"patchURL"] withSupportedMachines:[update objectForKey:@"supportedMachines"] kextcacheRebuildRequired:[[update objectForKey:@"kextcacheRebuildRequired"] boolValue] fileSumsDict:[update objectForKey:@"patchedFileSums"] withMinimumSystemVersion:[update objectForKey:@"minSystemVersion"]];
        obj.delegate=self;
        [availableUpdates addObject:obj];
    }
}
-(void)updateDidFinishInstalling:(id)update withError:(int)err
{
    [self.delegate updateDidFinishInstalling:update withError:err];
    if (err == 0)
    {
        [updatesToInstall removeObjectAtIndex:0];
        if (updatesToInstall.count > 0)
        {
            [self.delegate willInstallUpdate:[updatesToInstall objectAtIndex:0]];
            if ([[updatesToInstall objectAtIndex:0] isKextcacheRebuildRequired])
            {
                kextcacheRebuildRequired=YES;
            }
            [installationReceipt setObject:[NSDictionary dictionaryWithObject:[NSNumber numberWithInteger:[[updatesToInstall objectAtIndex:0] getVersion]] forKey:@"version"] forKey:[[updatesToInstall objectAtIndex:0] getName]];
            [[updatesToInstall objectAtIndex:0] install];
        }
        else
        {
            [installationReceipt writeToFile:[applicationSupportDirectory stringByAppendingPathComponent:@"installedPatches.plist"] atomically:YES];
            if (![[NSFileManager defaultManager] fileExistsAtPath:@"/Library/Application Support/macOS Catalina Patcher"])
            {
                STPrivilegedTask *md = [[STPrivilegedTask alloc] init];
                [md setLaunchPath:@"/bin/mkdir"];
                [md setArguments:[NSArray arrayWithObjects:@"/Library/Application Support/macOS Catalina Patcher", nil]];
                [md launch];
                [md waitUntilExit];
            }
            if ([[NSFileManager defaultManager] fileExistsAtPath:@"/Library/Application Support/macOS Catalina Patcher/installedPatches.plist"])
            {
                STPrivilegedTask *chmod = [[STPrivilegedTask alloc] init];
                [chmod setLaunchPath:@"/bin/chmod"];
                [chmod setArguments:[NSArray arrayWithObjects:@"777", @"/Library/Application Support/macOS Catalina Patcher/installedPatches.plist", nil]];
                [chmod launch];
                [chmod waitUntilExit];
            }
            STPrivilegedTask *moveReceipt = [[STPrivilegedTask alloc] init];
            [moveReceipt setLaunchPath:@"/bin/mv"];
            [moveReceipt setArguments:[NSArray arrayWithObjects:[applicationSupportDirectory stringByAppendingPathComponent:@"installedPatches.plist"], @"/Library/Application Support/macOS Catalina Patcher/installedPatches.plist", nil]];
            [moveReceipt launch];
            [moveReceipt waitUntilExit];
            [self.delegate installedUpdatesNeedKextcacheRebuild:kextcacheRebuildRequired];
        }
    }
}
-(void)installUpdates:(NSArray *)updates
{
    installationReceipt = [[NSMutableDictionary alloc] initWithDictionary:installedPatches];
    updatesToInstall = [[NSMutableArray alloc] initWithArray:updates];
    if (updatesToInstall.count > 0)
    {
        STPrivilegedTask *mountRW = [[STPrivilegedTask alloc] init];
        [mountRW setArguments:@[@"-uw", @"/"]];
        [mountRW setLaunchPath:@"/sbin/mount"];
        int err = [mountRW launch];
        if (err) {
            [self.delegate updateDidFinishInstalling:[updatesToInstall objectAtIndex:0] withError:err];
        }
        else {
            [mountRW waitUntilExit];
            [self.delegate willInstallUpdate:[updatesToInstall objectAtIndex:0]];
            if ([[updatesToInstall objectAtIndex:0] isKextcacheRebuildRequired])
            {
                kextcacheRebuildRequired=YES;
            }
            [installationReceipt setObject:[NSDictionary dictionaryWithObject:[NSNumber numberWithInteger:[[updatesToInstall objectAtIndex:0] getVersion]] forKey:@"version"] forKey:[[updatesToInstall objectAtIndex:0] getName]];
            [[updatesToInstall objectAtIndex:0] install];
        }
    }
    else
    {
        [self.delegate installedUpdatesNeedKextcacheRebuild:kextcacheRebuildRequired];
    }
}
-(void)rebuildKextcache
{
    STPrivilegedTask *systemCacheRebuild = [[STPrivilegedTask alloc] init];
    [systemCacheRebuild setLaunchPath:@"/usr/sbin/kextcache"];
    [systemCacheRebuild setArguments:[NSArray arrayWithObject:@"-system-caches"]];
    [systemCacheRebuild launch];
    [systemCacheRebuild waitUntilExit];
    STPrivilegedTask *prelinkedKernelRebuild = [[STPrivilegedTask alloc] init];
    [prelinkedKernelRebuild setLaunchPath:@"/usr/sbin/kextcache"];
    [prelinkedKernelRebuild setArguments:[NSArray arrayWithObject:@"-system-prelinked-kernel"]];
    [prelinkedKernelRebuild launch];
    [prelinkedKernelRebuild waitUntilExit];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.delegate kextcacheRebuildComplete];
    });
}
-(NSDictionary *)getInstalledPatches
{
    return installedPatches;
}
-(NSArray *)getAllUpdates
{
    return availableUpdates;
}
-(NSArray *)checkPatchIntegrityOfInstalledPatches
{
    NSMutableArray *failedPatches = [[NSMutableArray alloc] init];
    for (Update *u in availableUpdates)
    {
        if ([installedPatches objectForKey:[u getName]])
        {
            if (![u isPatchGood])
            {
                [failedPatches addObject:u];
            }
        }
    }
    return failedPatches;
}
@end
