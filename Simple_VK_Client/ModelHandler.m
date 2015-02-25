//
//  ModelHandler.m
//  Simple_VK_Client
//
//  Created by Dmitriy on 10/10/14.
//  Copyright (c) 2014 ALS. All rights reserved.
//

#import "ModelHandler.h"
#import "NewsItem.h"
#import <AFNetworking/UIKit+AFNetworking.h>


@implementation ModelHandler

+ (void)initModelHandler{
    requestOprationManager = [AFHTTPRequestOperationManager manager];
}

+ (void)initCoreDataWithManagedObjectContext:(NSManagedObjectContext*)resievedManagedObjectContext{
    managedObjectContext = resievedManagedObjectContext;
}

+ (NSFetchedResultsController *)fetchedResultsController{
    if (fetchedResultsController != nil) {
        return fetchedResultsController;
    }
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:ENTITY_NEWS_ITEM];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:FETCH_RESULT_CONTROLLER_SORT_DESCRIPTOR ascending:NO];
    NSArray *sortDescriptors = @[sortDescriptor];
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:managedObjectContext sectionNameKeyPath:nil cacheName:FETCH_RESULT_CONTROLLER_CACHE_NAME];
    NewsViewController *newsViewController = [NewsViewController sharedInstance];
    aFetchedResultsController.delegate = newsViewController;
    fetchedResultsController = aFetchedResultsController;
    NSError *error = nil;
    if (![self.fetchedResultsController performFetch:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    return fetchedResultsController;
}

+ (void)getNewsFromVKWithSuccessBlock:(SuccessLoadBlock)successBlock failureBlock:(FailureLoadBlock)failureBlock isRefreshing:(BOOL)isRefreshing{
    NSString *URLString = GET_NEWS_FEED_URL;
    NSMutableDictionary *parameters = [ModelHandler formNewsParametersWithRefreshing:isRefreshing andFromString:fromLoadString];
    
    //     News in JSON
    [requestOprationManager GET:URLString parameters:parameters success:^(AFHTTPRequestOperation *operation, NSMutableDictionary *responseObject) {
        //        NSLog(@"JSON: %@", responseObject);
        NSLog(@"request DONE");
        //        self.responseDictionary = responseObject;
        if (isRefreshing) {
            [ModelHandler returnClearManagedObjectContext];
        }
        [ModelHandler saveResponseObject:responseObject];
        [managedObjectContext save:nil];
        successBlock();
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        failureBlock();
        UIAlertView *alertError = [[UIAlertView alloc] initWithTitle:@"Connection error" message:[error description] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alertError show];
    }];
}

+ (void)saveResponseObject:(NSMutableDictionary*)responseObject {
    for (NSDictionary *itemDictionary in (NSArray*)[[responseObject objectForKey:@"response"] objectForKey:@"items"]) {
        NSString *postSenderID = [itemDictionary objectForKey:@"source_id"];
        NSLog(@"   check  %@ " , postSenderID);
        
        NewsItem *newsItem = [NSEntityDescription insertNewObjectForEntityForName:@"NewsItem" inManagedObjectContext:managedObjectContext];
        
        //Date
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:[[itemDictionary objectForKey:@"date"] longLongValue]];
        newsItem.date = date;
        
        //Text
        if ([itemDictionary objectForKey:@"text"]) {
            newsItem.text =[itemDictionary objectForKey:@"text"];
        }
        
        //Image for preview
        if ([[[itemDictionary objectForKey:@"attachment"] objectForKey:@"type"]  isEqual: @"photo"]) {
            NSURL *urlForImageOneBig = [NSURL URLWithString:[[[itemDictionary objectForKey:@"attachment"] objectForKey:@"photo"] objectForKey:@"src_big"]];
            NSURL *urlForImageOne = [NSURL URLWithString:[[[itemDictionary objectForKey:@"attachment"] objectForKey:@"photo"] objectForKey:@"src"]];
            if (urlForImageOneBig) {
                newsItem.imageURL = [urlForImageOneBig absoluteString];
            } else {
                newsItem.imageURL = [urlForImageOne absoluteString];
            }
        }
        
        //More images
        NSMutableArray *arrayOfImages = [[NSMutableArray alloc] init];
        for (NSDictionary *attachmentItem in [itemDictionary objectForKey:@"attachments"]) {
            [attachmentItem objectForKey:@"photo"];
            if ([[attachmentItem objectForKey:@"type"]  isEqual: @"photo"]) {
                NSURL *urlForImageBig = [NSURL URLWithString:[[attachmentItem objectForKey:@"photo"] objectForKey:@"src_big"]];
                NSURL *urlForImage = [NSURL URLWithString:[[attachmentItem objectForKey:@"photo"] objectForKey:@"src"]];
                if (urlForImageBig) {
                    [arrayOfImages addObject:urlForImageBig];
                } else {
                    [arrayOfImages addObject:urlForImage];
                }
            }
        }
        NSData *arrayData = [NSKeyedArchiver archivedDataWithRootObject:arrayOfImages];
        newsItem.dataWithArrayOfImages = arrayData;
        
        //Likes
        newsItem.likes = [[[itemDictionary objectForKey:@"likes"] objectForKey:@"count"] stringValue];
        
        //Reposts
        newsItem.reposts = [[[itemDictionary objectForKey:@"reposts"] objectForKey:@"count"] stringValue];
        
        if ([postSenderID integerValue] > 0) {
            for (NSDictionary *profile in [[responseObject objectForKey:@"response"] objectForKey:@"profiles"]) {
                if ([[profile objectForKey:@"uid"] integerValue] == [postSenderID integerValue]) {
                    
                    //Name (Profile)
                    newsItem.name = [[[profile objectForKey:@"first_name"] stringByAppendingString:@" "] stringByAppendingString:[profile objectForKey:@"last_name"]];
                    
                    //Avatar
                    newsItem.imageAvatarURL = [profile objectForKey:@"photo_medium_rec"];
                    
                }
            }
        } else {
            //delete minus before postSenderID
            long long convertToPositiveLongLongValue = [postSenderID longLongValue];
            convertToPositiveLongLongValue = convertToPositiveLongLongValue * (-1);
            NSString *postSenderIDPositive = [NSString stringWithFormat:@"%lld", convertToPositiveLongLongValue];
            
            for (NSDictionary *group in [[responseObject objectForKey:@"response"] objectForKey:@"groups"]) {
                
                if ([[group objectForKey:@"gid"] integerValue] == [postSenderIDPositive integerValue]) {
                    
                    //Name (Group)
                    newsItem.name = [group objectForKey:@"name"];
                    
                    //Avatar
                    newsItem.imageAvatarURL = [group objectForKey:@"photo_medium"];
                }
            }
        }
    }
    fromLoadString = [ModelHandler fromFieldInResponse:responseObject];
}



