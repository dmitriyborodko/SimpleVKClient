//
//  DictionaryOfCachedImages.h
//  Simple_VK_Client
//
//  Created by Dmitriy on 10/10/14.
//  Copyright (c) 2014 ALS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface DictionaryOfCachedImages : NSManagedObject

@property (nonatomic, retain) NSData * dictionary;
@property (nonatomic, retain) NSString * from;

@end
