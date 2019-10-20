//
//  AnalyticsManager.m
//  macOS Catalina Patcher
//
//  Created by Collin Mistr on 7/30/19.
//  Copyright (c) 2019 dosdude1 Apps. All rights reserved.
//

#import "AnalyticsManager.h"

@implementation AnalyticsManager

-(id)init {
    self = [super init];
    return self;
}
+ (AnalyticsManager *)sharedInstance {
    static AnalyticsManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

-(void)postAnalyticsOfPatcherMode:(int)mode usingInstallerAppVersion:(NSString *)version withError:(int)err {
    NSString *errNum = [NSString stringWithFormat:@"%d", err];
    NSString *patcherMode = [NSString stringWithFormat:@"%d", mode];
    NSString *macModel = [self getMachineModel];
    NSString *systemVersion = [self getCurrentSystemVersion];
    NSString *sysID = [self getHashOfString:[self getSystemUUID]];
    NSString *log = [[CatalinaPatcherLoggingManager sharedInstance] getCurrentLogText];
    NSString *patcherVersion = [self getAppVersion];
    
    NSString *post = [NSString stringWithFormat:@"key=%@&id=%@&error=%@&mode=%@&model=%@&sysver=%@&appver=%@&installerver=%@&log=%@", @AnalyticsKey, sysID, errNum, patcherMode, macModel, systemVersion, patcherVersion, version, log];
    NSData *postData = [post dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    NSString *postLength = [NSString stringWithFormat:@"%lu",[postData length]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:@AnalyticsURL]];
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody:postData];
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    [conn start];
}
-(NSString *)getMachineModel {
    NSString *macModel=@"";
    size_t len=0;
    sysctlbyname("hw.model", nil, &len, nil, 0);
    if (len)
    {
        char *model = malloc(len*sizeof(char));
        sysctlbyname("hw.model", model, &len, nil, 0);
        macModel=[NSString stringWithFormat:@"%s", model];
        free(model);
    }
    return macModel;
}
-(NSString *)getCurrentSystemVersion {
    NSDictionary *systemVersion = [[NSDictionary alloc] initWithContentsOfFile:@"/System/Library/CoreServices/SystemVersion.plist"];
    return [systemVersion objectForKey:@"ProductVersion"];
}
- (NSString *)getSystemUUID {
    io_service_t platformExpert = IOServiceGetMatchingService(kIOMasterPortDefault,IOServiceMatching("IOPlatformExpertDevice"));
    if (!platformExpert)
        return nil;
    
    CFTypeRef serialNumberAsCFString = IORegistryEntryCreateCFProperty(platformExpert,CFSTR(kIOPlatformUUIDKey),kCFAllocatorDefault, 0);
    if (!serialNumberAsCFString)
        return nil;
    
    IOObjectRelease(platformExpert);
    return (__bridge NSString *)(serialNumberAsCFString);
}
-(NSString *)getHashOfString:(NSString *)string
{
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    uint8_t digest[CC_SHA1_DIGEST_LENGTH];
    CC_SHA1(data.bytes, (CC_LONG)data.length, digest);
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];
    for (int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++) {
        [output appendFormat:@"%02x", digest[i]];
    }
    return output;
}
-(NSString *)getAppVersion {
    NSDictionary *info = [[NSDictionary alloc] initWithContentsOfFile:[[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"Contents/Info.plist"]];
    return [info objectForKey:@"CFBundleShortVersionString"];
}
@end
