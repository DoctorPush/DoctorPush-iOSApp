//
//  AppointmentSettings.h
//  DoctorPush
//
//  Created by René (Privat) on 27.10.13.
//  Copyright (c) 2013 René (Privat). All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface AppointmentSettings : NSManagedObject

@property (nonatomic, retain) NSString * service_url;

@end
