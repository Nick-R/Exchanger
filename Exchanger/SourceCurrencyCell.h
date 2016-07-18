//
//  SourceCurrencyCell.h
//  Exchanger
//
//  Created by Nicolas Rostov on 18.07.16.
//  Copyright © 2016 Nicolas Rostov. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CurrencyCellDelegate

-(void)amountDidChange:(NSNumber*)amount;

@end

@interface SourceCurrencyCell : UICollectionViewCell

@property id<CurrencyCellDelegate> delegate;

@property (nonatomic, strong) NSString *currencyCode;
@property (nonatomic, strong) NSNumber *walletAmount;

-(void)activateCell;

@end
