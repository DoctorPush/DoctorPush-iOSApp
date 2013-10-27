//
//  RKAppDelegate.m
//  DoctorPush
//
//  Created by René (Privat) on 26.10.13.
//  Copyright (c) 2013 René (Privat). All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()
@property (nonatomic, readwrite) BOOL registeredForPN;
@end

@implementation AppDelegate

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;

@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;
@synthesize user, serviceURLFromAPN;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    NSDictionary *remoteNotif = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    
    if(remoteNotif)
    {
        self.serviceURLFromAPN = [remoteNotif valueForKey:@"serviceURL"];
    }
    
    //self.serviceURLFromAPN = @"https://rawgithub.com/DoctorPush/doctor/master/appointment_test2.json";
    
    
    // setup RestKit and StoreManager
    [self setupObjectManager];
    
    // setup user
    [self setupUser];
    
    // init for PushNotes
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound)];
    
    return YES;
}

-(void)application:(UIApplication *)app didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    if([app applicationState] == UIApplicationStateInactive)
    {
        //If the application state was inactive, this means the user pressed an action button
        // from a notification.
        
        //Handle notification
        if(userInfo)
        {
            self.serviceURLFromAPN = [userInfo valueForKey:@"serviceURL"];
            [self.user setANewServiceURL:self.serviceURLFromAPN];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"RefreshAppointments" object:nil];
            
        }
    }
}

- (void)setupUser {
    
    NSString *phone = @"+491604421713";
    self.user = [[User alloc] init];
    self.user.phonenumber = phone;
    
    //[self.user deleteAllAppointmentSettings];
    
    if(self.serviceURLFromAPN) {
        [self.user setANewServiceURL:self.serviceURLFromAPN];
        self.serviceURLFromAPN = nil;
    }
    
    //[self.user addAppointmentWithServiceURL:@"https://rawgithub.com/DoctorPush/doctor/master/appointment_test.json"];
    //[self.user addAppointmentWithServiceURL:@"https://rawgithub.com/DoctorPush/doctor/master/appointment_test2.json"];
}

- (void)setupObjectManager
{
    //let AFNetworking manage the activity indicator
    [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;
    
    RKLogConfigureByName("RestKit", RKLogLevelTrace);
    RKLogConfigureByName("RestKit/Network", RKLogLevelDebug);
    RKLogConfigureByName("RestKit/ObjectMapping", RKLogLevelDebug);
    RKLogConfigureByName("RestKit/Network/Queue", RKLogLevelDebug);
	RKLogConfigureByName("RestKit/Network", RKLogLevelTrace);
	RKLogConfigureByName("RestKit/ObjectMapping", RKLogLevelTrace);
    RKLogSetAppLoggingLevel(RKLogLevelTrace);
	RKLogDebug(@"RestKit example test is starting up...");
    
    NSString *baseUrl = @"https://rawgithub.com/DoctorPush/doctor/master";
    
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:baseUrl]];
    [httpClient setDefaultHeader:@"Accept" value:RKMIMETypeJSON];
	[httpClient setParameterEncoding:AFJSONParameterEncoding];
    
    RKObjectManager *manager = [[RKObjectManager alloc]
                                initWithHTTPClient:httpClient];
    
    //[RKMIMETypeSerialization registerClass:[RKNSJSONSerialization class] forMIMEType:@"text/plain"];
    
    [manager.HTTPClient setParameterEncoding:AFJSONParameterEncoding];
	[manager.operationQueue setMaxConcurrentOperationCount:3];
 
    //[manager setAcceptHeaderWithMIMEType:RKMIMETypeJSON];
    //manager.requestSerializationMIMEType = RKMIMETypeJSON;

    //[RKObjectManager setSharedManager:manager];
}

// 1
- (NSManagedObjectContext *) managedObjectContext {
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator: coordinator];
    }
    
    return _managedObjectContext;
}

//2
- (NSManagedObjectModel *)managedObjectModel {
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    _managedObjectModel = [NSManagedObjectModel mergedModelFromBundles:nil];
    
    return _managedObjectModel;
}

//3
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    NSURL *storeUrl = [NSURL fileURLWithPath: [[self applicationDocumentsDirectory]
                                               stringByAppendingPathComponent: @"DoctorPush.sqlite"]];
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc]
                                   initWithManagedObjectModel:[self managedObjectModel]];
    if(![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType
                                                  configuration:nil URL:storeUrl options:nil error:&error]) {
        /*Error for store creation should be handled in here*/
    }
    
    return _persistentStoreCoordinator;
}

- (NSString *)applicationDocumentsDirectory {
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}

// Delegation methods

- (void)application:(UIApplication *)app didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)devToken {
    
    NSString* deviceTokenString = [[NSString alloc] initWithString: [devToken description]];
    self.user.apn_id = deviceTokenString;
    
    //[self.user registerAPNID];
}



- (void)application:(UIApplication *)app didFailToRegisterForRemoteNotificationsWithError:(NSError *)err {
    
    NSLog(@"Error in registration. Error: %@", err);
}


- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
