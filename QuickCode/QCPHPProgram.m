//
//  QCPHPProgram.m
//  QuickCode
//
//  Created by John Hobbs on 10/2/14.
//  Copyright (c) 2014 John Hobbs. All rights reserved.
//

#import "QCPHPProgram.h"

@implementation QCPHPProgram

+ (bool)isAvailable {
    return nil != [QCProgram pathToBinary:@"php"];
}

+ (ACEMode)highlightMode {
    return ACEModePHP;
}

- (bool)compile:(NSString *)code {
    NSString *sourceFileTemplate = [NSTemporaryDirectory() stringByAppendingPathComponent:@"quickcode.XXXXXX.php"];
    const char *sourceFileTemplateCString = [sourceFileTemplate fileSystemRepresentation];
    char *sourceFileNameCString = (char *)malloc(strlen(sourceFileTemplateCString) + 1);
    strcpy(sourceFileNameCString, sourceFileTemplateCString);
    int sourceFileDescriptor = mkstemps(sourceFileNameCString, 4);
    
    if (sourceFileDescriptor == -1) {
        [self.log error:@"Error creating temporary file."];
        return NO;
    }
    
    self.sourceFileName = [[NSFileManager defaultManager] stringWithFileSystemRepresentation:sourceFileNameCString length:strlen(sourceFileNameCString)];
    free(sourceFileNameCString);
    NSFileHandle *sourceFileHandle = [[NSFileHandle alloc] initWithFileDescriptor:sourceFileDescriptor closeOnDealloc:NO];
    [sourceFileHandle writeData:[code dataUsingEncoding:NSUTF8StringEncoding]];
    
    return YES;
}

- (bool)execute {
    NSPipe *outputPipe = [NSPipe pipe];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(readCompleted:) name:NSFileHandleReadToEndOfFileCompletionNotification object:[outputPipe fileHandleForReading]];
    
    [self.log debug:@"[QuickCode] Running..."];
    NSTask *task = [[NSTask alloc] init];
    [task setLaunchPath:@"/usr/bin/env"];
    [task setArguments:@[@"php", self.sourceFileName]];
    [task setStandardOutput:outputPipe];
    [task setStandardError:outputPipe];
    [[outputPipe fileHandleForReading] readToEndOfFileInBackgroundAndNotify];
    [task launch];
    [task waitUntilExit];
    
    return YES;
}

- (void)readCompleted:(NSNotification *)notification {
    NSString *lines = [[NSString alloc] initWithData:[[notification userInfo] objectForKey:NSFileHandleNotificationDataItem] encoding:NSUTF8StringEncoding];
    [self.log info:lines];
}

@end
