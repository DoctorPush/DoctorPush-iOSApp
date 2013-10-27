//
//  User.h
//  DoctorPush
//
//  Created by René (Privat) on 26.10.13.
//  Copyright (c) 2013 René (Privat). All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Appointment.h"

@interface NSObject (UserDelegate)
- (void)appointmentsLoaded;
@end

@interface User : NSObject

@property (nonatomic, strong) NSString *apn_id, *phonenumber;
@property (nonatomic, strong) NSMutableArray *appointments;
@property (nonatomic, strong) NSMutableArray *service_urls;
@property (nonatomic, assign) id delegate;

- (void)registerAPNID;
- (void)addFakeAppointment;
- (void)getAllAppointments;
- (void)deleteAllAppointments;
- (void)loadAppointmentInital:(NSString *)serviceURL;

@end
