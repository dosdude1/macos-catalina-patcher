//
//  PreferencesHandler.m
//  macOS Post Install
//
//  Created by Collin Mistr on 7/9/17.
//  Copyright (c) 2017 dosdude1 Apps. All rights reserved.
//

#import "PreferencesHandler.h"

@implementation PreferencesHandler

-(id)init
{
    self=[super init];
    standardUserDefaults = [NSUserDefaults standardUserDefaults];
    return self;
}
+(PreferencesHandler *)sharedInstance
{
    static dispatch_once_t pred = 0;
    __strong static PreferencesHandler *sharedObject = nil;
    dispatch_once(&pred, ^{
        sharedObject = [[self alloc] init];
    });
    return sharedObject;
}
-(void)setShouldCheckUpdatesAutomatically:(BOOL)shouldCheck
{
	if (standardUserDefaults)
    {
		[standardUserDefaults setBool:shouldCheck forKey:@kShouldCheckUpdatesAutomatically];
		[standardUserDefaults synchronize];
	}
}
-(BOOL)shouldCheckUpdatesAutomatically
{
    if ([[[standardUserDefaults dictionaryRepresentation] allKeys] containsObject:@kShouldCheckUpdatesAutomatically])
    {
        return [standardUserDefaults boolForKey:@kShouldCheckUpdatesAutomatically];
    }
    return YES;
}
-(NSString *)getUpdateDataURL
{
    if ([[[standardUserDefaults dictionaryRepresentation] allKeys] containsObject:@kUpdateDataURL])
    {
        return [standardUserDefaults objectForKey:@kUpdateDataURL];
    }
    return nil;
}
-(void)setUpdateDataURL:(NSString *)url
{
    if (standardUserDefaults)
    {
		[standardUserDefaults setObject:url forKey:@kUpdateDataURL];
		[standardUserDefaults synchronize];
	}
}
-(BOOL)shouldCheckPatchIntegrity
{
    if ([[[standardUserDefaults dictionaryRepresentation] allKeys] containsObject:@kShouldCheckPatchIntegrity])
    {
        return [standardUserDefaults boolForKey:@kShouldCheckPatchIntegrity];
    }
    return YES;
}
-(void)setShouldCheckPatchIntegrity:(BOOL)shouldCheck
{
    if (standardUserDefaults)
    {
		[standardUserDefaults setBool:shouldCheck forKey:@kShouldCheckPatchIntegrity];
		[standardUserDefaults synchronize];
	}
}
@end
