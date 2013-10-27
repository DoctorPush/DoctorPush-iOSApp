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
    [self initUser];
    [self setupLocationManager];
}

- (void)setupLocationManager {
    self.locationManager = [[UCDLocationManager alloc] init];
	[self.locationManager setDelegate:self];
	[self.locationManager initLocationUpdates];
}

- (void)initUser {
    
    [self.appointsTable setHidden:YES];
    [ProgressHUD show:@"Termine werden geladen..."];
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    self.user = appDelegate.user;
    [self.user setDelegate:self];
    [self.user getAllAppointments];
}

- (void)appointmentsLoaded {
    [ProgressHUD dismiss];
    
    [self.appointsTable setHidden:NO];
    [self.appointsTable reloadData];
    
}

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
