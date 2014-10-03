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

//-----
#import "QCObjectiveCProgram.h"
#import "QCPython2Program.h"
#import "QCRubyProgram.h"
#import "QCPHPProgram.h"
//-----

@implementation QCAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{    
    [self.input setDelegate:self];
    [self.input setMode:ACEModeText];
    [self.input setTheme:ACEThemeMonokai];
    
    [self.output setEditable:NO];
    [[self.output textStorage] setFont:[NSFont fontWithName:@"Menlo" size:14]];
    
    if([QCObjectiveCProgram isAvailable]) {
        [self.languageSelect addItemWithTitle:@"Objective-C"];
    }
    if([QCPython2Program isAvailable]) {
        [self.languageSelect addItemWithTitle:@"Python 2"];
    }
    if([QCRubyProgram isAvailable]) {
        [self.languageSelect addItemWithTitle:@"Ruby"];
    }
    if([QCPHPProgram isAvailable]) {
        [self.languageSelect addItemWithTitle:@"PHP"];
    }
    
    [self.languageSelect setAction:@selector(languageChanged:)];
    [self.languageSelect setTarget:self];
    [self.languageSelect selectItemAtIndex:0];
    [self languageChanged:self.languageSelect];
}

- (IBAction)languageChanged:(id)sender
{
    NSString *language = [self.languageSelect titleOfSelectedItem];
    NSBundle *mainBundle = [NSBundle mainBundle];
    NSString *source = [mainBundle pathForResource:[language stringByReplacingOccurrencesOfString:@" " withString:@""] ofType:@"src"];
    NSError *error;
    NSString *src = [NSString stringWithContentsOfFile:source encoding:NSUTF8StringEncoding error:&error];
    
    [self.input setString:src];
    
    NSString *className = [language stringByReplacingOccurrencesOfString:@" " withString:@""];
    className = [className stringByReplacingOccurrencesOfString:@"-" withString:@""];
    className = [NSString stringWithFormat:@"QC%@Program", className];

    [self.input setMode:[NSClassFromString(className) highlightMode]];
}

- (IBAction)runProgram:(id)sender
{
    NSString *language = [self.languageSelect titleOfSelectedItem];
    [self.output.textStorage setAttributedString:[[NSAttributedString alloc] initWithString:@"" ]];
    
    [self.runButton setHidden:YES];
    [self.workingSpinner setHidden:NO];
    [self.workingSpinner startAnimation:nil];

    NSString *className = [language stringByReplacingOccurrencesOfString:@" " withString:@""];
    className = [className stringByReplacingOccurrencesOfString:@"-" withString:@""];
    className = [NSString stringWithFormat:@"QC%@Program", className];

    id program = [[NSClassFromString(className) alloc] initWithLog:self.output];
    if([program compile:[self.input string]]) {
        [program execute];
    }
    
    [self.workingSpinner stopAnimation:nil];
    [self.workingSpinner setHidden:YES];
    [self.runButton setHidden:NO];
}



@end
