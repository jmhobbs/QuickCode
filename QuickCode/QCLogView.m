//
//  QCLogView.m
//  QuickCode
//
//  Created by John Hobbs on 9/26/14.
//  Copyright (c) 2014 John Hobbs. All rights reserved.
//

#import "QCLogView.h"

@implementation QCLogView

- (void)clear {
    [self.textStorage setAttributedString:[[NSAttributedString alloc] initWithString:@"" ]];
}

- (void)writeAttributedLine:(NSString *)string foreground:(NSColor *)foreground background:(NSColor *)background {
    NSMutableDictionary *attrs = [[NSMutableDictionary alloc] initWithCapacity:3];
    attrs[NSFontAttributeName] = [NSFont fontWithName:@"Menlo" size:14];
    if(foreground) { attrs[NSForegroundColorAttributeName] = foreground; }
    if(background) { attrs[NSBackgroundColorAttributeName] = background; }
    NSAttributedString *attr = [[NSAttributedString alloc] initWithString:[string stringByAppendingString:@"\n"] attributes:attrs];
    [self.textStorage insertAttributedString:attr atIndex:0];
}

- (void)debug:(NSString *)string {
    NSColor *textColor = [NSColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.75];
    [self writeAttributedLine:string foreground:textColor background:nil];
}

- (void)error:(NSString *)string {
    NSColor *textColor = [NSColor colorWithRed:200.0 green:0 blue:0 alpha:1.0];
    [self writeAttributedLine:string foreground:textColor background:nil];
}

- (void)info:(NSString *)string {
    [self writeAttributedLine:string foreground:nil background:nil];
}

@end
