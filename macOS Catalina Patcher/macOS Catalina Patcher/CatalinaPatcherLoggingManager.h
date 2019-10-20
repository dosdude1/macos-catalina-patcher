//
//  CatalinaPatcherLoggingManager.h
//  macOS Catalina Patcher
//
//  Created by Collin Mistr on 7/22/19.
//  Copyright (c) 2019 dosdude1 Apps. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol CatalinaPatcherLoggingDelegate <NSObject>

-(void)logDidUpdateWithText:(NSString *)text;

@end

@interface CatalinaPatcherLoggingManager : NSObject
{
    NSString *log;
}
@property (strong) id <CatalinaPatcherLoggingDelegate> delegate;
-(id)init;
+ (CatalinaPatcherLoggingManager *)sharedInstance;
-(NSString *)getCurrentLogText;
-(void)updateLogWithText:(NSString *)text;
-(void)saveLogToPath:(NSString *)path;
-(void)resetLog;

@end
