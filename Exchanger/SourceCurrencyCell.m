//
//  SourceCurrencyCell.m
//  Exchanger
//
//  Created by Nicolas Rostov on 18.07.16.
//  Copyright © 2016 Nicolas Rostov. All rights reserved.
//

#define FONT_LARGE [UIFont fontWithName:@"HelveticaNeue-Light" size:36 * [[UIScreen mainScreen] bounds].size.width / 320]
#define FONT_SMALL [UIFont fontWithName:@"HelveticaNeue-Light" size:17 * [[UIScreen mainScreen] bounds].size.width / 320]

#import "SourceCurrencyCell.h"

#define WALLET_COLOR_NORMAL [[UIColor whiteColor] colorWithAlphaComponent:0.75]
#define WALLET_COLOR_ERROR [[UIColor redColor] colorWithAlphaComponent:0.75]

@interface SourceCurrencyCell ()

@property (nonatomic, weak) IBOutlet UILabel *currencyCodeLabel;
@property (nonatomic, weak) IBOutlet UILabel *walletLabel;
@property (nonatomic, weak) IBOutlet UITextField *amountField;

@end

@implementation SourceCurrencyCell

-(void)prepareForReuse {
    self.amountField.text = @"";
    [self.delegate amountDidChange:@(0)];
    self.walletLabel.textColor = WALLET_COLOR_NORMAL;
    
    self.currencyCodeLabel.font = FONT_LARGE;
    self.amountField.font = FONT_LARGE;
    self.walletLabel.font = FONT_SMALL;
}

-(void)activateCell {
    self.amountField.text = @"";
    [self.delegate amountDidChange:@(0)];
    [self.amountField becomeFirstResponder];
}

-(IBAction)textFieldDidChange:(UITextField *)textField {
    if([textField.text length] > 7)
        textField.text = [textField.text substringToIndex:7];
    int value = abs([textField.text intValue]);
    if([_walletAmount doubleValue] >= value)
        self.walletLabel.textColor = WALLET_COLOR_NORMAL;
    else
        self.walletLabel.textColor = WALLET_COLOR_ERROR;
    textField.text = [NSString stringWithFormat:@"- %i", value];
    [self.delegate amountDidChange:@(value)];
}

-(void)setCurrencyCode:(NSString *)currencyCode {
    _currencyCode = currencyCode;
    self.currencyCodeLabel.text = currencyCode;
}

-(void)setWalletAmount:(NSNumber *)walletAmount {
    _walletAmount = walletAmount;
    self.walletLabel.text = [NSString stringWithFormat:@"You have %@%.2f", _currencySymbol, [_walletAmount doubleValue]];
}

@end
