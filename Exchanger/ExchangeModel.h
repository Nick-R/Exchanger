//
//  ExchangeModel.h
//  Exchanger
//
//  Created by Nicolas Rostov on 18.07.16.
//  Copyright © 2016 Nicolas Rostov. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ExchangeModel : NSObject

+(instancetype)sharedInstance;

-(double)rateFor:(NSString*)fromCode to:(NSString*)toCode;

+(NSString*)currencySymbolForCode:(NSString*)currencyCode;

@end
