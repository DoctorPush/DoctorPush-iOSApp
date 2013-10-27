//
//  RKAppDelegate.h
//  DoctorPush
//
//  Created by René (Privat) on 26.10.13.
//  Copyright (c) 2013 René (Privat). All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"
#import <CoreTelephony/CoreTelephonyDefines.h>
#import "AppointmentsList.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator ;
@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) User *user;
@property (nonatomic, strong) NSString *serviceURLFromAPN;

@end
