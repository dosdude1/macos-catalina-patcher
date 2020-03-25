//
//  MacOSDownloader.h
//  macOS High Sierra Patcher
//
//  Created by Collin Mistr on 8/21/17.
//  Copyright (c) 2017 dosdude1 Apps. All rights reserved.
//

#import <Cocoa/Cocoa.h>

//macOS 10.15
#define targetMinorVersion 15
#define targetBugfixVersion 3

typedef enum
{
    downloadError = 0,
    appError = 1,
    catalogError = 2,
    overwriteDecline = 3
}error;

typedef enum
{
    alertConfirmDownload=0
}downloadAlert;

@protocol DownloaderDelegate <NSObject>
@optional
-(void)updateProgressPercentage:(double)percent;
-(void)updateProgressSize:(NSString *)size;
-(void)updateProgressStatus:(NSString *)status;
-(void)setIndefiniteProgress:(BOOL)indefinite;
-(void)downloadDidFailWithError:(error)err;
-(void)shouldLoadApp:(BOOL)shouldLoad atPath:(NSString *)path;
@end

@interface MacOSDownloader : NSObject <NSURLConnectionDelegate, NSURLConnectionDataDelegate>
{
    NSDictionary *downloadSettings;
    NSString *catalogURL;
    NSString *savePath;
    NSString *downloadingURL;
    NSString *downloadPath;
    NSMutableArray *filesToDownload;
    NSFileHandle *downloadingFile;
    NSString *metadataURL;
    
    long dlSize;
    long dataLength;
    double percent;
    long totalDownloadSize;
    
    NSWindow *windowForAlertSheets;
}

@property (nonatomic, strong) id <DownloaderDelegate> delegate;
-(id)init;
-(void)startDownloadingToPath:(NSString *)path withWindowForAlertSheets:(NSWindow *)win;
-(void)cancelDownload;
@property (strong) NSURLConnection *urlConnection;

@end
