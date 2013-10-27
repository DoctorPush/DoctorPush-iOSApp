//
//  Appointment.m
//  DoctorPush
//
//  Created by René (Privat) on 26.10.13.
//  Copyright (c) 2013 René (Privat). All rights reserved.
//

#import "Appointment.h"

@implementation Appointment

@synthesize begin, end, title;
@synthesize service_url;
@synthesize created_at, updated_at;
@synthesize medic, patient;

@synthesize formatedDate, locationManager, delegate, location;

- (NSString *)formatedDateAndTime {
    
    if(self.formatedDate != nil) {
        return self.formatedDate;
    }
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"dd.MM.yyyy"];
    
    NSString *date = [formatter stringFromDate:self.begin];
    [formatter setDateFormat:@"HH:mm"];
    NSString *beginTime = [formatter stringFromDate:self.begin];
    NSString *endTime = [formatter stringFromDate:self.end];
    
    self.formatedDate = [NSString stringWithFormat:@"%@ %@ Uhr - %@ Uhr", date, beginTime, endTime];
    
    return self.formatedDate;
}

- (NSComparisonResult)compare:(Appointment *)otherObject {
    return [self.begin compare:otherObject.begin];
}

- (void)calcTravelTimeWalking {
    
    MKDirectionsRequest *request = [[MKDirectionsRequest alloc] init];
    
    MKPlacemark *sourcePlacemark = [[MKPlacemark alloc] initWithCoordinate:self.location addressDictionary:nil];
    MKMapItem *appLocation = [[MKMapItem alloc] initWithPlacemark:sourcePlacemark];
    
    [request setTransportType:MKDirectionsTransportTypeWalking];
    request.source = [MKMapItem mapItemForCurrentLocation];
    request.destination = appLocation;
    
    request.requestsAlternateRoutes = NO;
    MKDirections *directions = [[MKDirections alloc] initWithRequest:request];
    
    [directions calculateETAWithCompletionHandler:^(MKETAResponse *response, NSError *error) {
        if (error) {
            // Handle error
        } else {
            self.traveltimeWalking = response.expectedTravelTime;
            
            if([self.delegate respondsToSelector:@selector(traveltimeWalkingCalculated:)]) {
                [self.delegate traveltimeWalkingCalculated:response.expectedTravelTime];
            }
        }
    }];
}

- (void)calcTravelTimeCar {
    
    MKDirectionsRequest *request = [[MKDirectionsRequest alloc] init];
    
    MKPlacemark *sourcePlacemark = [[MKPlacemark alloc] initWithCoordinate:self.location addressDictionary:nil];
    MKMapItem *appLocation = [[MKMapItem alloc] initWithPlacemark:sourcePlacemark];
    
    [request setTransportType:MKDirectionsTransportTypeAutomobile];
    request.source = [MKMapItem mapItemForCurrentLocation];
    request.destination = appLocation;
    
    request.requestsAlternateRoutes = NO;
    MKDirections *directions = [[MKDirections alloc] initWithRequest:request];
    
    [directions calculateETAWithCompletionHandler:
     ^(MKETAResponse *response, NSError *error) {
         if (error) {
             // Handle error
         } else {
             
             self.traveltimeCar = response.expectedTravelTime;
             
             if([self.delegate respondsToSelector:@selector(traveltimeCarCalculated:)]) {
                 [self.delegate traveltimeCarCalculated:response.expectedTravelTime];
             }
         }
     }];
}


- (void)setupLocationManager {
    if(!self.locationManager) {
        self.locationManager = [[UCDLocationManager alloc] init];
        [self.locationManager setDelegate:self];
    }
}

- (void)getLocationFromAdress {
    
    [self setupLocationManager];
    
    if(self.locationManager && self.location.latitude == 0) {
        [self.locationManager forwardGeodecode:self.medic.address];
    } else if(self.location.latitude != 0) {
        if([self.delegate respondsToSelector:@selector(locationFound)]) {
            [self.delegate locationFound];
        }
    }
}

- (void)forwardFound:(CLLocationCoordinate2D)theLocation {
    
    if(theLocation.latitude != 0) {
        self.location = theLocation;
        
        if([self.delegate respondsToSelector:@selector(locationFound)]) {
            [self.delegate locationFound];
        }
    }
}

- (void)forwardLocationUnknown {
    
}

- (void)forwardLocationToManyQueries {
    
}



@end
