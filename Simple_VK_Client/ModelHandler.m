//
//  ModelHandler.m
//  Simple_VK_Client
//
//  Created by Dmitriy on 10/10/14.
//  Copyright (c) 2014 ALS. All rights reserved.
//

#import "ModelHandler.h"
#import "NewsItem.h"

@implementation ModelHandler

+ (NSManagedObjectContext*)saveResponseObject:(NSMutableDictionary*)responseObject andReturnManagedObjectContext:(NSManagedObjectContext*)managedObjectContext{
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
    return managedObjectContext;
}



+ (NSManagedObjectContext*)returnClearManagedObjectContext:(NSManagedObjectContext*)managedObjectContext{
    NSFetchRequest * newsFetchRequest = [[NSFetchRequest alloc] init];
    [newsFetchRequest setEntity:[NSEntityDescription entityForName:@"NewsItem" inManagedObjectContext:managedObjectContext]];
    [newsFetchRequest setIncludesPropertyValues:NO];
    NSError * error = nil;
    NSArray * arrayOfInstances = [managedObjectContext executeFetchRequest:newsFetchRequest error:&error];
    for (NSManagedObject * newsItem in arrayOfInstances) {
        [managedObjectContext deleteObject:newsItem];
    }
    return managedObjectContext;
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



@end
