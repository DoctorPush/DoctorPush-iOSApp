//
//  Helper.m
//  DoctorPush
//
//  Created by René (Privat) on 26.10.13.
//  Copyright (c) 2013 René (Privat). All rights reserved.
//

#import "Helper.h"


@implementation Helper

+ (NSString *)splitSecondsIntoComponents:(NSTimeInterval)interval {
    
    NSInteger ti = (NSInteger)interval;
    NSInteger seconds = ti % 60;
    NSInteger minutes = (ti / 60) % 60;
    NSInteger hours = (ti / 3600);
    
    if(hours > 0) {
        return [NSString stringWithFormat:@"%02i:%02i h", hours, minutes];
    } else {
        return [NSString stringWithFormat:@"%02i:%02i min", minutes, seconds];
    }
    
}


@end
