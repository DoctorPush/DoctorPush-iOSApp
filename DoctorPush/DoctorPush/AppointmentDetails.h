//
//  AppointmentDetails.h
//  DoctorPush
//
//  Created by René (Privat) on 26.10.13.
//  Copyright (c) 2013 René (Privat). All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Appointment.h"
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>

@interface AppointmentDetails : UIViewController
@property (weak, nonatomic) IBOutlet UILabel *lblMedicName;
@property (weak, nonatomic) IBOutlet UILabel *lblDate;
@property (weak, nonatomic) IBOutlet UILabel *lblAddress;

@property (strong, nonatomic) Appointment *appointment;
@property (weak, nonatomic) IBOutlet UILabel *lblWalkingTime;
@property (weak, nonatomic) IBOutlet UILabel *lblCarTime;
@property (weak, nonatomic) IBOutlet UILabel *lblDistance;
@property (weak, nonatomic) IBOutlet MKMapView *mapview;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *carSpinner;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *walkingSpinner;

@end
