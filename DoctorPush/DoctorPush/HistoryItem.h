//
//  HistoryItem.h
//  DoctorPush
//
//  Created by René (Privat) on 27.10.13.
//  Copyright (c) 2013 René (Privat). All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HistoryItem : NSObject
@property (nonatomic, strong) NSString *recipient_id, *recipient_type, *trackable_type, *owner_type, *key;
@property (nonatomic, readwrite) int hid, owner_id, trackable_id;
@property (nonatomic, strong) NSDate *created_at, *updated_at;
@property (nonatomic, strong) NSMutableArray *parameters;
@end
