//
//  PodcastsTableCell.h
//  DoctorPush
//
//  Created by René Kann on 19.03.10.
//  Copyright (c) 2013 René (Privat). All rights reserved.
//
// UPDATE in der .h Datei

#import <UIKit/UIKit.h>

@interface AppointmentCell : UITableViewCell {
	
}

@property (weak, nonatomic) IBOutlet UILabel *lblDate;
@property (weak, nonatomic) IBOutlet UILabel *lblDoctor, *lblAddress;

@end
