//
//  NewsItem.h
//  Simple_VK_Client
//
//  Created by Dmitriy on 06/10/14.
//  Copyright (c) 2014 ALS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface NewsItem : NSManagedObject

@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSData * imageAvatar;
@property (nonatomic, retain) NSData * imagePostOne;
@property (nonatomic, retain) NSData * imagePostTwo;
@property (nonatomic, retain) NSString * likes;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * offset;
@property (nonatomic, retain) NSString * reposts;
@property (nonatomic, retain) NSString * text;

@end
