//
//  ModelHandler.h
//  Simple_VK_Client
//
//  Created by Dmitriy on 10/10/14.
//  Copyright (c) 2014 ALS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import <AFNetworking/AFNetworking.h>
#import "NewsViewController.h"

#define FETCH_RESULT_CONTROLLER_CACHE_NAME @"cache"
#define FETCH_RESULT_CONTROLLER_SORT_DESCRIPTOR @"date"

typedef void (^ SuccessLoadBlock)(void);
typedef void (^ FailureLoadBlock)(void);

static AFHTTPRequestOperationManager *requestOprationManager;
static NSString *fromLoadString;
static NSFetchedResultsController *fetchedResultsController;
static NSManagedObjectContext *managedObjectContext;

@interface ModelHandler : NSObject

+ (void)initModelHandler;
+ (void)saveResponseObject:(NSMutableDictionary*)responseObject;
+ (void)returnClearManagedObjectContext;
+ (NSString*)fromFieldInResponse:(NSMutableDictionary*)responseObject;
+ (NSMutableDictionary*)formNewsParametersWithRefreshing:(BOOL)isRefreshing andFromString:(NSString*)fromLoadString;
+ (void)getNewsFromVKWithSuccessBlock:(SuccessLoadBlock)successBlock failureBlock:(FailureLoadBlock)failureBlock isRefreshing:(BOOL)isRefreshing;
+ (void)quitVK;
+ (UIImageView*)setImageWithURLString:(NSString *)urlString successBlock:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image))successBlock failureBlock:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error))failureBlock toImageView:(UIImageView*)imageView;
+ (NSFetchedResultsController *)fetchedResultsController;
+ (void)initCoreDataWithManagedObjectContext:(NSManagedObjectContext*)resievedManagedObjectContext;
+ (NewsItem*)loadNewsItemOnIndexPath:(NSIndexPath*)indexPath;
+ (void)deleteFetchResultControllerCache;

@end

