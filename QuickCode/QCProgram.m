//
//  QCLanguage.m
//  QuickCode
//
//  Created by John Hobbs on 9/25/14.
//  Copyright (c) 2014 John Hobbs. All rights reserved.
//

#import "QCProgram.h"

@implementation QCProgram

- (id)initWithLog:(QCLogView *)log {
    self = [self init];
    if(self) {
        self.log = log;
    }
    return self;
}

- (bool)isAvailable {
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
