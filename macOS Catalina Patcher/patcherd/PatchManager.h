//
//  PatchManager.h
//  macOS Catalina Patcher
//
//  Created by Collin Mistr on 8/3/19.
//  Copyright (c) 2019 dosdude1 Apps. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LoggingManager.h"

@interface PatchManager : NSObject

-(id)init;
-(int)copyFile:(NSString *)filePath toDirectory:(NSString *)dirPath;
-(int)setPermsOnFile:(NSString *)path;

@end
