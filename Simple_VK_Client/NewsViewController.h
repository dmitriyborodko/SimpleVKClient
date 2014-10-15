//
//  NewsController.h
//  Simple_VK_Client
//
//  Created by Dmitriy on 30/09/14.
//  Copyright (c) 2014 ALS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "DetailView.h"

#define NEWS_CELL_IDENTIFIER @"newsCell"

static NSDateFormatter *dateFormat;

@interface NewsViewController : UITableViewController <NSFetchedResultsControllerDelegate, UIScrollViewDelegate>

@property NSMutableArray *arrayOfIndexPathesOfCellsWithImages;
@property BOOL isRefreshing;
@property BOOL isLoading;
@property NSString *fromLoadString;
@property UIActivityIndicatorView *activityIndicatorView;

@property (weak, nonatomic) IBOutlet UIView *bottomView;

- (IBAction)exitButton:(id)sender;

+ (NewsViewController *) sharedInstance;

@end

typedef void (^ SuccessLoadBlock)(void);
typedef void (^ FailureLoadBlock)(void);
