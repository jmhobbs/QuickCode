//
//  QCAppDelegate.m
//  QuickCode
//
//  Created by John Hobbs on 9/25/14.
//  Copyright (c) 2014 John Hobbs. All rights reserved.
//

#import "QCAppDelegate.h"
#import "ACEView/ACEModeNames.h"
#import "ACEView/ACEThemeNames.h"

@implementation QCAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{    
    NSBundle *mainBundle = [NSBundle mainBundle];
    NSString *source = [mainBundle pathForResource:@"Objective-C" ofType:@"src"];
    
    NSError *error;
    NSString *src = [NSString stringWithContentsOfFile:source encoding:NSUTF8StringEncoding error:&error];
    
    // Note that you'll likely be using local text
    [self.input setString:src];
    [self.input setDelegate:self];
    [self.input setMode:ACEModeCPP];
    [self.input setTheme:ACEThemeMonokai];
    
    [self.output setEditable:NO];
    [[self.output textStorage] setFont:[NSFont fontWithName:@"Menlo" size:14]];
    
    [self.languageSelect setEditable:NO];
    [self.languageSelect setSelectable:NO];
    [self.languageSelect selectItemAtIndex:0];
}

- (IBAction)runProgram:(id)sender {
    [self.output.textStorage setAttributedString:[[NSAttributedString alloc] initWithString:@"" ]];
    
    [self.runButton setHidden:YES];
    [self.workingSpinner setHidden:NO];
    [self.workingSpinner startAnimation:nil];
    
    NSString *tempFileTemplate = [NSTemporaryDirectory() stringByAppendingPathComponent:@"quickcode.XXXXXX.m"];
    const char *tempFileTemplateCString = [tempFileTemplate fileSystemRepresentation];
    char *tempFileNameCString = (char *)malloc(strlen(tempFileTemplateCString) + 1);
    strcpy(tempFileNameCString, tempFileTemplateCString);
    int fileDescriptor = mkstemps(tempFileNameCString, 2);

    
    if (fileDescriptor == -1)
    {
        [self writeErrorLine:@"Error creating temporary files."];
        return;
    }
    
    
    NSString *tempFileName = [[NSFileManager defaultManager] stringWithFileSystemRepresentation:tempFileNameCString length:strlen(tempFileNameCString)];
    
    free(tempFileNameCString);
    NSFileHandle *tempFileHandle = [[NSFileHandle alloc] initWithFileDescriptor:fileDescriptor closeOnDealloc:NO];
    [tempFileHandle writeData:[[self.input string] dataUsingEncoding:NSUTF8StringEncoding]];

    NSString *binFileTemplate = [NSTemporaryDirectory() stringByAppendingPathComponent:@"quickcode.XXXXXX"];
    const char *binFileTemplateCString = [binFileTemplate fileSystemRepresentation];
    char *binFileNameCString = (char *)malloc(strlen(tempFileTemplateCString) + 1);
    strcpy(binFileNameCString, binFileTemplateCString);
    int binFileDescriptor = mkstemp(binFileNameCString);

    if (binFileDescriptor == -1)
    {
        [self writeErrorLine:@"Error creating temporary files."];
        return;
    }
    
    NSString *binFileName = [[NSFileManager defaultManager] stringWithFileSystemRepresentation:binFileNameCString length:strlen(binFileNameCString)];
    
    NSArray *arguments = @[ @"-fobjc-arc", @"-framework", @"Foundation", tempFileName, @"-o", binFileName];
    
    NSPipe *outputPipe = [NSPipe pipe];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(readCompleted:) name:NSFileHandleReadToEndOfFileCompletionNotification object:[outputPipe fileHandleForReading]];
    
    [self writeDebugLine:@"[QuickCode] Building..."];
    NSTask *task = [[NSTask alloc] init];
    [task setLaunchPath:@"/usr/bin/clang"];
    [task setArguments:arguments];
    [task setStandardError:outputPipe];
    [task launch];
    [task waitUntilExit];

    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSFileHandleReadToEndOfFileCompletionNotification object:outputPipe];
    
    outputPipe = [NSPipe pipe];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(readCompleted:) name:NSFileHandleReadToEndOfFileCompletionNotification object:[outputPipe fileHandleForReading]];
    
    [self writeDebugLine:@"[QuickCode] Running..."];
    task = [[NSTask alloc] init];
    [task setLaunchPath:binFileName];
    [task setStandardError:outputPipe];
    [[outputPipe fileHandleForReading] readToEndOfFileInBackgroundAndNotify];
    [task launch];
    [task waitUntilExit];
    
    [self.workingSpinner stopAnimation:nil];
    [self.workingSpinner setHidden:YES];
    [self.runButton setHidden:NO];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSFileHandleReadToEndOfFileCompletionNotification object:outputPipe];
}

- (void)readCompleted:(NSNotification *)notification {
    NSString *log = [[NSString alloc] initWithData:[[notification userInfo] objectForKey:NSFileHandleNotificationDataItem] encoding:NSUTF8StringEncoding];
    [self writeLine:log];
}

- (void)writeAttributedLine:(NSString *)string foreground:(NSColor *)foreground background:(NSColor *)background {
    NSMutableDictionary *attrs = [[NSMutableDictionary alloc] initWithCapacity:3];
    attrs[NSFontAttributeName] = [NSFont fontWithName:@"Menlo" size:14];
    if(foreground) { attrs[NSForegroundColorAttributeName] = foreground; }
    if(background) { attrs[NSBackgroundColorAttributeName] = background; }
    NSAttributedString *attr = [[NSAttributedString alloc] initWithString:[string stringByAppendingString:@"\n"] attributes:attrs];
    [self.output.textStorage insertAttributedString:attr atIndex:0];
}

- (void)writeDebugLine:(NSString *)string {
    NSColor *textColor = [NSColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.75];
    [self writeAttributedLine:string foreground:textColor background:nil];
}

- (void)writeErrorLine:(NSString *)string {
    NSColor *textColor = [NSColor colorWithRed:200.0 green:0 blue:0 alpha:1.0];
    [self writeAttributedLine:string foreground:textColor background:nil];
}

- (void)writeLine:(NSString *)string {
    [self writeAttributedLine:string foreground:nil background:nil];
}

@end
