//
//  UCDLocationManager.h
//  DaimlerHRJobagent
//
//  Created by René Kann on 22.12.11.
//  Copyright (c) 2011 UCDplus GmbH - www.ucdplus.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>

#import "BSForwardGeocoder.h"
#import "BSKmlResult.h"

#import "CDCustomLocationManager.h"

@interface NSObject (UCDLocationManagerDelegate)
- (void)forwardFound:(CLLocationCoordinate2D)location;
- (void)forwardLocationUnknown;
- (void)reverseGeoLocationFound:(CLLocation *)theLocation place:(MKPlacemark *)thePlace;
- (void)reverseGeoLocationAdressNotFound:(CLLocation *)theLocation;
- (void)locationIsUpdating;
- (void)locationNotAccessable;
- (void)locationUpdateStarted;
@end

@interface UCDLocationManager : NSObject <CDCustomLocationManagerDelegate, BSForwardGeocoderDelegate> {
	BOOL updateReadableLocation, initialUpdateReadableLocation;
}

@property (nonatomic, weak) id delegate;

@property (nonatomic, strong) CDCustomLocationManager *locationManager;
@property (nonatomic, strong) CLLocation *currentLocation;
@property (nonatomic, strong) NSString *gpsStatus, *readableGPSLocation;

@property (nonatomic, strong) CLGeocoder *geoCoder;
@property (nonatomic, strong) BSForwardGeocoder *forwardGeocoder;

@property (nonatomic, readwrite) BOOL gpsEnabled, tellMeIfLocationIsAvailable, gpsRunning;

- (void)updateCurrentLocationAsReadableLocation;
- (void)reverseGeocode:(CLLocation *)theLocation;
- (void)initLocationUpdates;
- (void)forwardGeodecode:(NSString *)adress;
- (void)startLocationUpdates;

@end
