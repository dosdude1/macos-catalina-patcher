//
//  MacOSDownloader.m
//  macOS High Sierra Patcher
//
//  Created by Collin Mistr on 8/21/17.
//  Copyright (c) 2017 dosdude1 Apps. All rights reserved.
//

#import "MacOSDownloader.h"

@interface MacOSDownloader ()

@end

@implementation MacOSDownloader

-(id)init {

    self = [super init];
    downloadSettings = [[NSDictionary alloc] initWithContentsOfFile:[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"DownloadSettings.plist"]];
    catalogURL = [downloadSettings objectForKey:@"CatalogURL"];
    metadataURL = [downloadSettings objectForKey:@"MetadataURL"];
    totalDownloadSize = 0;
    return self;
}



-(BOOL)macOSInstallerExistsAtPath:(NSString *)path {
    NSArray *files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:nil];
    for (NSString *file in files) {
        if ([file rangeOfString:@"Install macOS"].location != NSNotFound && ([file rangeOfString:@"Catalina"].location != NSNotFound || [file rangeOfString:@"10.15"].location != NSNotFound)) {
            return YES;
        }
    }
    return NO;
}
-(void)startDownloadingToPath:(NSString *)path withWindowForAlertSheets:(NSWindow *)win {
    windowForAlertSheets = win;
    totalDownloadSize = 0;
    dataLength = 0;
    savePath = path;
    if ([self macOSInstallerExistsAtPath:savePath]) {
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:@"Installer Exists"];
        [alert setInformativeText:@"A macOS Installer already exists in this location. Are you sure you want to overwrite it?"];
        [alert addButtonWithTitle:@"Yes"];
        [alert addButtonWithTitle:@"Cancel"];
        if ([alert runModal] == NSAlertFirstButtonReturn) {
            downloadPath = [savePath stringByAppendingPathComponent:@"macOSDownload"];
            [[NSFileManager defaultManager] createDirectoryAtPath:downloadPath withIntermediateDirectories:YES attributes:nil error:nil];
            [self downloadFileAtURL:catalogURL fromSize:0];
        }
        else {
            [self.delegate downloadDidFailWithError:overwriteDecline];
        }
    }
    else {
        downloadPath = [savePath stringByAppendingPathComponent:@"macOSDownload"];
        if ([[NSFileManager defaultManager] fileExistsAtPath:downloadPath]) {
            [[NSFileManager defaultManager] removeItemAtPath:[downloadPath stringByAppendingPathComponent:[catalogURL lastPathComponent]] error:nil];
            if (metadataURL) {
                [[NSFileManager defaultManager] removeItemAtPath:[downloadPath stringByAppendingPathComponent:[metadataURL lastPathComponent]] error:nil];
            }
        }
        else {
            [[NSFileManager defaultManager] createDirectoryAtPath:downloadPath withIntermediateDirectories:YES attributes:nil error:nil];
        }
        [self downloadFileAtURL:catalogURL fromSize:0];
    }
}

