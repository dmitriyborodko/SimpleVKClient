//
//  NewsItem.h
//  Simple_VK_Client
//
//  Created by Dmitriy on 10/10/14.
//  Copyright (c) 2014 ALS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface NewsItem : NSManagedObject

@property (nonatomic, retain) NSData * dataWithArrayOfImages;
@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSData * imageAvatar;
@property (nonatomic, retain) NSString * imageURL;
@property (nonatomic, retain) NSString * likes;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * reposts;
@property (nonatomic, retain) NSString * text;

@end
