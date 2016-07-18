//
//  DestinationCurrencyCell.h
//  Exchanger
//
//  Created by Nicolas Rostov on 18.07.16.
//  Copyright © 2016 Nicolas Rostov. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DestinationCurrencyCell : UICollectionViewCell

@property (nonatomic, strong) NSString *currencyCode;
@property (nonatomic, strong) NSString *currencySymbol;
@property (nonatomic, strong) NSNumber *walletAmount;
@property (nonatomic, strong) NSString *rateString;
@property (nonatomic, strong) NSNumber *changeAmount;

@end
