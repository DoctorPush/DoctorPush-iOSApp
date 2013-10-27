//
//  Medic.h
//  DoctorPush
//
//  Created by René (Privat) on 27.10.13.
//  Copyright (c) 2013 René (Privat). All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Medic : NSObject

@property (nonatomic, strong) NSString *mid, *name, *prename, *title;
@property (nonatomic, strong) NSString *address;
@property (nonatomic, strong) NSDate *created_at, *updated_at;

- (NSString *)formatedName;

@end
