//
//  NewsController.h
//  Simple_VK_Client
//
//  Created by Dmitriy on 30/09/14.
//  Copyright (c) 2014 ALS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AFNetworking.h>
#import <CoreData/CoreData.h>

//#define NewsItemString @"NewsItem";

@interface NewsController : UITableViewController

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property AFHTTPRequestOperationManager *requestOprationManager;
@property NSMutableArray *arrayOfIndexPathesOfCellsWithImages;
@property NSMutableDictionary *responseDictionary;
@property BOOL isFirstRequestResponsed;

- (IBAction)exitButton:(id)sender;



@end

typedef void (^ SuccessLoadBlock)(void);
typedef void (^ FailureLoadBlock)(void);

enum
{
    NUMBER_OF_NEWS_PER_LOAD_TWO = 20,
};
