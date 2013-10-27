//
//  CDCustomLocationManager.h
//  DaimlerHRJobagent
//
//  Created by René Kann on 05.04.12.
//  Copyright (c) 2012 UCDplus GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@protocol CDCustomLocationManagerDelegate <NSObject>
- (void)locationUpdate:(CLLocation*)location;
@end

@interface CDCustomLocationManager : NSObject <CLLocationManagerDelegate> {
	
}

@property (nonatomic, strong) NSString *gpsStatus;
@property (nonatomic, strong) CLLocationManager* locationManager;
@property (nonatomic, strong) CLLocation* currentLocation;
@property (nonatomic, weak) id <CDCustomLocationManagerDelegate> locDelegate;
@property (nonatomic, readwrite) BOOL locationUpdating;

+ (CDCustomLocationManager *)sharedInstance;
- (void)startLocationUpdates;
- (void)stopLocationUpdates;
@end
