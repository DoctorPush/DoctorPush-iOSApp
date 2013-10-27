//
//  UCDRegistrationResponse.m
//  LSA Kreativ
//
//  Created by René Kann on 05.04.13.
//
//

#import "UCDRegistrationResponse.h"

@interface UCDRegistrationResponse ()
@property (nonatomic, strong) NSMutableArray *errors;
@end

@implementation UCDRegistrationResponse

- (NSString *)description {
	return [NSString stringWithFormat:@"%@ %@ %@ %@ %@", self.vendorNameExists, self.vendorMailExists, self.mailInvalid, self.userMailExists, self.userNameExists];
}

- (NSMutableArray *)getTheErrors {
	
	if(!self.errors) {
		self.errors = [[NSMutableArray alloc] init];
	}
	
	[self.errors removeAllObjects];
	
	if(self.vendorNameExists) {
		[self.errors addObject:@"Unternehmensname bereits vergeben."];
	}
	
	if(self.vendorMailExists) {
		[self.errors addObject:@"E-Mailadresse bereits vergeben."];
	}
	
	if(self.mailInvalid) {
		[self.errors addObject:@"E-Mailadresse nicht korrekt oder im falschen Format."];
	}
	
	if(self.userMailExists) {
		[self.errors addObject:@"E-Mailadresse bereits vergeben."];
	}
	
	if(self.userNameExists) {
		[self.errors addObject:@"Benutzername bereits vergeben."];
	}
	
	return self.errors;
}

@end
