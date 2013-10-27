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

@synthesize formatedDate, locationManager, delegate, location, delegateToTimer;

- (NSString *)formatedDateAndTime {
    
    if(self.formatedDate != nil) {
        return self.formatedDate;
    }
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"dd.MM.yyyy"];
    
    NSString *date = [formatter stringFromDate:self.begin];
    [formatter setDateFormat:@"HH:mm"];
    NSTimeZone *gmt = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
    [formatter setTimeZone:gmt];
    
    NSString *beginTime = [formatter stringFromDate:self.begin];
    NSString *endTime = [formatter stringFromDate:self.end];
    
    self.formatedDate = [NSString stringWithFormat:@"%@ %@ Uhr - %@ Uhr", date, beginTime, endTime];
    
    return self.formatedDate;
}

- (NSComparisonResult)compare:(Appointment *)otherObject {
    return [self.begin compare:otherObject.begin];
}

- (void)calcTravelTimeWalking:(BOOL)refresh {
    
    if(self.traveltimeWalking && !refresh) {
        if([self.delegate respondsToSelector:@selector(traveltimeWalkingCalculated:)]) {
            [self.delegate traveltimeWalkingCalculated:self.traveltimeWalking];
        }
    }
    
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
             NSLog(@"error %@", [error userInfo]);
        } else {
            self.traveltimeWalking = response.expectedTravelTime;
            
            if([self.delegate respondsToSelector:@selector(traveltimeWalkingCalculated:)]) {
                [self.delegate traveltimeWalkingCalculated:response.expectedTravelTime];
            }
            
            if([self.delegateToTimer respondsToSelector:@selector(traveltimeWalkingCalculated:)]) {
                [self.delegateToTimer traveltimeWalkingCalculated:response.expectedTravelTime];
            }
        }
    }];
}

- (void)calcTravelTimeCar:(BOOL)refresh {
    
    if(self.traveltimeCar && !refresh) {
        if([self.delegate respondsToSelector:@selector(traveltimeCarCalculated:)]) {
            [self.delegate traveltimeCarCalculated:self.traveltimeCar];
        }
    }
    
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
             NSLog(@"error %@", [error userInfo]);
             
         } else {
             
             self.traveltimeCar = response.expectedTravelTime;
             
             if([self.delegate respondsToSelector:@selector(traveltimeCarCalculated:)]) {
                 [self.delegate traveltimeCarCalculated:response.expectedTravelTime];
             }
             
             if([self.delegateToTimer respondsToSelector:@selector(traveltimeCarCalculated:)]) {
                 [self.delegateToTimer traveltimeCarCalculated:response.expectedTravelTime];
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
        [self forwardFound:self.location];
    }
}

- (void)forwardFound:(CLLocationCoordinate2D)theLocation {
    
    if(theLocation.latitude != 0) {
        self.location = theLocation;
        
        if([self.delegate respondsToSelector:@selector(locationFound)]) {
            [self.delegate locationFound];
        }
        
        if([self.delegateToTimer respondsToSelector:@selector(locationFound)]) {
            [self.delegateToTimer locationFound];
        }
    }
}

- (void)forwardLocationUnknown {
    
}

- (void)forwardLocationToManyQueries {
    
}



@end
