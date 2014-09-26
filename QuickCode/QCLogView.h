//
//  QCLogView.h
//  QuickCode
//
//  Created by John Hobbs on 9/26/14.
//  Copyright (c) 2014 John Hobbs. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface QCLogView : NSTextView

- (void)clear;

- (void)debug:(NSString *)string;
- (void)error:(NSString *)string;
- (void)info:(NSString *)string;

@end
