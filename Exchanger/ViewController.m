//
//  ViewController.m
//  Exchanger
//
//  Created by Nicolas Rostov on 18.07.16.
//  Copyright © 2016 Nicolas Rostov. All rights reserved.
//

#import "ViewController.h"
#import "SourceCurrencyCell.h"
#import "DestinationCurrencyCell.h"
#import "WalletModel.h"
#import "ExchangeModel.h"

@interface ViewController () <CurrencyCellDelegate>

@property (nonatomic, weak) IBOutlet UICollectionView *srcCurrencyView;
@property (nonatomic, weak) IBOutlet UICollectionView *dstCurrencyView;

@property (nonatomic, weak) IBOutlet NSLayoutConstraint *dstCurrencyViewHeight;

@property (nonatomic, weak) IBOutlet UIPageControl *srcPageControl;
@property (nonatomic, weak) IBOutlet UIPageControl *dstPageControl;

@property (nonatomic, weak) IBOutlet UILabel *rateLabel;
@property (nonatomic, weak) IBOutlet UIButton *rateButton;
@property (nonatomic, weak) IBOutlet UIButton *exchangeButton;

@property (nonatomic, strong) NSString *currentSrcCode;
@property (nonatomic, strong) NSString *currentDstCode;
@property (nonatomic, strong) NSNumber *currentSrcAmount;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.rateButton.layer.cornerRadius = 8;
    self.rateButton.layer.borderColor = [UIColor colorWithWhite:1 alpha:0.3].CGColor;
    self.rateButton.layer.borderWidth = 1;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateEverything)
                                                 name:RATES_UPDATE_NOTIFICATION
                                               object:nil];
    
    [self.srcCurrencyView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]
                                 atScrollPosition:UICollectionViewScrollPositionLeft
                                         animated:NO];
    self.srcPageControl.numberOfPages = [[[WalletModel sharedInstance] activeAccountCodes] count];
    [self.dstCurrencyView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]
                                 atScrollPosition:UICollectionViewScrollPositionLeft
                                         animated:NO];
    self.dstPageControl.numberOfPages = [[[WalletModel sharedInstance] activeAccountCodes] count];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self currencyScrollChanged:self.srcCurrencyView];
    [self currencyScrollChanged:self.dstCurrencyView];
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:RATES_UPDATE_NOTIFICATION object:nil];
}

// recalculates page indicator & current currency symbols
-(void)currencyScrollChanged:(UIScrollView *)scrollView {
    UIPageControl *pageControl;
    UICollectionView *collectionView;
    if(scrollView == self.dstCurrencyView) {
        collectionView = self.dstCurrencyView;
        pageControl = self.dstPageControl;
    }
    else {
        collectionView = self.srcCurrencyView;
        pageControl = self.srcPageControl;
    }
    
    NSInteger page = lround(scrollView.contentOffset.x / scrollView.frame.size.width);
    NSInteger currentIndex = page-1;
    NSArray *accounts = [[WalletModel sharedInstance] activeAccountCodes];
    if (page == 0) {
        [collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:[accounts count] inSection:0]
                               atScrollPosition:UICollectionViewScrollPositionLeft
                                       animated:NO];
        currentIndex = [accounts count] - 1;
    } else if (page == [accounts count] + 1) {
        [collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]
                               atScrollPosition:UICollectionViewScrollPositionLeft
                                       animated:NO];
        currentIndex = 0;
    }
    pageControl.currentPage = currentIndex;
    
    if(scrollView == self.dstCurrencyView) {
        self.currentDstCode = accounts[currentIndex];
    }
    else {
        self.currentSrcCode = accounts[currentIndex];
        [self performSelector:@selector(updateActiveField) withObject:nil afterDelay:0.1];
    }
    [self updateRateLabel];
    if(_currentSrcAmount)
        [self amountDidChange:_currentSrcAmount];
}

-(void)updateActiveField {
    NSIndexPath *ip = [self.srcCurrencyView indexPathForItemAtPoint:CGPointMake(self.srcCurrencyView.contentOffset.x+1, 1)];
    SourceCurrencyCell *cell = (SourceCurrencyCell*)[self.srcCurrencyView cellForItemAtIndexPath:ip];
    if(ip.row != 0 && ip.row != [[[WalletModel sharedInstance] activeAccountCodes] count]+1 && [cell.currencyCode isEqualToString:self.currentSrcCode]) {
        [cell activateCell];
    }
}

