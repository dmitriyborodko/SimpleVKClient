//
//  NewsController.h
//  Simple_VK_Client
//
//  Created by Dmitriy on 30/09/14.
//  Copyright (c) 2014 ALS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AFNetworking/AFNetworking.h>
#import <CoreData/CoreData.h>
#import "DetailView.h"

#define NEWS_CELL_IDENTIFIER @"newsCell"

@interface NewsController : UITableViewController <NSFetchedResultsControllerDelegate, UIScrollViewDelegate>

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property AFHTTPRequestOperationManager *requestOprationManager;
@property NSMutableArray *arrayOfIndexPathesOfCellsWithImages;
@property NSMutableDictionary *responseDictionary;
@property BOOL isRefreshing;
@property BOOL isLoading;
@property NSString *fromLoadString;
@property UIActivityIndicatorView *activityIndicatorView;
@property NSDateFormatter *dateFormat;

- (IBAction)exitButton:(id)sender;
@property (weak, nonatomic) IBOutlet UIView *bottomView;

@end

typedef void (^ SuccessLoadBlock)(void);
typedef void (^ FailureLoadBlock)(void);
