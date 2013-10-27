//
//  HistoryItem.m
//  DoctorPush
//
//  Created by René (Privat) on 27.10.13.
//  Copyright (c) 2013 René (Privat). All rights reserved.
//

#import "HistoryItem.h"

@implementation HistoryItem

- (NSString *)kindIfOfUpdate {
    
    if([self.key isEqualToString:@"appointment.update"]) {
        return @"Updated";
    }
    
    if([self.key isEqualToString:@"appointment.create"]) {
        return @"Created";
    }
    
    return @"Unknown";
}

- (NSString *)getInfo {
    if([self.key isEqualToString:@"appointment.update"] || [self.key isEqualToString:@"appointment.create"]) {
        
        NSString *r = @"";
        
        if(self.parameters.start) {
            r = [self formatedDateAndTime:self.parameters.start date_was:self.parameters.start_was];
        }
        
        if(self.parameters.end) {
            NSString *temp = [self formatedDateAndTime:self.parameters.start date_was:self.parameters.start_was];
            
            if(temp && r) {
                r = [NSString stringWithFormat:@"%@\n%@", r, temp];
            } else {
                r = temp;
            }
        }
        
        return r;
    }
    
    if([self.key isEqualToString:@"appointment.comment"]) {
        
    }
    
    return @"";
}

- (NSString *)formatedDateAndTime:(NSDate *)date_now date_was:(NSDate *)date_was {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"dd.MM.yyyy"];
    
    NSString *dateNow = [formatter stringFromDate:date_now];
    NSString *dateEnd = [formatter stringFromDate:date_was];
    
    [formatter setDateFormat:@"HH:mm"];
    NSTimeZone *gmt = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
    [formatter setTimeZone:gmt];
    
    NSString *beginTime = [formatter stringFromDate:date_now];
    NSString *endTime = [formatter stringFromDate:date_was];
    
    NSString *formatedDate = [NSString stringWithFormat:@"%@ %@ o'clock - %@ %@ o'clock", dateNow, beginTime, dateEnd, endTime];
    
    return formatedDate;
}

@end
