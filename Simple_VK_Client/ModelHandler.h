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

typedef void (^ SuccessLoadBlock)(void);
typedef void (^ FailureLoadBlock)(void);

static NSString *fromLoadString;

@interface ModelHandler : NSObject

+ (NSManagedObjectContext*)saveResponseObject:(NSMutableDictionary*)responseObject andReturnManagedObjectContext:(NSManagedObjectContext*)managedObjectContext;
+ (NSManagedObjectContext*)returnClearManagedObjectContext:(NSManagedObjectContext*)managedObjectContext;
+ (NSString*)fromFieldInResponse:(NSMutableDictionary*)responseObject;
+ (NSMutableDictionary*)formNewsParametersWithRefreshing:(BOOL)isRefreshing andFromString:(NSString*)fromLoadString;
+ (NSManagedObjectContext*)getNewsFromVKWithSuccessBlock:(SuccessLoadBlock)successBlock failureBlock:(FailureLoadBlock)failureBlock isRefreshing:(BOOL)isRefreshing requestOprationManager:(AFHTTPRequestOperationManager*)requestOprationManager andManagedObjectContext:(NSManagedObjectContext*)managedObjectContext;
+ (void)quitVKWithRequestOprationManager:(AFHTTPRequestOperationManager*)requestOprationManager;
@end

