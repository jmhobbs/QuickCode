//
//  QCObjectiveC.m
//  QuickCode
//
//  Created by John Hobbs on 9/25/14.
//  Copyright (c) 2014 John Hobbs. All rights reserved.
//

#import "QCObjectiveCProgram.h"

@implementation QCObjectiveCProgram

+ (bool)isAvailable {
    return nil != [QCProgram pathToBinary:@"clang"];
}

- (bool)compile:(NSString *)code {
    NSString *sourceFileTemplate = [NSTemporaryDirectory() stringByAppendingPathComponent:@"quickcode.XXXXXX.m"];
    const char *sourceFileTemplateCString = [sourceFileTemplate fileSystemRepresentation];
    char *sourceFileNameCString = (char *)malloc(strlen(sourceFileTemplateCString) + 1);
    strcpy(sourceFileNameCString, sourceFileTemplateCString);
    int sourceFileDescriptor = mkstemps(sourceFileNameCString, 2);
    
    if (sourceFileDescriptor == -1) {
        [self.log error:@"Error creating temporary file."];
        return NO;
    }
    
    self.sourceFileName= [[NSFileManager defaultManager] stringWithFileSystemRepresentation:sourceFileNameCString length:strlen(sourceFileNameCString)];
    free(sourceFileNameCString);
    NSFileHandle *sourceFileHandle = [[NSFileHandle alloc] initWithFileDescriptor:sourceFileDescriptor closeOnDealloc:NO];
    [sourceFileHandle writeData:[code dataUsingEncoding:NSUTF8StringEncoding]];

    NSString *binaryFileTemplate = [NSTemporaryDirectory() stringByAppendingPathComponent:@"quickcode.XXXXXX"];
    const char *binaryFileTemplateCString = [binaryFileTemplate fileSystemRepresentation];
    char *binaryFileNameCString = (char *)malloc(strlen(binaryFileTemplateCString) + 1);
    strcpy(binaryFileNameCString, binaryFileTemplateCString);
    int binaryFileDescriptor = mkstemp(binaryFileNameCString);
    
    if (binaryFileDescriptor == -1)
    {
        [self.log error:@"Error creating temporary files."];
        return NO;
    }
    
    self.binaryFileName = [[NSFileManager defaultManager] stringWithFileSystemRepresentation:binaryFileNameCString length:strlen(binaryFileNameCString)];
    
    NSArray *arguments = @[@"-fobjc-arc", @"-framework", @"Foundation", self.sourceFileName, @"-o", self.binaryFileName];
    
    NSPipe *outputPipe = [NSPipe pipe];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(readCompleted:)
                                                 name:NSFileHandleReadToEndOfFileCompletionNotification
                                               object:[outputPipe fileHandleForReading]];

    [self.log debug:@"[QuickCode] Building..."];
    NSTask *task = [[NSTask alloc] init];
    [task setLaunchPath:[QCProgram pathToBinary:@"clang"]];
    [task setArguments:arguments];
    [task setStandardOutput:outputPipe];
    [task setStandardError:outputPipe];
    [task launch];
    [task waitUntilExit];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSFileHandleReadToEndOfFileCompletionNotification object:outputPipe];
    
    return YES;
}

- (bool)execute {
    
    NSPipe *outputPipe = [NSPipe pipe];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(readCompleted:) name:NSFileHandleReadToEndOfFileCompletionNotification object:[outputPipe fileHandleForReading]];
    
    [self.log debug:@"[QuickCode] Running..."];
    NSTask *task = [[NSTask alloc] init];
    [task setLaunchPath:self.binaryFileName];
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
