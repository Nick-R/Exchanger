//
//  DestinationCurrencyCell.m
//  Exchanger
//
//  Created by Nicolas Rostov on 18.07.16.
//  Copyright © 2016 Nicolas Rostov. All rights reserved.
//

#define FONT_LARGE [UIFont fontWithName:@"HelveticaNeue-Light" size:36 * [[UIScreen mainScreen] bounds].size.width / 320]
#define FONT_SMALL [UIFont fontWithName:@"HelveticaNeue-Light" size:17 * [[UIScreen mainScreen] bounds].size.width / 320]

#import "DestinationCurrencyCell.h"

@interface DestinationCurrencyCell ()

@property (nonatomic, weak) IBOutlet UILabel *currencyCodeLabel;
@property (nonatomic, weak) IBOutlet UILabel *walletLabel;
@property (nonatomic, weak) IBOutlet UILabel *amountLabel;
@property (nonatomic, weak) IBOutlet UILabel *rateLabel;

@end

@implementation DestinationCurrencyCell

-(void)prepareForReuse {
    self.currencyCodeLabel.font = FONT_LARGE;
    self.amountLabel.font = FONT_LARGE;
    self.walletLabel.font = FONT_SMALL;
    self.rateLabel.font = FONT_SMALL;
}

-(void)setCurrencyCode:(NSString *)currencyCode {
    _currencyCode = currencyCode;
    self.currencyCodeLabel.text = currencyCode;
}

-(void)setWalletAmount:(NSNumber *)walletAmount {
    _walletAmount = walletAmount;
    self.walletLabel.text = [NSString stringWithFormat:@"You have %@%.2f", _currencySymbol, [_walletAmount doubleValue]];
}

-(void)setRateString:(NSString *)rateString {
    _rateString = rateString;
    self.rateLabel.text = _rateString;
}

-(void)setChangeAmount:(NSNumber *)changeAmount {
    _changeAmount = changeAmount;
    NSString *amountString = [NSString stringWithFormat:@"+ %.2f", [_changeAmount doubleValue]];
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:amountString];
    [str addAttribute:NSFontAttributeName value:_currencyCodeLabel.font range:NSMakeRange(0, [amountString length]-2)];
    [str addAttribute:NSFontAttributeName value:[_currencyCodeLabel.font fontWithSize:_currencyCodeLabel.font.pointSize/2] range:NSMakeRange([amountString length]-2, 2)];
    self.amountLabel.attributedText = str;
}

@end
