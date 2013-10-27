//
//  Appointment.h
//  DoctorPush
//
//  Created by René (Privat) on 26.10.13.
//  Copyright (c) 2013 René (Privat). All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UCDLocationManager.h"
#import "Medic.h"
#import "Patient.h"

@interface NSObject (AppointmentDelegate)
- (void)locationFound;
- (void)traveltimeCarCalculated:(NSTimeInterval)time;
- (void)traveltimeWalkingCalculated:(NSTimeInterval)time;
@end

@interface Appointment : NSObject

@property (nonatomic, retain) NSDate * begin;
@property (nonatomic, retain) NSDate * end;
@property (nonatomic, strong) NSDate *created_at, *updated_at;

@property (nonatomic, readwrite) int aID, patient_id, medic_id;

@property (nonatomic, retain) Medic *medic;
@property (nonatomic, retain) Patient *patient;

@property (nonatomic, strong) NSMutableArray *history;

@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString *service_url;

@property (nonatomic, strong) NSString *formatedDate;
@property (nonatomic, strong) UCDLocationManager *locationManager;
@property (nonatomic, readwrite) CLLocationCoordinate2D location;
@property (nonatomic, assign) id delegate;

@property (nonatomic, readwrite) NSTimeInterval traveltimeWalking, traveltimeCar;

- (NSString *)formatedDateAndTime;
- (void)getLocationFromAdress;

@end
