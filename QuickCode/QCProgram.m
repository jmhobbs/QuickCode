//
//  QCLanguage.m
//  QuickCode
//
//  Created by John Hobbs on 9/25/14.
//  Copyright (c) 2014 John Hobbs. All rights reserved.
//

#import "QCProgram.h"

@implementation QCProgram

+ (NSString *)pathToBinary:(NSString *)binaryName {
    NSDictionary *environmentDict = [[NSProcessInfo processInfo] environment];
    NSString *shellString = [environmentDict objectForKey:@"SHELL"];
    
    NSPipe *pipe = [[NSPipe alloc] init];
    NSTask *task = [[NSTask alloc] init];
    [task setStandardOutput:pipe];
    [task setLaunchPath:shellString];
    [task setArguments:[NSArray arrayWithObjects:@"-l", @"-c", [NSString stringWithFormat:@"which %@", binaryName], nil]];
    [task launch];
    [task waitUntilExit];
    
    return [[[NSString alloc] initWithData:[[pipe fileHandleForReading] readDataToEndOfFile] encoding:NSUTF8StringEncoding] stringByReplacingOccurrencesOfString:@"\n" withString:@""];
}

- (id)initWithLog:(QCLogView *)log {
    self = [self init];
    if(self) {
        self.log = log;
    }
    return self;
}

+ (bool)isAvailable {
    return NO;
}

- (bool)compile:(NSString *)code {
    [[NSException exceptionWithName:@"NotImplementedError" reason:@"Method not implemented." userInfo:nil] raise];
    return NO;
}

- (bool)execute {
    [[NSException exceptionWithName:@"NotImplementedError" reason:@"Method not implemented." userInfo:nil] raise];
    return NO;
}

@end
