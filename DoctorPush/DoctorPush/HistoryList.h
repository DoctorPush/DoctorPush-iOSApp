//
//  HistoryList.h
//  DoctorPush
//
//  Created by René (Privat) on 27.10.13.
//  Copyright (c) 2013 René (Privat). All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Appointment.h"
#import "HistoryTableCell.h"
#import "HistoryItem.h"

@interface HistoryList : UITableViewController
@property (nonatomic, strong) Appointment *appointment;
@end
