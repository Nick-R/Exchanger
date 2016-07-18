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

#define CURRENCIES @[@"GBP", @"USD", @"EUR"]

@interface ViewController () <CurrencyCellDelegate>

@property (nonatomic, weak) IBOutlet UICollectionView *srcCurrencyView;
@property (nonatomic, weak) IBOutlet UICollectionView *dstCurrencyView;

@property (nonatomic, weak) IBOutlet NSLayoutConstraint *dstCurrencyViewHeight;

@property (nonatomic, weak) IBOutlet UIPageControl *srcPageControl;
@property (nonatomic, weak) IBOutlet UIPageControl *dstPageControl;

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
    
    [self.srcCurrencyView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]
                                 atScrollPosition:UICollectionViewScrollPositionLeft
                                         animated:NO];
    self.srcPageControl.numberOfPages = [CURRENCIES count];
    [self.dstCurrencyView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]
                                 atScrollPosition:UICollectionViewScrollPositionLeft
                                         animated:NO];
    self.dstPageControl.numberOfPages = [CURRENCIES count];
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
    if (page == 0) {
        [collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:[CURRENCIES count] inSection:0]
                               atScrollPosition:UICollectionViewScrollPositionLeft
                                       animated:NO];
        currentIndex = [CURRENCIES count] - 1;
    } else if (page == [CURRENCIES count] + 1) {
        [collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]
                               atScrollPosition:UICollectionViewScrollPositionLeft
                                       animated:NO];
        currentIndex = 0;
    }
    pageControl.currentPage = currentIndex;
    
    if(scrollView == self.dstCurrencyView) {
        self.currentDstCode = CURRENCIES[currentIndex];
    }
    else {
        self.currentSrcCode = CURRENCIES[currentIndex];
        [self performSelector:@selector(updateActiveField) withObject:nil afterDelay:0.1];
    }
    NSString *rateString = [NSString stringWithFormat:@"$1 = $1"];
    [self.rateButton setTitle:rateString forState:UIControlStateNormal];
}

-(void)updateActiveField {
    NSIndexPath *ip = [self.srcCurrencyView indexPathForItemAtPoint:CGPointMake(self.srcCurrencyView.contentOffset.x+1, 1)];
    SourceCurrencyCell *cell = (SourceCurrencyCell*)[self.srcCurrencyView cellForItemAtIndexPath:ip];
    if(ip.row != 0 && ip.row != [CURRENCIES count]+1 && [cell.currencyCode isEqualToString:self.currentSrcCode]) {
        [cell activateCell];
    }
}

#pragma mark actions 
-(IBAction)exchangeAction:(id)sender {
    
}

-(IBAction)cancelAction:(id)sender {
    [self.srcCurrencyView reloadData];
    [self performSelector:@selector(updateActiveField) withObject:nil afterDelay:0.1];
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

    self.exchangeButton.enabled = ([_currentSrcAmount intValue] <= 100);
}

#pragma mark UICollectionView
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self currencyScrollChanged:scrollView];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [CURRENCIES count]+2;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *currencyCode;
    if(indexPath.row == 0)
        currencyCode = [CURRENCIES lastObject];
    else if(indexPath.row == [CURRENCIES count]+1)
        currencyCode = [CURRENCIES firstObject];
    else
        currencyCode = CURRENCIES[indexPath.row-1];
    
    if(collectionView == self.dstCurrencyView) {
        DestinationCurrencyCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"DestinationCurrencyCell" forIndexPath:indexPath];
        cell.currencyCode = currencyCode;
        cell.walletAmount = @(100);
        cell.rateString = @"$1 = $1";
        cell.changeAmount = @([self.currentSrcAmount doubleValue]*2);
        return cell;
    }
    else {
        SourceCurrencyCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"SourceCurrencyCell" forIndexPath:indexPath];
        cell.currencyCode = currencyCode;
        NSLog(@"currencyCode: %@", currencyCode);
        cell.walletAmount = @(100);
        cell.delegate = self;
        return cell;
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    return collectionView.bounds.size;
}

@end
