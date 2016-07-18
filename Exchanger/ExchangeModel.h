//
//  ExchangeModel.h
//  Exchanger
//
//  Created by Nicolas Rostov on 18.07.16.
//  Copyright © 2016 Nicolas Rostov. All rights reserved.
//

#import <Foundation/Foundation.h>

// we'll post this notification after rates update
// i used notification as we can have multiple subscribers for this event in future
#define RATES_UPDATE_NOTIFICATION @"RATES_UPDATE_NOTIFICATION"

@interface ExchangeModel : NSObject

+(instancetype)sharedInstance;

// returns exchange rate for currency codes
-(double)rateFor:(NSString*)fromCode to:(NSString*)toCode;

// utility method to receive currency symbol by code
+(NSString*)currencySymbolForCode:(NSString*)currencyCode;

@end
