//
//  UCDLocationManager.m
//  DoctorPush
//
//  Created by René Kann on 22.12.11.
//  Copyright (c) 2013 René (Privat) . All rights reserved.
//

#import "UCDLocationManager.h"

@implementation UCDLocationManager

#pragma mark - GPS Manager stuff

- (void)initLocationUpdates {
	
	if ([CLLocationManager locationServicesEnabled]) {
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(locationUpdateNote:) name:@"locationUpdate" object:self.locationManager];
		self.locationManager = [CDCustomLocationManager sharedInstance];
		[self.locationManager startLocationUpdates];
		
		self.gpsEnabled = YES;
		
	} else {
		self.gpsEnabled = NO;
	}
}

- (void)locationUpdateNote:(NSNotification *)notification {
	CLLocation *tmpCurrentLocation = (CLLocation *)notification.object;
	[self locationUpdate:tmpCurrentLocation];
}

- (void)updateCurrentLocationAsReadableLocation {
	
	//NSLog(@"self.currentLocation %@", self.currentLocation);
	
	if(!self.gpsEnabled || !self.locationManager) {
		
		if([self.delegate respondsToSelector:@selector(locationNotAccessable)]) {
			[self.delegate locationNotAccessable];
		}
		
	} else {
		if(self.locationManager && !self.currentLocation) {
			if(self.locationManager.locationUpdating) {
				
				if([self.delegate respondsToSelector:@selector(locationIsUpdating)]) {
					[self.delegate locationIsUpdating];
				}
				
			} else {
				
				initialUpdateReadableLocation = YES;
				[self.locationManager startLocationUpdates];
				
				if([self.delegate respondsToSelector:@selector(locationUpdateStarted)]) {
					[self.delegate locationUpdateStarted];
				}
			}
		}
	}
	
	if(!updateReadableLocation && self.currentLocation) {
		updateReadableLocation = YES;
		[self reverseGeocode:self.currentLocation];
	}
}

- (void)startLocationUpdates {
	if(self.locationManager) {
		[self.locationManager startLocationUpdates];
	}
}

- (void)locationUpdate:(CLLocation*)location {
	
	if(!self.currentLocation) {
		//[SVProgressHUD dismissWithSuccess:@"Standort ermittelt!" afterDelay:2];
	}
	
	self.currentLocation = location;
	
	if(initialUpdateReadableLocation) {
		initialUpdateReadableLocation = NO;
		[self updateCurrentLocationAsReadableLocation];
	}
}

#pragma mark - Forward Geocoding

-(void) forwardGeodecode:(NSString *)address {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self addressLocationBackground:address];
    });
}

-(void) addressLocationBackground:(NSString *)address
{
	NSString *urlString = [NSString stringWithFormat:@"http://maps.googleapis.com/maps/api/geocode/json?address=%@&sensor=true", [address stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
	
	NSError *jsonError = nil;
	NSData *locData = [NSData dataWithContentsOfURL:[NSURL URLWithString:urlString]];
	
	id object = [NSJSONSerialization JSONObjectWithData:locData options:0 error:&jsonError];
	
    if(!jsonError) {
		
		if([object isKindOfClass:[NSDictionary class]])
		{
			NSDictionary *results = object;
			
			BOOL adressFound = NO;
			
			double lat = [[[results valueForKeyPath:@"results.geometry.location.lat"] lastObject] doubleValue];
			double lng = [[[results valueForKeyPath:@"results.geometry.location.lng"] lastObject] doubleValue];
			
			CLLocationCoordinate2D loc;
			
			if(lat != 0 || lng != 0) {
				
				adressFound = YES;
				
				loc.latitude = lat;
				loc.longitude = lng;
			}
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if([self.delegate respondsToSelector:@selector(forwardFound:)]) {
					[self.delegate forwardFound:loc];
				}
            });
			
		}
		else
		{
			NSLog(@"Bei der Suche nach der Adresse ist ein Fehler aufgetrete!");
		}
	}
	else
	{
		NSLog(@"Bei der Suche nach der Adresse ist ein Fehler aufgetrete!");
	}
}

#pragma mark - Reverse Geocoding

- (void)reverseGeocode:(CLLocation *)theLocation {
	
	if(theLocation != nil) {
		
		__block CLGeocoder *geocoder = [[CLGeocoder alloc] init];
		
		[geocoder reverseGeocodeLocation:theLocation completionHandler:^(NSArray *placemarks, NSError *error) {
			if (error){
				NSLog(@"Geocode failed with error: %@", error);
				
				return;
			}
			
			NSLog(@"Received placemarks: %@", placemarks);
			
			MKPlacemark *placemark = [placemarks lastObject];
			
			if(placemark) {
				
				NSArray *shortDescArray = [placemark.addressDictionary valueForKey:@"FormattedAddressLines"];
				NSString *shortDesc = [shortDescArray componentsJoinedByString:@", "];
				
				NSLog(@"myPlacemark %@", placemark.addressDictionary);
				
				updateReadableLocation = NO;
				self.readableGPSLocation = shortDesc;
				
				if([self.delegate respondsToSelector:@selector(reverseGeoLocationFound:place:)]) {
					[self.delegate reverseGeoLocationFound:theLocation place:placemark];
				}
			} else {
				
				updateReadableLocation = NO;
				self.readableGPSLocation = @"-";
				
				if([self.delegate respondsToSelector:@selector(reverseGeoLocationAdressNotFound:)]) {
					[self.delegate reverseGeoLocationAdressNotFound:theLocation];
				}
			}
		}];
	}
}
@end
