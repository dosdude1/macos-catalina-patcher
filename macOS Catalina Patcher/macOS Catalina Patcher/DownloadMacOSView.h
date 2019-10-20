//
//  DownloadMacOSView.h
//  macOS Catalina Patcher
//
//  Created by Collin Mistr on 6/22/19.
//  Copyright (c) 2019 dosdude1 Apps. All rights reserved.
//

#import "WizardView.h"
#import "MacOSDownloader.h"

@interface DownloadMacOSView : WizardView <DownloaderDelegate>
{
    NSString *downloadPath;
    MacOSDownloader *downloader;
}
- (IBAction)goBack:(id)sender;
- (IBAction)startDownloading:(id)sender;
@property (strong) IBOutlet NSButton *backButton;
@property (strong) IBOutlet NSButton *startButton;
@property (strong) IBOutlet NSTextField *downloadStatusLabel;
@property (strong) IBOutlet NSProgressIndicator *progressIndicator;
@property (strong) IBOutlet NSTextField *sizeLabel;
@property (strong) IBOutlet NSButton *cancelButton;
- (IBAction)cancelDownload:(id)sender;


@end
