//
//  PatcherFlags.m
//  macOS Catalina Patcher
//
//  Created by Collin Mistr on 8/20/19.
//  Copyright (c) 2019 dosdude1 Apps. All rights reserved.
//

#import "PatcherFlags.h"

@implementation PatcherFlags

-(id)init {
    self = [super init];
    shouldUseAPFSBooter = YES;
    shouldAutoApplyPostInstall = YES;
    return self;
}
-(id)initWithPatcherFlags:(PatcherFlags *)o {
    self = [self init];
    shouldUseAPFSBooter = [o shouldUseAPFSBooter];
    shouldAutoApplyPostInstall = [o shouldAutoApplyPostInstall];
    return self;
}
+ (PatcherFlags *)sharedInstance {
    static PatcherFlags *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}
-(void)setShouldUseAPFSBooter:(BOOL)shouldUse {
    shouldUseAPFSBooter = shouldUse;
}
-(void)setShouldAutoApplyPostInstall:(BOOL)shouldAutoApply {
    shouldAutoApplyPostInstall = shouldAutoApply;
}
-(BOOL)shouldUseAPFSBooter {
    return shouldUseAPFSBooter;
}
-(BOOL)shouldAutoApplyPostInstall {
    return shouldAutoApplyPostInstall;
}
-(void)saveToDirectory:(NSString *)path {
    NSDictionary *flags = [[NSDictionary alloc] initWithObjects:@[[NSNumber numberWithBool:shouldUseAPFSBooter], [NSNumber numberWithBool:shouldAutoApplyPostInstall]] forKeys:@[@kShouldUseAPFSBooter, @kShouldAutoApplyPostInstall]];
    [flags writeToFile:[path stringByAppendingPathComponent:@PatcherFlagsFile] atomically:YES];
}
-(void)loadFromDirectory:(NSString *)path {
    NSDictionary *flags = [[NSDictionary alloc] initWithContentsOfFile:[path stringByAppendingPathComponent:@PatcherFlagsFile]];
    if (flags) {
        shouldUseAPFSBooter = [[flags objectForKey:@kShouldUseAPFSBooter] boolValue];
        shouldAutoApplyPostInstall = [[flags objectForKey:@kShouldAutoApplyPostInstall] boolValue];
    }
}
@end
