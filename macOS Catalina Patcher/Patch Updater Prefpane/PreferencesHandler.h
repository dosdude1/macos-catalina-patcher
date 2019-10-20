//
//  PreferencesHandler.h
//  macOS Post Install
//
//  Created by Collin Mistr on 7/9/17.
//  Copyright (c) 2017 dosdude1 Apps. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kShouldCheckUpdatesAutomatically "checkUpdatesAutomatically"
#define kUpdateDataURL "updateDataURL"
#define kShouldCheckPatchIntegrity "checkPatchIntegrity"

@interface PreferencesHandler : NSObject
{
    NSUserDefaults *standardUserDefaults;
}

+(PreferencesHandler *)sharedInstance;
-(void)setShouldCheckUpdatesAutomatically:(BOOL)shouldCheck;
-(BOOL)shouldCheckUpdatesAutomatically;
-(NSString *)getUpdateDataURL;
-(void)setUpdateDataURL:(NSString *)url;
-(BOOL)shouldCheckPatchIntegrity;
-(void)setShouldCheckPatchIntegrity:(BOOL)shouldCheck;


@end
