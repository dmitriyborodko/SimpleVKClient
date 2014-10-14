//
//  DetailView.h
//  Simple_VK_Client
//
//  Created by Dmitriy on 08/10/14.
//  Copyright (c) 2014 ALS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NewsItem.h"
#import "ImageCell.h"
#import <AFNetworking/UIKit+AFNetworking.h>

#define IMAGE_CELL_IDENTIFIER @"imageCell"
#define TEXT_CELL_IDENTIFIER @"textCell"

static NSDateFormatter *dateFormat;

@interface DetailView : UIViewController <UIScrollViewDelegate, UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) NewsItem *detailItem;

@property (weak, nonatomic) IBOutlet UILabel *nameOfPoster;
@property (weak, nonatomic) IBOutlet UILabel *dateOfPost;
@property (weak, nonatomic) IBOutlet UILabel *likesOfPost;
@property (weak, nonatomic) IBOutlet UILabel *repostOfPost;
@property (weak, nonatomic) IBOutlet UIImageView *avatarOfPoster;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property NSMutableArray *arrayOfImages;
@property NSMutableArray *arrayWithImageURLs;
@property BOOL isCellWithText;

@end