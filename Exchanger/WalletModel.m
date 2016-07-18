//
//  WalletModel.m
//  Exchanger
//
//  Created by Nicolas Rostov on 18.07.16.
//  Copyright © 2016 Nicolas Rostov. All rights reserved.
//

#define ACTIVE_CODES @[@"GBP", @"USD", @"EUR"]

#import "WalletModel.h"
#import "ExchangeModel.h"

@implementation WalletModel

+(instancetype)sharedInstance {
    static WalletModel *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
        
        // initialize wallet testing values if need
        if([[NSUserDefaults standardUserDefaults] valueForKey:ACTIVE_CODES[0]] == nil) {
            for(NSString *code in ACTIVE_CODES)
                [[NSUserDefaults standardUserDefaults] setDouble:100. forKey:code];
        }
    });
    return sharedInstance;
}

-(NSArray*)activeAccountCodes {
    return ACTIVE_CODES;
}

-(NSNumber*)amountForCode:(NSString*)currencyCode {
    return [[NSUserDefaults standardUserDefaults] valueForKey:currencyCode];
}

-(BOOL)exchangeFrom:(NSString*)fromCode to:(NSString*)toCode amount:(NSNumber*)amount {
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    double fromValue = [def doubleForKey:fromCode];
    double toValue = [def doubleForKey:toCode];
    
    if(fromValue >= [amount doubleValue]) {
        fromValue -= [amount doubleValue];
        double rate = [[ExchangeModel sharedInstance] rateFor:fromCode to:toCode];
        toValue += [amount doubleValue]*rate;
        [def setDouble:fromValue forKey:fromCode];
        [def setDouble:toValue forKey:toCode];
        [def synchronize];
        return YES;
    }
    return NO;
}

@end
