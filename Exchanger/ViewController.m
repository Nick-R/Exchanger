//
//  ViewController.m
//  Exchanger
//
//  Created by Nicolas Rostov on 18.07.16.
//  Copyright © 2016 Nicolas Rostov. All rights reserved.
//

#import "ViewController.h"

#define CURRENCIES @[@"GBP", @"USD", @"EUR"]

@interface ViewController ()

@property (nonatomic, weak) IBOutlet UICollectionView *srcCurrencyView;
@property (nonatomic, weak) IBOutlet UICollectionView *dstCurrencyView;

@property (nonatomic, weak) IBOutlet NSLayoutConstraint *dstCurrencyViewHeight;

@property (nonatomic, weak) IBOutlet UIPageControl *srcPageControl;
@property (nonatomic, weak) IBOutlet UIPageControl *dstPageControl;

@property (nonatomic, strong) NSString *srcCurrency;
@property (nonatomic, strong) NSString *dstCurrency;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.srcCurrencyView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]
                                atScrollPosition:UICollectionViewScrollPositionLeft
                                        animated:NO];
    self.srcPageControl.numberOfPages = [CURRENCIES count];
    [self currencyScrollChanged:self.srcCurrencyView];
    [self.dstCurrencyView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]
                                   atScrollPosition:UICollectionViewScrollPositionLeft
                                           animated:NO];
    self.dstPageControl.numberOfPages = [CURRENCIES count];
    [self currencyScrollChanged:self.dstCurrencyView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
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
        // Set our pagecontrol circles to the appropriate page indicator
        currentIndex = [CURRENCIES count] - 1;
    } else if (page == [CURRENCIES count] + 1) {
        [collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]
                               atScrollPosition:UICollectionViewScrollPositionLeft
                                       animated:NO];
        currentIndex = 0;
    }
    pageControl.currentPage = currentIndex;
    
    if(scrollView == self.dstCurrencyView) {
        self.dstCurrency = CURRENCIES[currentIndex];
        NSLog(@"dst: %@", self.dstCurrency);
    }
    else {
        self.srcCurrency = CURRENCIES[currentIndex];
        NSLog(@"src: %@", self.srcCurrency);
    }
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

#pragma mark UICollectionView
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self currencyScrollChanged:scrollView];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [CURRENCIES count]+2;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    NSString *currencyCode;
    if(indexPath.row == 0)
        currencyCode = [CURRENCIES lastObject];
    else if(indexPath.row == [CURRENCIES count]+1)
        currencyCode = [CURRENCIES firstObject];
    else
        currencyCode = CURRENCIES[indexPath.row-1];
    [[cell viewWithTag:1] setText:currencyCode];
    return cell;
}

@end