-(void)downloadFileAtURL:(NSString *)fileURL fromSize:(long)bytesToStart {
    downloadingURL = fileURL;
    [self.delegate updateProgressStatus:[NSString stringWithFormat:@"Downloading %@...", [downloadingURL lastPathComponent]]];
    
    NSURL* url = [NSURL URLWithString:fileURL];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:60];
    NSString *range = [NSString stringWithFormat:@"bytes=%ld-", bytesToStart];
    [request setValue:range forHTTPHeaderField:@"Range"];
    self.urlConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES];
}
- (void)connection: (NSURLConnection*) connection didReceiveResponse:(NSURLResponse *)response {
    dlSize = [response expectedContentLength];
    if (![[NSFileManager defaultManager] fileExistsAtPath:[downloadPath stringByAppendingPathComponent:[downloadingURL lastPathComponent]]]) {
        [[NSFileManager defaultManager] createFileAtPath:[downloadPath stringByAppendingPathComponent:[downloadingURL lastPathComponent]] contents:nil attributes:nil];
    }
    downloadingFile = [NSFileHandle fileHandleForUpdatingAtPath:[downloadPath stringByAppendingPathComponent:[downloadingURL lastPathComponent]]];
    [downloadingFile seekToEndOfFile];
}
- (void) connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    dataLength += data.length;
    dlSize -= data.length;
    percent = ((100.0/totalDownloadSize)*dataLength);
    [self.delegate updateProgressPercentage:percent];
    [downloadingFile writeData:data];
    NSString *sizeString = [NSString stringWithFormat:@"%.1f/%.1f MB", dataLength/100000*.1, totalDownloadSize/100000*.1];
    [self.delegate updateProgressSize:sizeString];
}
- (void) connectionDidFinishLoading:(NSURLConnection *)connection {
    [downloadingFile closeFile];
    if ([[downloadingURL lastPathComponent] isEqualToString:[catalogURL lastPathComponent]]) {
        if (metadataURL) {
            [self downloadFileAtURL:metadataURL fromSize:0];
        }
        else {
            [self loadSWUCatalog];
        }
    }
    else if ([[downloadingURL lastPathComponent] isEqualToString:[metadataURL lastPathComponent]]) {
        [self loadSWUCatalog];
    }
    else {
        if (filesToDownload.count == 1) {
            [filesToDownload removeObjectAtIndex:0];
            [self performSelectorInBackground:@selector(setupApp) withObject:nil];
        }
        else {
            [filesToDownload removeObjectAtIndex:0];
            [self downloadFileAtURL:[[filesToDownload objectAtIndex:0] objectForKey:@"URL"] fromSize:[[[filesToDownload objectAtIndex:0] objectForKey:@"startBytes"] longValue]];
        }
    }
}
-(void)loadSWUCatalog {
    NSDictionary *downloadMetadata = [[NSDictionary alloc] initWithContentsOfFile:[downloadPath stringByAppendingPathComponent:[metadataURL lastPathComponent]]];
    NSDictionary *updateCatalog = [[NSDictionary alloc] initWithContentsOfFile:[downloadPath stringByAppendingPathComponent:[catalogURL lastPathComponent]]];
    if ([updateCatalog count] < 1) {
        NSTask *gunzip = [[NSTask alloc] init];
        [gunzip setLaunchPath:@"/usr/bin/gunzip"];
        [gunzip setArguments:@[[downloadPath stringByAppendingPathComponent:[catalogURL lastPathComponent]]]];
        [gunzip launch];
        [gunzip waitUntilExit];
        updateCatalog = [[NSDictionary alloc] initWithContentsOfFile:[downloadPath stringByAppendingPathComponent:[[catalogURL lastPathComponent] stringByDeletingPathExtension]]];
    }
    NSDictionary *products = [updateCatalog objectForKey:@"Products"];
    NSString *downloadKey = @"";
    if (![downloadMetadata objectForKey:@"DownloadKey"]) {
        downloadKey = [self locateOSDownloadKeyInProductDict:products];
    }
    else {
        downloadKey = [downloadMetadata objectForKey:@"DownloadKey"];
    }
    if ([downloadKey isEqualToString:@""]) {
        [self handleError:catalogError];
    }
    else {
        NSArray *packages = [[products objectForKey:downloadKey] objectForKey:@"Packages"];
        if (!packages) {
            packages = [[products objectForKey:[self locateOSDownloadKeyInProductDict:products]] objectForKey:@"Packages"];
        }
        filesToDownload = [[NSMutableArray alloc] init];
        for (NSDictionary *d in packages) {
            long fileSize = [[d objectForKey:@"Size"] longValue];
            NSString *fileName = [[d objectForKey:@"URL"] lastPathComponent];
            if ([[NSFileManager defaultManager] fileExistsAtPath:[downloadPath stringByAppendingPathComponent:fileName]]) {
                long currentFileSize = [[[NSFileManager defaultManager] attributesOfItemAtPath:[downloadPath stringByAppendingPathComponent:fileName] error:nil] fileSize];
                dataLength += currentFileSize;
                if (currentFileSize < fileSize) {
                    [filesToDownload addObject:@{@"URL": [d objectForKey:@"URL"], @"startBytes":[NSNumber numberWithLong:currentFileSize]}];
                }
            }
            else {
                [filesToDownload addObject:@{@"URL": [d objectForKey:@"URL"], @"startBytes":[NSNumber numberWithLong:0]}];
            }
            totalDownloadSize += fileSize;
        }
        
        [self.delegate setIndefiniteProgress:NO];
        [self downloadFileAtURL:[[filesToDownload objectAtIndex:0] objectForKey:@"URL"] fromSize:[[[filesToDownload objectAtIndex:0] objectForKey:@"startBytes"] longValue]];
    }
}
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    [self handleError:downloadError];
}
-(NSString *)locateOSDownloadKeyInProductDict:(NSDictionary *)products {
    NSArray *allKeys = products.allKeys;
    NSDate *latestDate;
    NSString *foundKey = @"";
    
    for (long i=allKeys.count - 1; i > 0; i--) {
        NSString *key = [allKeys objectAtIndex:i];
        if ([[products objectForKey:key] objectForKey:@"ServerMetadataURL"] != nil && [[[products objectForKey:key] objectForKey:@"ServerMetadataURL"] rangeOfString:@"InstallAssistantAuto"].location != NSNotFound) {
            NSURL *ServerMetadataURL = [NSURL URLWithString:[[products objectForKey:key] objectForKey:@"ServerMetadataURL"]];
            NSDate *postDate = [[products objectForKey:key] objectForKey:@"PostDate"];
            NSDictionary *metadata = [[NSDictionary alloc] initWithContentsOfURL:ServerMetadataURL];
            NSString *systemVersion = [metadata objectForKey:@"CFBundleShortVersionString"];
            NSArray *ver = [systemVersion componentsSeparatedByString:@"."];
            int minor = 0;
            if (ver.count >= 2) {
                minor = [[ver objectAtIndex:1] intValue];
                if (minor == targetMinorVersion) {
                    if (!latestDate || [latestDate isLessThan:postDate]) {
                        latestDate = postDate;
                        foundKey = key;
                    }
                }
            }
        }
    }
    return foundKey;
}
-(void)setupApp {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.delegate setIndefiniteProgress:YES];
        [self.delegate updateProgressStatus:@"Preparing Installer Application..."];
    });
    
    for (NSString *file in [[NSFileManager defaultManager] contentsOfDirectoryAtPath:savePath error:nil]) {
        if ([file rangeOfString:@"Install macOS"].location != NSNotFound && ([file rangeOfString:@"Catalina"].location != NSNotFound || [file rangeOfString:@"10.15"].location != NSNotFound) && [file rangeOfString:@".app"].location != NSNotFound) {
            [[NSFileManager defaultManager] removeItemAtPath:[savePath stringByAppendingPathComponent:file] error:nil];
        }
    }
    NSTask *extractPKG = [[NSTask alloc] init];
    [extractPKG setLaunchPath: @"/bin/bash"];
    [extractPKG setArguments: @[ @"-c", [NSString stringWithFormat:@"\"%@\" \"%@\" | cpio -i" , [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"pbzx"], [downloadPath stringByAppendingPathComponent:@"InstallAssistantAuto.pkg"]]]];
    [extractPKG setCurrentDirectoryPath:savePath];
    [extractPKG launch];
    [extractPKG waitUntilExit];
    NSString *installerFile=@"";
    for (NSString *file in [[NSFileManager defaultManager] contentsOfDirectoryAtPath:savePath error:nil]) {
        if ([file rangeOfString:@"Install macOS"].location != NSNotFound && ([file rangeOfString:@"Catalina"].location != NSNotFound || [file rangeOfString:@"10.15"].location != NSNotFound) && [file rangeOfString:@".app"].location != NSNotFound) {
            installerFile = file;
        }
    }
    if ([installerFile isEqualToString:@""]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self handleError:appError];
        });
    }
    else {
        [[NSFileManager defaultManager] moveItemAtPath:[downloadPath stringByAppendingPathComponent:@"RecoveryHDMetaDmg.pkg"] toPath:[downloadPath stringByAppendingPathComponent:@"RecoveryHDMeta.dmg"] error:nil];
        NSString *recoveryHDMetaMount = [downloadPath stringByAppendingPathComponent:@"RecHDMeta"];
        [[NSFileManager defaultManager] createDirectoryAtPath:recoveryHDMetaMount withIntermediateDirectories:YES attributes:nil error:nil];
        NSTask *mount = [[NSTask alloc] init];
        [mount setLaunchPath:@"/usr/bin/hdiutil"];
        NSArray *mountArgs = [[NSArray alloc] initWithObjects:@"attach", [downloadPath stringByAppendingPathComponent:@"RecoveryHDMeta.dmg"], @"-noverify", @"-nobrowse", @"-mountpoint", recoveryHDMetaMount, nil];
        [mount setArguments:mountArgs];
        [mount launch];
        [mount waitUntilExit];
        NSString *sharedSupportPath = [savePath stringByAppendingPathComponent:[installerFile stringByAppendingPathComponent:@"Contents/SharedSupport"]];
        NSTask *prepareApp = [[NSTask alloc] init];
        [prepareApp setLaunchPath:[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"PrepareInstallerApp.sh"]];
        [prepareApp setArguments:[NSArray arrayWithObjects:downloadPath, sharedSupportPath, recoveryHDMetaMount, nil]];
        [prepareApp launch];
        [prepareApp waitUntilExit];
        NSTask *unmount = [[NSTask alloc] init];
        [unmount setLaunchPath:@"/usr/bin/hdiutil"];
        NSArray *unmountArgs = [[NSArray alloc] initWithObjects:@"detach", recoveryHDMetaMount, nil];
        [unmount setArguments:unmountArgs];
        [unmount launch];
        [unmount waitUntilExit];
        [[NSFileManager defaultManager] removeItemAtPath:downloadPath error:nil];

        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate shouldLoadApp:YES atPath:[savePath stringByAppendingPathComponent:installerFile]];
        });
    }
}
-(void)handleError:(error)err {
    [self.delegate downloadDidFailWithError:err];
    NSAlert *alert = [[NSAlert alloc] init];
    [alert setAlertStyle:NSCriticalAlertStyle];
    switch (err) {
        case downloadError:
            [alert setMessageText:@"Error"];
            [alert setInformativeText:@"An error occurred while downloading macOS. Please check your Internet connection and try again."];
            [alert addButtonWithTitle:@"OK"];
            break;
        case appError:
            [alert setMessageText:@"Error"];
            [alert setInformativeText:@"An error occurred while preparing the macOS Installer app."];
            [alert addButtonWithTitle:@"OK"];
            break;
        case catalogError:
            [alert setMessageText:@"Error"];
            [alert setInformativeText:@"Could not locate the correct entry in the CatalogURL. Cannot continue."];
            [alert addButtonWithTitle:@"OK"];
            break;
        default:
            break;
    }
    if (windowForAlertSheets) {
        [alert beginSheetModalForWindow:windowForAlertSheets modalDelegate:nil didEndSelector:nil contextInfo:nil];
    }
    else {
        [alert runModal];
    }
}
-(void)cancelDownload {
    [self.urlConnection cancel];
}
@end
