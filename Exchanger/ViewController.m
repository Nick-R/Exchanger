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

@property (nonatomic, weak) IBOutlet NSLayoutConstraint *srcCurrencyViewHeight;
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
    // we need to know keyboard height to adopt scrollers
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    // we want to update values when rates are changed
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateUI)
                                                 name:RATES_UPDATE_NOTIFICATION
                                               object:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    // set page control values
    self.srcPageControl.numberOfPages = [[[WalletModel sharedInstance] activeAccountCodes] count];
    self.dstPageControl.numberOfPages = self.srcPageControl.numberOfPages;
    // set initial currency position, just to not have same currencies
    [self.srcCurrencyView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]
                                 atScrollPosition:UICollectionViewScrollPositionLeft
                                         animated:NO];
    [self.dstCurrencyView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]
                                 atScrollPosition:UICollectionViewScrollPositionLeft
                                         animated:NO];
    // we need to recalculate things manually as we changed scrollers programmatically
    [self currencyScrollChanged:self.srcCurrencyView];
    [self currencyScrollChanged:self.dstCurrencyView];
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:RATES_UPDATE_NOTIFICATION object:nil];
}

// recalculates page indicator & active currency symbols, activates keyboard after scroll
-(void)currencyScrollChanged:(UIScrollView *)scrollView {
    // which UI elements to change
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
    // calculate current position
    NSInteger page = lround(scrollView.contentOffset.x / scrollView.frame.size.width);
    // default index is page-1, as first element is for animation purpose
    NSInteger currentIndex = page-1;
    NSArray *accounts = [[WalletModel sharedInstance] activeAccountCodes];
    if (page == 0) {
        // user scrolls to left from first element, get him to last one behind the scene
        [collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:[accounts count] inSection:0]
                               atScrollPosition:UICollectionViewScrollPositionLeft
                                       animated:NO];
        currentIndex = [accounts count] - 1;
    } else if (page == [accounts count] + 1) {
        // user scrolls to right from last element, get him to first one behind the scene
        [collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]
                               atScrollPosition:UICollectionViewScrollPositionLeft
                                       animated:NO];
        currentIndex = 0;
    }
    pageControl.currentPage = currentIndex;
    // update active source & dest currency codes
    if(scrollView == self.dstCurrencyView) {
        self.currentDstCode = accounts[currentIndex];
    }
    else {
        self.currentSrcCode = accounts[currentIndex];
        [self performSelector:@selector(updateActiveField) withObject:nil afterDelay:0.1];
    }
    // update rate at top of screen
    [self updateRateLabel];
    // set the exchange button state. we use delegate method for this coz it has similar purpose
    if(_currentSrcAmount)
        [self amountDidChange:_currentSrcAmount];
}

// finds a source cell which is active and activates it's keyboard
// i tried indexPathForItemAtPoint but it's not as reliable
-(void)updateActiveField {
    for(SourceCurrencyCell *cell in self.srcCurrencyView.visibleCells) {
        NSIndexPath *ip = [self.srcCurrencyView indexPathForCell:cell];
 
        if(ip.row != 0 &&
           ip.row != [[[WalletModel sharedInstance] activeAccountCodes] count]+1 &&
           [cell.currencyCode isEqualToString:self.currentSrcCode]) {
            
            [cell activateCell];
            return;
        }
    }
}

// generates attributed string like €1 = $0.9000 and sets it to topmost label
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

// updates rate label and all cells without reloading data.
// we need this to not erasing user input when rates are coming.
// called after exchange, cancel and rates update.
-(void)updateUI {
    for(SourceCurrencyCell *cell in self.srcCurrencyView.visibleCells)
        [self configureSourceCell:cell];
    for(DestinationCurrencyCell *cell in self.dstCurrencyView.visibleCells)
        [self configureDestinationCell:cell];
    [self updateRateLabel];
}

