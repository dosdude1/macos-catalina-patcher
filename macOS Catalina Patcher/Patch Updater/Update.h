//
//  Update.h
//  macOS Post Install
//
//  Created by Collin Mistr on 7/8/17.
//  Copyright (c) 2017 dosdude1 Apps. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STPrivilegedTask.h"


@protocol UpdateDelegate <NSObject>
@optional
-(void)updateDidFinishInstalling:(id)update withError:(int)err;
-(void)updateDidFinishUninstalling:(id)update withError:(int)err;
@end


typedef enum{
    actionInstall = 0,
    actionUninstall = 1
}action;

@interface Update : NSObject <NSURLConnectionDelegate>
{
    NSString *name;
    BOOL kextcacheRebuildRequired;
    NSString *size;
    NSInteger version;
    NSString *userVisiableName;
    NSString *description;
    NSString *URL;
    NSArray *supportedMachines;
    NSString *applicationSupportDirectory;
    action desiredAction;
    NSString *downloadingFile;
    NSFileHandle *downloadingFileHandle;
    NSDictionary *patchedFileSums;
    NSString *minSystemVersion;
}

@property (nonatomic, strong) id <UpdateDelegate> delegate;
-(id)init;
-(instancetype)initWithName:(NSString *)inName withUserVisiableName:(NSString *)inVisibleName withVersion:(NSInteger)inVer withDescription:(NSString *)inDescription withSize:(NSString *)inSize withURL:(NSString *)inURL withSupportedMachines:(NSArray *)inSupportedMachines kextcacheRebuildRequired:(BOOL)kextRebuild fileSumsDict:(NSDictionary *)fileSums withMinimumSystemVersion:(NSString *)minVersion;
-(NSString *)getSize;
-(NSInteger)getVersion;
-(NSString *)getName;
-(NSString *)getUserVisibleName;
-(NSString *)getDescription;
-(BOOL)isCompatibleWithThisMachine;
-(BOOL)isEqualTo:(Update *)u;
-(BOOL)isKextcacheRebuildRequired;
-(void)install;
-(BOOL)isPatchGood;


@end
