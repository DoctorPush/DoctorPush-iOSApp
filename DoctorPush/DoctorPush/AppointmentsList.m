//
//  RKFirstViewController.m
//  DoctorPush
//
//  Created by René (Privat) on 26.10.13.
//  Copyright (c) 2013 René (Privat). All rights reserved.
//

#import "AppointmentsList.h"

@interface AppointmentsList ()
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) UCDLocationManager *locationManager;
@end

@implementation AppointmentsList

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"Meine Termine";
    
    self.timerVC = [[TimerVC alloc] initWithNibName:@"TimerVC" bundle:nil];
    [self.timerVC.view setFrame:CGRectMake(0, 66, 320, 175)];
    [self.view addSubview:self.timerVC.view];
    
    [self initUser];
    [self setupLocationManager];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reload)
                                                 name:@"RefreshAppointments"
                                               object:nil];
}

- (void)setupLocationManager {
    self.locationManager = [[UCDLocationManager alloc] init];
	[self.locationManager setDelegate:self];
	[self.locationManager initLocationUpdates];
}

- (void)initUser {

    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    self.user = appDelegate.user;
    [self.user setDelegate:self];
   
    [self reload];
}

- (void)appointmentsLoaded {
    [ProgressHUD dismiss];
    
    if(self.user.appointments.count > 0) {
        Appointment *a = [self.user.appointments objectAtIndex:0];
        [self.timerVC setAppointment:a];
        [self.timerVC startTimer];
    }
    
    [self.appointsTable setHidden:NO];
    [self.appointsTable reloadData];
}

- (void)reload {
    
    [self.appointsTable setHidden:YES];
    [self.timerVC reloadTimer];
    
    [ProgressHUD show:@"Termine werden geladen..."];
    [self.user getAllAppointments];
}


#pragma mark TableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [self.user.appointments count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
	return 60;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *CellIdentifier = @"AppointmentCell";
    
    AppointmentCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:CellIdentifier owner:nil options:nil];
        for(id currentObject in topLevelObjects) {
            if([currentObject isKindOfClass:[UITableViewCell class]]) {
                cell = (AppointmentCell *) currentObject;
                break;
            }
        }
        
        topLevelObjects = nil;
    }
    
    Appointment *a = [self.user.appointments objectAtIndex:[indexPath row]];
    cell.lblDoctor.text = a.title;
    cell.lblDate.text = [a formatedDateAndTime];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Appointment * a = [self.user.appointments objectAtIndex:indexPath.row];
    
    AppointmentDetails *details = [self.storyboard instantiateViewControllerWithIdentifier:@"AppointmentDetails"];
    [details setAppointment:a];
    [self.navigationController pushViewController:details animated:YES];
    
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
