//
//  User.m
//  DoctorPush
//
//  Created by René (Privat) on 26.10.13.
//  Copyright (c) 2013 René (Privat). All rights reserved.
//

#import "User.h"

@interface User ()
@property (nonatomic, readwrite) int appsToLoad, appsLoaded;
@property (nonatomic, readwrite) BOOL appsLoading;
@end

@implementation User

@synthesize apn_id, phonenumber, delegate;

- (NSMutableArray *)appointments {
    if(!_appointments) _appointments = [[NSMutableArray alloc] init];
    return _appointments;
}

- (NSMutableArray *)service_urls {
    if(!_service_urls) _service_urls = [[NSMutableArray alloc] init];
    return _service_urls;
}

- (void)registerAPNID {
    //RKObjectManager *manager = [RKObjectManager sharedManager];
    //manager.managedObjectStore = nil;
    
    RKObjectManager *manager = [RKObjectManager managerWithBaseURL:[NSURL URLWithString:@"http://pushdoc.delphinus.uberspace.de/api"]];
    
    // Projects
	RKObjectMapping *userMapping = [RKObjectMapping mappingForClass:[self class]];
    
	[userMapping addAttributeMappingsFromDictionary:@{
                                                          @"iosDeviceID": @"apn_id",
                                                          @"phoneNumber": @"phonenumber"
                                                          }];
    
    // Build a request mapping by inverting our response mapping. Includes attributes and relationships
	RKObjectMapping* requestSerializationMapping = [userMapping inverseMapping];
	[manager addRequestDescriptor:[RKRequestDescriptor requestDescriptorWithMapping:requestSerializationMapping objectClass:[self class] rootKeyPath:Nil method:RKRequestMethodPOST]];
   
	[manager postObject:self path:@"user"
             parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                 NSLog(@"It Worked: %@", [mappingResult array]);
                 
             } failure:^(RKObjectRequestOperation *operation, NSError *error) {
                 //self.r = operation.targetObject;
                 
                 NSLog(@"It Failed: %@", error);
               
             }];
}

- (void)addFakeAppointment {
    
    Appointment *a1 = [[Appointment alloc] init];
    [a1 setBegin:[NSDate dateWithTimeIntervalSinceReferenceDate:1382822200]];
    [a1 setEnd:[NSDate dateWithTimeIntervalSinceReferenceDate:1382822323]];
    [a1 setTitle:@"Termin A"];
    [a1 setService_url:@""];
    //[a1 setAdress:@"Alexanderstraße 13, 10179 Berlin, Deutschland"];
    //[a1 setDoctor:@"Dr. Mueller"];
    [self.appointments addObject:a1];
    
    Appointment *a2 = [[Appointment alloc] init];
    [a2 setBegin:[NSDate dateWithTimeIntervalSinceReferenceDate:1382822200]];
    [a2 setEnd:[NSDate dateWithTimeIntervalSinceReferenceDate:1382822323]];
    [a2 setTitle:@"Termine B"];
    [a2 setService_url:@""];
    //[a2 setAdress:@"Voltastrasse 5, 13355 Berlin, Deutschland"];
    //[a2 setDoctor:@"Dr. meier"];
    [self.appointments addObject:a2];
}

- (void)loadAppointmentFromServer:(NSString *)serviceURL {
    RKObjectManager* objectManager = [RKObjectManager sharedManager];
    
	RKObjectMapping * appointmentMapping = [RKObjectMapping mappingForClass:[Appointment class]];
	
	[appointmentMapping addAttributeMappingsFromDictionary:@{
                                                          @"start": @"begin",
                                                          @"end": @"end",
                                                          @"aID": @"id",
                                                          @"medic_id": @"medic_id",
                                                          @"patient_id": @"patient_id",
                                                          @"created_at": @"created_at",
                                                          @"updated_at": @"updated_at"
                                                          }];
    
    // Patient
	RKObjectMapping *patientsMapping = [RKObjectMapping mappingForClass:[Patient class]];
    
	[patientsMapping addAttributeMappingsFromDictionary:@{
                                                          @"pid": @"id",
                                                          @"name": @"name",
                                                          @"prename": @"prename",
                                                          @"title": @"title",
                                                          @"record_id":@"record_id",
                                                          @"address":@"address",
                                                          @"tel_number":@"tel_number",
                                                          @"created_at":@"created_at",
                                                          @"updated_at":@"updated_at"
                                                          }];
	
	// Define the relationship mapping
	[appointmentMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"patient"
																				  toKeyPath:@"patient"
																				withMapping:patientsMapping]];
    
    
    // Medic
	RKObjectMapping *medicsMapping = [RKObjectMapping mappingForClass:[Medic class]];
    
	[medicsMapping addAttributeMappingsFromDictionary:@{
                                                          @"mid": @"id",
                                                          @"name": @"name",
                                                          @"prename": @"prename",
                                                          @"title": @"title",
                                                          @"record_id":@"record_id",
                                                          @"address":@"address",
                                                          @"created_at":@"created_at",
                                                          @"updated_at":@"updated_at"
                                                          }];
	
	// Define the relationship mapping
	[appointmentMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"medic"
                                                                                       toKeyPath:@"medic"
                                                                                     withMapping:medicsMapping]];
    
    // do request stuff
    
	RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:appointmentMapping method:RKRequestMethodGET pathPattern:nil keyPath:@""  statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    
	NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:serviceURL]];
	
    RKObjectRequestOperation *objectRequestOperation = [[RKObjectRequestOperation alloc] initWithRequest:request responseDescriptors:@[ responseDescriptor ]];
    [objectRequestOperation.HTTPRequestOperation setAcceptableContentTypes:[NSSet setWithObject:@"application/json"]];
	
	[objectRequestOperation setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        RKLogInfo(@"Load collection of Articles: %@", mappingResult.array);
        
        [self.appointments addObject:[mappingResult.array lastObject]];
        
        self.appsLoaded++;
        [self checkLoadingState];
		
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        RKLogError(@"Operation failed with error: %@", error);
		
        self.appsLoaded++;
        [self checkLoadingState];
    }];
	
	[objectManager enqueueObjectRequestOperation:objectRequestOperation];
}

- (void)checkLoadingState {
    if(self.appsLoaded >= self.appsToLoad) {
        self.appsToLoad = 0;
        self.appsLoaded = 0;
        self.appsLoading = NO;
        
        if([self.delegate respondsToSelector:@selector(appointmentsLoaded)]) {
            [self.delegate appointmentsLoaded];
        }
    }
}

- (void)getAllAppointments {
    
    if(!self.appsLoading) {
        
        self.appsLoading = YES;
        
        [self.service_urls addObject:@"https://rawgithub.com/DoctorPush/doctor/master/appointment_test.json"];
        [self.service_urls addObject:@"https://rawgithub.com/DoctorPush/doctor/master/appointment_test.json"];
        
        self.appsToLoad = self.service_urls.count;
        
        for(NSString *service_url in self.service_urls) {
            [self loadAppointmentFromServer:service_url];
        }
    }
    
}

- (void) deleteAllAppointments  {
    if(self.appointments) {
        [self.appointments removeAllObjects];
    }
}


@end
