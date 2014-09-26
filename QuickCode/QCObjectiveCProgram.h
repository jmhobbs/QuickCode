//
//  QCObjectiveC.h
//  QuickCode
//
//  Created by John Hobbs on 9/25/14.
//  Copyright (c) 2014 John Hobbs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QCProgram.h"

@interface QCObjectiveCProgram : QCProgram

@property (strong, nonatomic) NSString *sourceFileName;
@property (strong, nonatomic) NSString *binaryFileName;

@end
