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

@interface DetailView : UIViewController <UIScrollViewDelegate, UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) NewsItem *detailItem;

@property (weak, nonatomic) IBOutlet UILabel *nameOfPoster;
@property (weak, nonatomic) IBOutlet UILabel *dateOfPost;
@property (weak, nonatomic) IBOutlet UILabel *likesOfPost;
@property (weak, nonatomic) IBOutlet UILabel *repostOfPost;
@property (weak, nonatomic) IBOutlet UIImageView *avatarOfPoster;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property BOOL isCellWithText;

@end
