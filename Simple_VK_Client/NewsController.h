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
#import <CCBottomRefreshControl/UIScrollView+BottomRefreshControl.h>
#import "DetailView.h"
#import "DictionaryOfCachedImages.h"

@interface NewsController : UITableViewController <NSFetchedResultsControllerDelegate, UIScrollViewDelegate>

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property AFHTTPRequestOperationManager *requestOprationManager;
@property NSMutableArray *arrayOfIndexPathesOfCellsWithImages;
@property NSMutableDictionary *responseDictionary;
@property BOOL isRefreshing;
@property NSMutableDictionary *imageDictionaryOfURLs;
@property BOOL isLoading;

- (IBAction)exitButton:(id)sender;

@end

typedef void (^ SuccessLoadBlock)(void);
typedef void (^ FailureLoadBlock)(void);

enum
{
    NUMBER_OF_NEWS_PER_LOAD = 5,
};
