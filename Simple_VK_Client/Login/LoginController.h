//
//  ViewController.h
//  Simple_VK_Client
//
//  Created by Dmitriy on 29/09/14.
//  Copyright (c) 2014 ALS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NewsController.h"
#import <AFNetworking.h>
#import <CoreData/CoreData.h>

@interface LoginController : UIViewController <UIWebViewDelegate>

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

- (IBAction)loginButton:(id)sender;

@end

