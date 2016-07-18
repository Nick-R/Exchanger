//
//  ExchangeModel.m
//  Exchanger
//
//  Created by Nicolas Rostov on 18.07.16.
//  Copyright © 2016 Nicolas Rostov. All rights reserved.
//

#import "ExchangeModel.h"

@implementation ExchangeModel

+(instancetype)sharedInstance {
    static ExchangeModel *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

-(double)rateFor:(NSString*)fromCode to:(NSString*)toCode {
    return 1.1;
}

+(NSString*)currencySymbolForCode:(NSString*)currencyCode {
    if(!currencyCode)
        return @"";
    NSNumberFormatter * formatter = [NSNumberFormatter new];
    formatter.numberStyle = NSNumberFormatterCurrencyStyle;
    
    NSString * localeIde = [NSLocale localeIdentifierFromComponents:@{NSLocaleCurrencyCode: currencyCode}];
    formatter.locale = [NSLocale localeWithLocaleIdentifier:localeIde];
    NSString * symbol = formatter.currencySymbol;
    return symbol;
}

@end
