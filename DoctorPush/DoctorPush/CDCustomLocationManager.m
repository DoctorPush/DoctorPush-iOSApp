//
//  CDCustomLocationManager.m
//  DoctorPush
//
//  Created by René Kann on 05.04.12.
//  Copyright (c) 2013 René (Privat). All rights reserved.
//

#import "CDCustomLocationManager.h"
#import "SynthesizeSingleton.h"

@implementation CDCustomLocationManager

+ (CDCustomLocationManager *)sharedInstance
{
    static CDCustomLocationManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[CDCustomLocationManager alloc] init];
        // Do any other initialisation stuff here
    });
    return sharedInstance;
}

- (id)init
{
	self = [super init];
	if (self) {
		self.currentLocation = nil;
		self.locationManager = [[CLLocationManager alloc] init];
		self.locationManager.delegate = self;
		self.locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
		
	}
	return self;
}

- (void)startLocationUpdates {
	if(self.locationManager && !self.locationUpdating) {
		self.locationUpdating = YES;
		[self.locationManager startUpdatingLocation];
	}
}

- (void)stopLocationUpdates {
	if(self.locationManager) {
		[self.locationManager stopUpdatingLocation];
		self.locationUpdating = NO;
	}
}

#pragma mark -
#pragma mark CLLocationManagerDelegate Methods
- (void)locationManager:(CLLocationManager*)manager
	didUpdateToLocation:(CLLocation*)newLocation
		   fromLocation:(CLLocation*)oldLocation
{
	
	self.gpsStatus = @"success";
	self.currentLocation = newLocation;
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"locationUpdate" object:newLocation];
	
	if([self.locDelegate respondsToSelector:@selector(locationUpdate:)]) {
		[self.locDelegate locationUpdate:newLocation];
	}
	
	[self stopLocationUpdates];
}

- (void)locationManager:(CLLocationManager*)manager
	   didFailWithError:(NSError*)error
{
	self.gpsStatus = @"failed";
}

@end
