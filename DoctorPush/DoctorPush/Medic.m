//
//  Medic.m
//  DoctorPush
//
//  Created by René (Privat) on 27.10.13.
//  Copyright (c) 2013 René (Privat). All rights reserved.
//

#import "Medic.h"

@implementation Medic
@synthesize mid, name, prename, title, created_at, updated_at, address;

- (NSString *)formatedName {
    return [NSString stringWithFormat:@"%@ %@", self.prename, self.name];
}


@end


