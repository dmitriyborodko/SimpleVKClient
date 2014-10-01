//
//  NewsController.h
//  Simple_VK_Client
//
//  Created by Dmitriy on 30/09/14.
//  Copyright (c) 2014 ALS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AFNetworking.h>
//#import "VKSdk.h"

@interface NewsController : UITableViewController

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property AFHTTPRequestOperationManager *requestOprationManager;

- (IBAction)exitButton:(id)sender;


@end
