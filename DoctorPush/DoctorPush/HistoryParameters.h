//
//  HistoryParameters.h
//  DoctorPush
//
//  Created by René (Privat) on 27.10.13.
//  Copyright (c) 2013 René (Privat). All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HistoryParameters : NSObject
@property (nonatomic, strong) NSDate *start, *start_was, *end, *end_was;
@property (nonatomic, strong) NSString *message;
@end