-(void)updateRateLabel {
    if(_currentSrcCode && _currentDstCode) {
        NSString *rateString = [NSString stringWithFormat:@"%@1 = %@%.4f",
                                [ExchangeModel currencySymbolForCode:_currentSrcCode],
                                [ExchangeModel currencySymbolForCode:_currentDstCode],
                                [[ExchangeModel sharedInstance] rateFor:_currentSrcCode to:_currentDstCode]];
        NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:rateString];
        [str addAttribute:NSFontAttributeName value:_rateLabel.font range:NSMakeRange(0, [rateString length]-2)];
        [str addAttribute:NSFontAttributeName value:[_rateLabel.font fontWithSize:_rateLabel.font.pointSize*0.7] range:NSMakeRange([rateString length]-2, 2)];
        self.rateLabel.attributedText = str;
    }
}

-(void)updateEverything {
    [self.srcCurrencyView reloadData];
    [self.dstCurrencyView reloadData];
    [self performSelector:@selector(updateActiveField) withObject:nil afterDelay:0.1];
    [self updateRateLabel];
}

#pragma mark actions
-(IBAction)exchangeAction:(id)sender {
    UIAlertController* alert;
    if([[WalletModel sharedInstance] exchangeFrom:self.currentSrcCode to:self.currentDstCode amount:self.currentSrcAmount]) {
        
        [self updateEverything];
        
        NSString *msg = [NSString stringWithFormat:@"Operation was successful. Now you have %@%.2f on your %@ account.", [ExchangeModel currencySymbolForCode:_currentDstCode], [[[WalletModel sharedInstance] amountForCode:_currentDstCode] doubleValue], _currentDstCode];
        alert = [UIAlertController alertControllerWithTitle:@"Success"
                                                    message:msg
                                             preferredStyle:UIAlertControllerStyleAlert];
    }
    else {
        alert = [UIAlertController alertControllerWithTitle:@"Error"
                                                    message:@"Operation wasn't successful."
                                             preferredStyle:UIAlertControllerStyleAlert];
    }
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
    [alert addAction:defaultAction];
    [self presentViewController:alert animated:YES completion:nil];
}

-(IBAction)cancelAction:(id)sender {
    [self updateEverything];
}

#pragma mark keyboard
- (void)keyboardWillShow:(NSNotification*)notification {
    NSDictionary *info = [notification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    CGFloat overlap = self.view.frame.size.height - CGRectGetMaxY(self.dstCurrencyView.frame) - kbSize.height;
    if(overlap < 0)
        self.dstCurrencyViewHeight.constant += overlap;
}

- (void)keyboardWillHide:(NSNotification*)notification {
    self.dstCurrencyViewHeight.constant = self.srcCurrencyView.frame.size.height;
}

#pragma mark CurrencyCellDelegate
-(void)amountDidChange:(NSNumber*)amount {
    self.currentSrcAmount = amount;
    [self.dstCurrencyView reloadData];

    double possibleAmount = [[[WalletModel sharedInstance] amountForCode:self.currentSrcCode] doubleValue];
    double currentValue = [_currentSrcAmount doubleValue];
    self.exchangeButton.enabled = (![_currentDstCode isEqualToString:_currentSrcCode] && currentValue > 0 && currentValue <= possibleAmount);
}

#pragma mark UICollectionView
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self currencyScrollChanged:scrollView];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [[[WalletModel sharedInstance] activeAccountCodes] count]+2;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *currencyCode;
    NSArray *accounts = [[WalletModel sharedInstance] activeAccountCodes];
    if(indexPath.row == 0)
        currencyCode = [accounts lastObject];
    else if(indexPath.row == [accounts count]+1)
        currencyCode = [accounts firstObject];
    else
        currencyCode = accounts[indexPath.row-1];
    
    if(collectionView == self.dstCurrencyView) {
        DestinationCurrencyCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"DestinationCurrencyCell" forIndexPath:indexPath];
        cell.currencyCode = currencyCode;
        cell.currencySymbol = [ExchangeModel currencySymbolForCode:currencyCode];
        cell.walletAmount = [[WalletModel sharedInstance] amountForCode:currencyCode];
        NSString *rateString = [NSString stringWithFormat:@"%@1 = %@%.2f",
                                [ExchangeModel currencySymbolForCode:_currentSrcCode],
                                [ExchangeModel currencySymbolForCode:_currentDstCode],
                                [[ExchangeModel sharedInstance] rateFor:_currentSrcCode to:_currentDstCode]];
        cell.rateString = rateString;
        cell.changeAmount = @([self.currentSrcAmount doubleValue]*[[ExchangeModel sharedInstance] rateFor:_currentSrcCode to:_currentDstCode]);
        return cell;
    }
    else {
        SourceCurrencyCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"SourceCurrencyCell" forIndexPath:indexPath];
        cell.currencyCode = currencyCode;
        cell.currencySymbol = [ExchangeModel currencySymbolForCode:currencyCode];
        cell.walletAmount = [[WalletModel sharedInstance] amountForCode:currencyCode];
        cell.delegate = self;
        return cell;
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    return collectionView.bounds.size;
}

@end
