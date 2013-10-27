//
//  TimerVC.m
//  DoctorPush
//
//  Created by René (Privat) on 27.10.13.
//  Copyright (c) 2013 René (Privat). All rights reserved.
//

#import "TimerVC.h"

@interface TimerVC ()
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, readwrite) int selectedIndex;

@end

@implementation TimerVC

@synthesize appointment;

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
    // Do any additional setup after loading the view from its nib.
}

- (void)startTimer {
    
    if(self.appointment) {
        [self.appointment setDelegateToTimer:self];
        [self.appointment getLocationFromAdress];
        
        if(self.appointment.waiting_persons > 0) {
            [self.lblPersonsWaiting setText:[NSString stringWithFormat:@"%i persons waiting in front of you.", self.appointment.waiting_persons]];
        }
    }
    
    if(!self.timer) {
        self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                      target:self
                                                    selector:@selector(calcTimeLeft)
                                                    userInfo:nil
                                                     repeats:YES];
    }
}

- (void)reloadTimer {
    [self.timer invalidate];
    self.timer = nil;
    
    __block CGRect fr = self.loadingView.frame;
    
    [UIView animateWithDuration:0.20
                     animations:^{
                         fr.origin.y = 0;
                         self.loadingView.frame = fr;
                     }
                     completion:^(BOOL finished) {
                         
                     }];
    
}

- (void)calcTimeLeft {
    
    double traveltime = self.appointment.traveltimeCar;
    
    if(self.selectedIndex == 1) {
        traveltime = self.appointment.traveltimeWalking;
    }
    
    double timeUntilAppointment = [self.appointment.begin timeIntervalSinceDate:[NSDate date]];
    double timeWithoutTraveltime = timeUntilAppointment - traveltime;
    
    if(timeWithoutTraveltime < 0) {
        self.lblTimer.text = @"00:00";
    } else {
        NSString *timeAsString = [Helper splitSecondsIntoComponents:timeWithoutTraveltime];
        self.lblTimer.text = timeAsString;
    }
    
   __block CGRect fr = self.loadingView.frame;
    
    [UIView animateWithDuration:0.20
                     animations:^{
                         fr.origin.y = 0 - fr.size.height;
                         self.loadingView.frame = fr;
                     }
                     completion:^(BOOL finished) {
                         
                     }];
    
}

- (void)locationFound {
    [self refreshTraveltime];
}

- (void)refreshTraveltime {
    [self.appointment calcTravelTimeWalking:YES];
    [self.appointment calcTravelTimeCar:YES];
    [self performSelector:@selector(refreshTraveltime) withObject:nil afterDelay:300];
}

- (void)traveltimeCarCalculated:(NSTimeInterval)time {
    
}

- (void)traveltimeWalkingCalculated:(NSTimeInterval)time {
    
}

-(IBAction)pickedTransportation:(id)sender{
    UISegmentedControl *segmentedControl = (UISegmentedControl *)sender;
    self.selectedIndex = [segmentedControl selectedSegmentIndex];
    
    if(self.selectedIndex == 0) {
        //self.lblDriveOrWalk.text = @"losfahren";
    } else {
        //self.lblDriveOrWalk.text = @"losgehen";
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
