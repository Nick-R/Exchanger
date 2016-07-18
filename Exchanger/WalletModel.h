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

-(NSArray*)activeAccountCodes;
-(NSNumber*)amountForCode:(NSString*)currencyCode;
-(BOOL)exchangeFrom:(NSString*)fromCode to:(NSString*)toCode amount:(NSNumber*)amount;

@end
