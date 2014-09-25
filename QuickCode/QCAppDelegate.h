//
//  QCAppDelegate.h
//  QuickCode
//
//  Created by John Hobbs on 9/25/14.
//  Copyright (c) 2014 John Hobbs. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <ACEView/ACEView.h>

@interface QCAppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *window;

@property (weak) IBOutlet ACEView *input;
@property (unsafe_unretained) IBOutlet NSTextView *output;

@property (weak) IBOutlet NSButton *runButton;
@property (weak) IBOutlet NSProgressIndicator *workingSpinner;
@property (weak) IBOutlet NSComboBox *languageSelect;

- (IBAction)runProgram:(id)sender;

@end
