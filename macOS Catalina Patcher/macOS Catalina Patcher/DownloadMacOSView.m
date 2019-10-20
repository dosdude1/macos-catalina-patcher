//
//  DownloadMacOSView.m
//  macOS Catalina Patcher
//
//  Created by Collin Mistr on 6/22/19.
//  Copyright (c) 2019 dosdude1 Apps. All rights reserved.
//

#import "DownloadMacOSView.h"

@implementation DownloadMacOSView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        downloader = [[MacOSDownloader alloc] init];
        downloader.delegate = self;
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

- (IBAction)goBack:(id)sender {
    [self.delegate transitionToView:lastView withDirection:transitionDirectionLeft];
}
-(void)setUI {
    [self.startButton setHidden:YES];
    [self.backButton setHidden:YES];
    [self.downloadStatusLabel setHidden:NO];
    [self.progressIndicator setHidden:NO];
    [self.progressIndicator startAnimation:self];
    [self.cancelButton setHidden:NO];
}
-(void)resetUI {
    [self.startButton setHidden:NO];
    [self.backButton setHidden:NO];
    [self.downloadStatusLabel setHidden:YES];
    [self.sizeLabel setHidden:YES];
    [self.progressIndicator setHidden:YES];
    [self.progressIndicator stopAnimation:self];
    [self.cancelButton setHidden:YES];
}
- (IBAction)startDownloading:(id)sender {
    [self setUI];
    [self.progressIndicator setIndeterminate:YES];
    [self.progressIndicator startAnimation:self];
    [self.progressIndicator setMaxValue:100.0];
    [self.progressIndicator setMinValue:0.0];
    [self.progressIndicator setDoubleValue:0.0];
    downloadPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Downloads"];
    [downloader startDownloadingToPath:downloadPath withWindowForAlertSheets:self.window];
}
- (IBAction)cancelDownload:(id)sender {
    [self resetUI];
    [downloader cancelDownload];
}

-(void)updateProgressPercentage:(double)percent {
    [self.progressIndicator setDoubleValue:percent];
}
-(void)updateProgressSize:(NSString *)size {
    [self.sizeLabel setStringValue:size];
}
-(void)updateProgressStatus:(NSString *)status {
    [self.downloadStatusLabel setStringValue:status];
}
-(void)setIndefiniteProgress:(BOOL)indefinite {
    if (indefinite) {
        [self.sizeLabel setHidden:YES];
        [self.progressIndicator setIndeterminate:YES];
        [self.progressIndicator startAnimation:self];
    }
    else {
        [self.sizeLabel setHidden:NO];
        [self.progressIndicator setIndeterminate:NO];
        //[self.progressIndicator startAnimation:self];
    }
}
-(void)downloadDidFailWithError:(error)err {
    [self resetUI];
}
-(void)shouldLoadApp:(BOOL)shouldLoad atPath:(NSString *)path {
    /*[self.sizeLabel setHidden:YES];
    [self.progressIndicator setIndeterminate:NO];
    [self.progressIndicator setDoubleValue:[self.progressIndicator maxValue]];
    [self.startButton setHidden:NO];
    [self.backButton setHidden:NO];
    [self.cancelButton setHidden:YES];
    [self.downloadStatusLabel setStringValue:@"Complete!"];*/
    [self resetUI];
    if ([[CatalinaPatcherController sharedInstance] setInstallerAppPath:path withVerification:YES]) {
        [self.delegate transitionToView:viewIDPatchOptions withDirection:transitionDirectionRight];
    } else {
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setAlertStyle:NSCriticalAlertStyle];
        [alert setMessageText:@"App Verification Failed"];
        [alert setInformativeText:@"The downloaded Catalina installer app did not contain the necessary files needed for this tool. Please delete the copy of macOS that was downloaded, and try downloading a new copy."];
        [alert addButtonWithTitle:@"OK"];
        [alert beginSheetModalForWindow:self.window modalDelegate:nil didEndSelector:nil contextInfo:nil];
    }
}
@end
