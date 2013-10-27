//
//  Patient.h
//  DoctorPush
//
//  Created by René (Privat) on 27.10.13.
//  Copyright (c) 2013 René (Privat). All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Patient : NSObject

@property (nonatomic, strong) NSString *name, *prename, *title, *address, *tel_number;
@property (nonatomic, strong) NSString *record_id;
@property (nonatomic, strong) NSDate *created_at, *updated_at;

@end
