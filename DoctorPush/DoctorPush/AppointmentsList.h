//
//  RKFirstViewController.h
//  DoctorPush
//
//  Created by René (Privat) on 26.10.13.
//  Copyright (c) 2013 René (Privat). All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Patient.h"
#import "AppDelegate.h"
#import "AppointmentCell.h"
#import "AppointmentDetails.h"
#import "UCDLocationManager.h"


@interface AppointmentsList : UIViewController
@property (weak, nonatomic) IBOutlet UITableView *appointsTable;
@property (nonatomic, strong) User *user;
@end