+ (void)returnClearManagedObjectContext{
    NSFetchRequest * newsFetchRequest = [[NSFetchRequest alloc] init];
    [newsFetchRequest setEntity:[NSEntityDescription entityForName:@"NewsItem" inManagedObjectContext:managedObjectContext]];
    [newsFetchRequest setIncludesPropertyValues:NO];
    NSError * error = nil;
    NSArray * arrayOfInstances = [managedObjectContext executeFetchRequest:newsFetchRequest error:&error];
    for (NSManagedObject * newsItem in arrayOfInstances) {
        [managedObjectContext deleteObject:newsItem];
    }
    [managedObjectContext save:nil];
}

+ (NSString*)fromFieldInResponse:(NSMutableDictionary*)responseObject{
    return [[responseObject objectForKey:@"response"] objectForKey:@"new_from"];
}

+ (NSMutableDictionary*)formNewsParametersWithRefreshing:(BOOL)isRefreshing andFromString:(NSString*)fromLoadString{
    NSString *userID = [[NSUserDefaults standardUserDefaults] objectForKey:ACCESS_USER_ID];
    NSString *accessToken = [[NSUserDefaults standardUserDefaults] objectForKey:ACCESS_TOKEN];
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    [parameters setObject:@"post" forKey:@"filters"];
    [parameters setObject:@(NUMBER_OF_NEWS_PER_LOAD) forKey:@"count"];
    [parameters setObject:userID forKey:@"owner_id"];
    [parameters setObject:accessToken forKey:@"access_token"];
    if (!isRefreshing) {
        //continue news
        [parameters setObject:fromLoadString forKey:@"from"];
    }
    return parameters;
}

+ (void)quitVK{
    [requestOprationManager GET:LOGUOT_URL parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
    }];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:ACCESS_USER_ID];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:ACCESS_TOKEN];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:ACCESS_TOKEN_DATE];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    //Deleting cookies to logout totally
    NSHTTPCookie *cookie;
    NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (cookie in [storage cookies]) {
        NSString* domainName = [cookie domain];
        NSRange domainRange = [domainName rangeOfString:@"vk.com"];
        if(domainRange.length > 0) {
            [storage deleteCookie:cookie];
        }
    }
}

+ (UIImageView*)setImageWithURLString:(NSString *)urlString successBlock:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image))successBlock failureBlock:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error))failureBlock toImageView:(UIImageView*)imageView{
    [imageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlString]] placeholderImage:[UIImage imageNamed:PLACEHOLDER_IMAGE] success:successBlock failure:failureBlock];
    return imageView;
}

+ (NewsItem*)loadNewsItemOnIndexPath:(NSIndexPath*)indexPath{
    return [self.fetchedResultsController objectAtIndexPath:indexPath];
}

+ (void)deleteFetchResultControllerCache{
    [NSFetchedResultsController deleteCacheWithName:FETCH_RESULT_CONTROLLER_CACHE_NAME];
}


@end
