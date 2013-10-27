//
//  TimerVC.h
//  DoctorPush
//
//  Created by René (Privat) on 27.10.13.
//  Copyright (c) 2013 René (Privat). All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Appointment.h"
#import "Helper.h"

@interface TimerVC : UIViewController
@property (weak, nonatomic) IBOutlet UISegmentedControl *switchCarWalking;
@property (weak, nonatomic) IBOutlet UILabel *lblTimer;
@property (weak, nonatomic) IBOutlet UILabel *lblPersonsWaiting;
@property (nonatomic, strong) Appointment *appointment;
@property (weak, nonatomic) IBOutlet UIView *loadingView;
@property (weak, nonatomic) IBOutlet UILabel *lblDriveOrWalk;

- (void)startTimer;
- (void)reloadTimer;

@end