#pragma mark actions
// performs exchange and shows result as alert
-(IBAction)exchangeAction:(id)sender {
    UIAlertController* alert;
    if([[WalletModel sharedInstance] exchangeFrom:self.currentSrcCode to:self.currentDstCode amount:self.currentSrcAmount]) {
        
        [self updateUI];
        [self updateActiveField];
        
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

// just erase current input, and update UI just for a case.
-(IBAction)cancelAction:(id)sender {
    [self updateUI];
    [self updateActiveField];
}

#pragma mark keyboard
// calculates scrollers height to fill the screen vertically
- (void)keyboardWillShow:(NSNotification*)notification {
    NSDictionary *info = [notification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    CGFloat height = (self.view.frame.size.height - CGRectGetMaxY(self.rateButton.frame) - kbSize.height)/2;
    self.dstCurrencyViewHeight.constant = height;
    self.srcCurrencyViewHeight.constant = height;
}

#pragma mark CurrencyCellDelegate
// we receive this delegate call after user changes input on source currency.
// updates Exchange button state: if have enough amount and not trying to convert to same currency
-(void)amountDidChange:(NSNumber*)amount {
    self.currentSrcAmount = amount;
    [self.dstCurrencyView reloadData];

    double possibleAmount = [[[WalletModel sharedInstance] amountForCode:self.currentSrcCode] doubleValue];
    double currentValue = [_currentSrcAmount doubleValue];
    self.exchangeButton.enabled = (![_currentDstCode isEqualToString:_currentSrcCode] && currentValue > 0 && currentValue <= possibleAmount);
}

#pragma mark UICollectionView
// set dynamic data for source acount cells, which is just money amount
-(void)configureSourceCell:(SourceCurrencyCell*)cell {
    cell.walletAmount = [[WalletModel sharedInstance] amountForCode:cell.currencyCode];
}

// set dynamic data for dest acount cells, which is money amount, rate string and change amount (user input * rate)
-(void)configureDestinationCell:(DestinationCurrencyCell*)cell {
    cell.walletAmount = [[WalletModel sharedInstance] amountForCode:cell.currencyCode];
    NSString *rateString = [NSString stringWithFormat:@"%@1 = %@%.2f",
                            [ExchangeModel currencySymbolForCode:_currentSrcCode],
                            [ExchangeModel currencySymbolForCode:cell.currencyCode],
                            [[ExchangeModel sharedInstance] rateFor:_currentSrcCode to:cell.currencyCode]];
    cell.rateString = rateString;
    cell.changeAmount = @([self.currentSrcAmount doubleValue]*[[ExchangeModel sharedInstance] rateFor:_currentSrcCode to:cell.currencyCode]);
}

// user has scrolled something, recalculate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self currencyScrollChanged:scrollView];
}

// we need accounts+2 cells, first and last ones will be used just for animation purposes
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [[[WalletModel sharedInstance] activeAccountCodes] count]+2;
}

// creates and configures cells
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    // currency code depends only on index
    NSString *currencyCode;
    NSArray *accounts = [[WalletModel sharedInstance] activeAccountCodes];
    if(indexPath.row == 0)
        currencyCode = [accounts lastObject];
    else if(indexPath.row == [accounts count]+1)
        currencyCode = [accounts firstObject];
    else
        currencyCode = accounts[indexPath.row-1];
    // we need to configure 2 different scrollers
    if(collectionView == self.dstCurrencyView) {
        DestinationCurrencyCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"DestinationCurrencyCell" forIndexPath:indexPath];
        // set static cell data, won't be changed later
        cell.currencyCode = currencyCode;
        cell.currencySymbol = [ExchangeModel currencySymbolForCode:currencyCode];
        // set dynamic data
        [self configureDestinationCell:cell];
        return cell;
    }
    else {
        SourceCurrencyCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"SourceCurrencyCell" forIndexPath:indexPath];
        // set static cell data, won't be changed later
        cell.currencyCode = currencyCode;
        cell.currencySymbol = [ExchangeModel currencySymbolForCode:currencyCode];
        cell.delegate = self;
        // set dynamic data
        [self configureSourceCell:cell];
        return cell;
    }
}

// configures cell sizes
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGSize result = CGSizeMake(self.view.frame.size.width, collectionView.frame.size.height);
    return result;
}

@end
