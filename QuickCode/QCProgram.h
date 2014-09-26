//
//  QCLanguage.h
//  QuickCode
//
//  Created by John Hobbs on 9/25/14.
//  Copyright (c) 2014 John Hobbs. All rights reserved.
//

// TODO: Ideally, these could be moved into a scriptable format that could be
// imported/exported and enumerated on the fly.

#import <Foundation/Foundation.h>
#import "QCLogView.h"

@interface QCProgram : NSObject

- (id)initWithLog:(QCLogView *)log;

@property (strong, nonatomic) QCLogView *log;

- (bool)isAvailable;
- (bool)compile:(NSString *)code;
- (bool)execute;

@end
