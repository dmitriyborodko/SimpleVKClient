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

@interface ModelHandler : NSObject

//+ (NSManagedObjectContext*)managedObjectContext;

+ (NSManagedObjectContext*)saveResponseObject:(NSMutableDictionary*)responseObject andReturnManagedObjectContext:(NSManagedObjectContext*)managedObjectContext;
+ (NSManagedObjectContext*)returnClearManagedObjectContext:(NSManagedObjectContext*)managedObjectContext;
+ (NSString*)fromFieldInResponse:(NSMutableDictionary*)responseObject;
+ (NSMutableDictionary*)formNewsParametersWithRefreshing:(BOOL)isRefreshing andFromString:(NSString*)fromLoadString;

@end
