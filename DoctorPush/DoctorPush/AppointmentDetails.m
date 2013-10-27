//
//  AppointmentDetails.m
//  DoctorPush
//
//  Created by René (Privat) on 26.10.13.
//  Copyright (c) 2013 René (Privat). All rights reserved.
//

#import "AppointmentDetails.h"

@interface AppointmentDetails ()

@end

@implementation AppointmentDetails

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	if(self.appointment) {
        
        CDCustomLocationManager *locationManager = [CDCustomLocationManager sharedInstance];

        //start off in San Francisco
        MKCoordinateRegion region;
        region.center = locationManager.currentLocation.coordinate;
        region.span.latitudeDelta = 0.1;
        region.span.longitudeDelta = 0.1;

        [self.mapview setRegion:region animated:YES];
        
        [self.appointment setDelegate:self];
        [self.appointment getLocationFromAdress];
        
        [self.lblMedicName setText:[self.appointment.medic formatedName]];
        [self.lblAddress setText:self.appointment.medic.address];
        [self.lblDate setText:[self.appointment formatedDateAndTime]];
        
        self.title = [NSString stringWithFormat:@"Termin bei %@", [self.appointment.medic formatedName]];
    }
}

- (NSArray *)minAndSeconds:(NSTimeInterval)theSeconds {
    int minutes = theSeconds / 60;
    int seconds = (int)((double)theSeconds) % 60;
    
    NSString *formatedMinutes = [NSString stringWithFormat:@"%i", minutes];
    
    if(minutes < 10) {
        formatedMinutes = [NSString stringWithFormat:@"0%i", minutes];
    }
    
    NSString *formatedSeconds = [NSString stringWithFormat:@"%i", seconds];
    
    NSArray *arr = [NSArray arrayWithObjects:formatedSeconds, nil];
    
    if(minutes > 0) {
        
        if(seconds < 10) {
            formatedSeconds = [NSString stringWithFormat:@"0%i", seconds];
        }
        
        arr = [NSArray arrayWithObjects:formatedMinutes,formatedSeconds, nil];
    }
   
    return arr;
}

- (void)traveltimeCarCalculated:(NSTimeInterval)time {
    [self.carSpinner stopAnimating];
    
    NSArray *arr = [self minAndSeconds:time];
    
    if(arr.count > 1) {
        [self.lblCarTime setText:[NSString stringWithFormat:@"%@:%@ min", [arr objectAtIndex:0], [arr objectAtIndex:1]]];
    } else {
        [self.lblCarTime setText:[NSString stringWithFormat:@"%@ Sek", [arr objectAtIndex:0]]];
    }
}

- (void)traveltimeWalkingCalculated:(NSTimeInterval)time {
    [self.walkingSpinner stopAnimating];
    
    NSArray *arr = [self minAndSeconds:time];
    
    if(arr.count > 1) {
        [self.lblWalkingTime setText:[NSString stringWithFormat:@"%@:%@ min", [arr objectAtIndex:0], [arr objectAtIndex:1]]];
    } else {
        [self.lblWalkingTime setText:[NSString stringWithFormat:@"%@ Sek", [arr objectAtIndex:0]]];
    }
}

- (void)getPerfectRegion {
    
    CDCustomLocationManager *locationManager = [CDCustomLocationManager sharedInstance];
    CLLocationCoordinate2D locCurrent = locationManager.currentLocation.coordinate;
    CLLocationCoordinate2D locApp = self.appointment.location;
    
    float minLatitude = MIN(locCurrent.latitude, locApp.latitude);
    float maxLatitude = MAX(locCurrent.latitude, locApp.latitude);
    
    float minLongitude = MIN(locCurrent.longitude, locApp.longitude);
    float maxLongitude = MAX(locCurrent.longitude, locApp.longitude);
    
    #define MAP_PADDING 1.8
    
    // we'll make sure that our minimum vertical span is about a kilometer
    // there are ~111km to a degree of latitude. regionThatFits will take care of
    // longitude, which is more complicated, anyway.
    #define MINIMUM_VISIBLE_LATITUDE 0.01
    
    MKCoordinateRegion region;
    region.center.latitude = (minLatitude + maxLatitude + 0.04) / 2;
    region.center.longitude = (minLongitude + maxLongitude) / 2;
    
    region.span.latitudeDelta = (maxLatitude - minLatitude) * MAP_PADDING;
    
    region.span.latitudeDelta = (region.span.latitudeDelta < MINIMUM_VISIBLE_LATITUDE)
    ? MINIMUM_VISIBLE_LATITUDE
    : region.span.latitudeDelta;
    
    region.span.longitudeDelta = (maxLongitude - minLongitude) * MAP_PADDING;
    
    MKCoordinateRegion scaledRegion = [self.mapview regionThatFits:region];
    [self.mapview setRegion:scaledRegion animated:YES];
}

- (void)locationFound {
    
    [self.appointment calcTravelTimeWalking:YES];
    [self.appointment calcTravelTimeCar:YES];
    
    [self getDirections];
}

- (void)getDirections
{
    MKDirectionsRequest *request = [[MKDirectionsRequest alloc] init];
    
    MKPlacemark *sourcePlacemark = [[MKPlacemark alloc] initWithCoordinate:self.appointment.location addressDictionary:nil];
    MKMapItem *appLocation = [[MKMapItem alloc] initWithPlacemark:sourcePlacemark];
    
    [request setTransportType:MKDirectionsTransportTypeWalking];
    request.source = [MKMapItem mapItemForCurrentLocation];
    request.destination = appLocation;
    
    request.requestsAlternateRoutes = NO;
    MKDirections *directions = [[MKDirections alloc] initWithRequest:request];
    
    [directions calculateDirectionsWithCompletionHandler:
     ^(MKDirectionsResponse *response, NSError *error) {
         if (error) {
             // Handle error
         } else {
             [self showRoute:response];
         }
     }];
}

-(void)showRoute:(MKDirectionsResponse *)response
{
    float traveltime = 0;
    
    for (MKRoute *route in response.routes)
    {
        [self.mapview addOverlay:route.polyline level:MKOverlayLevelAboveRoads];
        
        traveltime += route.expectedTravelTime;
        
        for (MKRouteStep *step in route.steps)
        {
            NSLog(@"%@", step.instructions);
        }
    }
    
    [self getPerfectRegion];
}


- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id < MKOverlay >)overlay
{
    MKPolylineRenderer *renderer =
    [[MKPolylineRenderer alloc] initWithOverlay:overlay];
    renderer.strokeColor = [UIColor blueColor];
    renderer.lineWidth = 2.0;
    return renderer;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
