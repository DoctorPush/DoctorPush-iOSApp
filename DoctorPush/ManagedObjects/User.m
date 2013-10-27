//
//  User.m
//  DoctorPush
//
//  Created by René (Privat) on 26.10.13.
//  Copyright (c) 2013 René (Privat). All rights reserved.
//

#import "User.h"
#import "AppDelegate.h"

@interface User ()
@property (nonatomic, readwrite) int appsToLoad, appsLoaded;
@property (nonatomic, readwrite) BOOL appsLoading;
@end

@implementation User

@synthesize apn_id, phonenumber, delegate, aNewServiceURL;

- (NSMutableArray *)appointments {
    if(!_appointments) _appointments = [[NSMutableArray alloc] init];
    return _appointments;
}

- (NSMutableArray *)service_urls {
    if(!_service_urls) _service_urls = [[NSMutableArray alloc] init];
    return _service_urls;
}

#pragma mark Register Apple ID

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

#pragma mark Appointments

- (void)addFakeAppointmentService {
    [self addAppointmentWithServiceURL:@"https://rawgithub.com/DoctorPush/doctor/master/appointment_test.json"];
    [self addAppointmentWithServiceURL:@"https://rawgithub.com/DoctorPush/doctor/master/appointment_test2.json"];
}

- (void)addAppointmentWithServiceURL:(NSString *)theURL loadAllAfterAdd:(BOOL)loadAllAfterAdd {
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSPredicate* urlPred = [NSPredicate predicateWithFormat:@"service_url == %@", theURL];
    [fetchRequest setPredicate:urlPred];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"AppointmentSettings" inManagedObjectContext:appDelegate.managedObjectContext];
    [fetchRequest setEntity:entity];
    NSError *error;
    
    NSArray *serviceURLs = [appDelegate.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    if(serviceURLs.count == 0) {
        AppointmentSettings *appSetting = [NSEntityDescription insertNewObjectForEntityForName:@"AppointmentSettings" inManagedObjectContext:appDelegate.managedObjectContext];
        [appSetting setService_url:theURL];
        
        NSError *error;
        if (![appDelegate.managedObjectContext save:&error]) {
            NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
        }
    }
    
    self.aNewServiceURL = nil;
    
    if(loadAllAfterAdd) {
        [self getAllAppointments];
    }
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
                                                          @"updated_at": @"updated_at",
                                                          @"title": @"title"
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
        
        Appointment *a = [mappingResult.array lastObject];
        [a setService_url:serviceURL];
        [self.appointments addObject:a];
        
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
        
        NSSortDescriptor* sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"begin" ascending:YES selector:@selector(compare:)];
        NSArray* sortedArray = [self.appointments sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
        
        [self.appointments removeAllObjects];
        [self.appointments addObjectsFromArray:sortedArray];
        
        if([self.delegate respondsToSelector:@selector(appointmentsLoaded)]) {
            [self.delegate appointmentsLoaded];
        }
    }
}

- (void)getAllAppointments {
    
    if(!self.appsLoading) {
        
        if(self.aNewServiceURL) {
            [self addAppointmentWithServiceURL:self.aNewServiceURL loadAllAfterAdd:YES];
            return;
        }
        
        [self.appointments removeAllObjects];
        
        self.appsLoading = YES;
        
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];

        NSEntityDescription *entity = [NSEntityDescription entityForName:@"AppointmentSettings" inManagedObjectContext:appDelegate.managedObjectContext];
        [fetchRequest setEntity:entity];
        NSError *error;
        
        NSArray *serviceURLs = [appDelegate.managedObjectContext executeFetchRequest:fetchRequest error:&error];
        
        if(serviceURLs.count > 0) {
            
            for(AppointmentSettings *a in serviceURLs) {
                [self loadAppointmentFromServer:a.service_url];
                [self.service_urls addObject:a.service_url];
            }
        }
                              
        self.appsToLoad = serviceURLs.count;
    }
}

- (void) deleteAllAppointmentSettings  {
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"AppointmentSettings" inManagedObjectContext:appDelegate.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSError *error;
    NSArray *items = [appDelegate.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    for (NSManagedObject *managedObject in items) {
    	[appDelegate.managedObjectContext deleteObject:managedObject];
    	NSLog(@"%@ object deleted",@"AppointmentSettings");
    }
    if (![appDelegate.managedObjectContext save:&error]) {
    	NSLog(@"Error deleting %@ - error:%@",@"AppointmentSettings",error);
    }
    
}

@end
