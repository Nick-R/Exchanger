//
//  ExchangeModel.m
//  Exchanger
//
//  Created by Nicolas Rostov on 18.07.16.
//  Copyright © 2016 Nicolas Rostov. All rights reserved.
//

#import "ExchangeModel.h"
#import "XMLDictionary.h"

@interface ExchangeModel ()

@property (nonatomic, strong) NSDictionary *rates;

@end

@implementation ExchangeModel

+(instancetype)sharedInstance {
    static ExchangeModel *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
        [[NSTimer scheduledTimerWithTimeInterval:30 target:sharedInstance selector:@selector(loadRates) userInfo:nil repeats:YES] fire];
    });
    return sharedInstance;
}

-(void)loadRates {
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        @try {
            NSURL *url = [[NSURL alloc]initWithString:@"http://www.ecb.europa.eu/stats/eurofxref/eurofxref-daily.xml"];
            NSData *data = [[NSData alloc] initWithContentsOfURL:url];
            NSDictionary *xmlDictionary = [[XMLDictionaryParser new] dictionaryWithData:data];
            
            NSMutableDictionary *updatedRates = [NSMutableDictionary new];
            for(NSDictionary *item in xmlDictionary[@"Cube"][@"Cube"][@"Cube"]) {
                [updatedRates setObject:item[@"_rate"] forKey:item[@"_currency"]];
            }
            self.rates = [updatedRates copy];
            
        } @catch (NSException *exception) {
            NSLog(@"loading rates exception: %@", exception);
        } @finally {
            dispatch_async(dispatch_get_main_queue(), ^(void){
                [[NSNotificationCenter defaultCenter] postNotificationName:RATES_UPDATE_NOTIFICATION object:self];
            });
        }
    });
}

-(double)rateFor:(NSString*)fromCode to:(NSString*)toCode {
    double value1, value2;
    if([fromCode isEqualToString:@"EUR"])
        value1 = 1;
    else
        value1 = 1/[self.rates[fromCode] doubleValue];
    if([toCode isEqualToString:@"EUR"])
        value2 = 1;
    else
        value2 = [self.rates[toCode] doubleValue];
    return value1 * value2;
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
