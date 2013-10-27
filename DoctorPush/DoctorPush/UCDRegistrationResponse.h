//
//  UCDRegistrationResponse.h
//  LSA Kreativ
//
//  Created by René Kann on 05.04.13.
//
//

#import <Foundation/Foundation.h>

/*
HTTP Status Code: 406, json-codierter Code:
0: vendor name already exists
1: vendor mail already exists
2: mail invalid
3: user mail exists
4: user name exists
*/

@interface UCDRegistrationResponse : NSObject

@property (nonatomic, strong) NSString *vendorNameExists, *vendorMailExists, *mailInvalid, *userMailExists, *userNameExists;

- (NSMutableArray *)getTheErrors;

@end
