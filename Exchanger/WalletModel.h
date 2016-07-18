//
//  WalletModel.h
//  Exchanger
//
//  Created by Nicolas Rostov on 18.07.16.
//  Copyright © 2016 Nicolas Rostov. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WalletModel : NSObject

+(instancetype)sharedInstance;

// returns available account codes
-(NSArray*)activeAccountCodes;
// returns account balance by code
-(NSNumber*)amountForCode:(NSString*)currencyCode;
// performs exchange
-(BOOL)exchangeFrom:(NSString*)fromCode to:(NSString*)toCode amount:(NSNumber*)amount;

@end
