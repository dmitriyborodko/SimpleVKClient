//
//  NewsController.m
//  Simple_VK_Client
//
//  Created by Dmitriy on 30/09/14.
//  Copyright (c) 2014 ALS. All rights reserved.
//

#import "NewsController.h"
#import "NewsCell.h"
#import "NewsItem.h"

@interface NewsController ()

@end

@implementation NewsController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.requestOprationManager = [AFHTTPRequestOperationManager manager];
    self.navigationItem.hidesBackButton = YES;
    self.navigationController.navigationItem.hidesBackButton = YES;
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(refreshInvoked:forState:) forControlEvents:UIControlEventValueChanged];
    
    self.arrayOfIndexPathesOfCellsWithImages = [[NSMutableArray alloc] init];
}

- (void)getNewsFromVKWithSuccessBlock:(SuccessLoadBlock)successBlock andFailureBlock:(FailureLoadBlock)failureBlock {
    NSString *userID = [[NSUserDefaults standardUserDefaults] objectForKey:@"VKAccessUserId"];
    NSString *accessToken = [[NSUserDefaults standardUserDefaults] objectForKey:@"VKAccessToken"];
    NSString *URLString = @"https://api.vk.com/method/newsfeed.get";
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
        [parameters setObject:@"filters" forKey:@"post"];
        [parameters setObject:@(NUMBER_OF_NEWS_PER_LOAD_TWO) forKey:@"count"];
        [parameters setObject:userID forKey:@"owner_id"];
        [parameters setObject:accessToken forKey:@"access_token"];
    
    //     News in JSON
    [self.requestOprationManager GET:URLString parameters:parameters success:^(AFHTTPRequestOperation *operation, NSMutableDictionary *responseObject) {
        NSLog(@"JSON: %@", responseObject);
        NSLog(@"rquestd DONE");
        self.responseDictionary = responseObject;
        successBlock();
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        failureBlock();
        UIAlertView *alertError = [[UIAlertView alloc] initWithTitle:@"Connection error" message:[error description] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alertError show];
    }];
}

-(void)saveNewsItemToCoreData:(NSMutableDictionary*)responseObject{
    for (NSDictionary *itemDictionary in (NSArray*)[[responseObject objectForKey:@"response"] objectForKey:@"items"]) {
        NSString *postSenderID = [itemDictionary objectForKey:@"source_id"];
        NSLog(@"   check  %@ " , postSenderID);
        
        NewsItem *newsItem = [NSEntityDescription insertNewObjectForEntityForName:@"NewsItem" inManagedObjectContext:self.managedObjectContext];
        
        if ([postSenderID integerValue] > 0) {
            for (NSDictionary *profile in [[responseObject objectForKey:@"response"] objectForKey:@"profiles"]) {
                if ([[profile objectForKey:@"uid"] integerValue] == [postSenderID integerValue]) {
                    
                    //Name (Profile)
                    newsItem.name = [[[profile objectForKey:@"first_name"] stringByAppendingString:@" "] stringByAppendingString:[profile objectForKey:@"last_name"]];
                    
                    //Avatar
                    NSURL *urlForAvatar = [NSURL URLWithString:[profile objectForKey:@"photo_medium_rec"]];
                    newsItem.imageAvatar = [NSData dataWithContentsOfURL:urlForAvatar];
                }
            }
        } else {
            //delete minus before postSenderID
            NSLog(@"%@", postSenderID);
            long long convertToPositiveLongLongValue = [postSenderID longLongValue];
            convertToPositiveLongLongValue = convertToPositiveLongLongValue * (-1);
            NSString *postSenderIDPositive = [NSString stringWithFormat:@"%lld", convertToPositiveLongLongValue];
            
            for (NSDictionary *group in [[responseObject objectForKey:@"response"] objectForKey:@"groups"]) {
                if ([[group objectForKey:@"gid"] integerValue] == [postSenderIDPositive integerValue]) {
                    
                    //Name (Group)
                    newsItem.name = [group objectForKey:@"name"];
                    
                    //Avatar
                    NSURL *urlForAvatar = [NSURL URLWithString:[group objectForKey:@"photo_medium"]];
                    newsItem.imageAvatar = [NSData dataWithContentsOfURL:urlForAvatar];
                }
            }
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)exitButton:(id)sender{
    [self.requestOprationManager GET:@"http://api.vk.com/oauth/logout" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        UIAlertView *alertError = [[UIAlertView alloc] initWithTitle:@"Connection error" message:[error description] delegate:nil cancelButtonTitle:nil otherButtonTitles:nil, nil];
        [alertError show];
    }];
    
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"VKAccessUserId"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"VKAccessToken"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"VKAccessTokenDate"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    //Deleting cookies to logout totally
    NSHTTPCookie *cookie;
    NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (cookie in [storage cookies]) {
        NSString* domainName = [cookie domain];
        NSRange domainRange = [domainName rangeOfString:@"vk.com"];
        if(domainRange.length > 0) {
            [storage deleteCookie:cookie];
        }
    }
    UIAlertView *exitCompleteAlert = [[UIAlertView alloc] initWithTitle:@"Run, pussy, run" message:nil delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil, nil];
    [exitCompleteAlert show];
    
    [self.navigationController popToRootViewControllerAnimated:YES];

}

- (void)refreshInvoked:(id)sender forState:(UIControlState)state {
    SuccessLoadBlock blockToExecuteWhenResponseRecieved = ^(void){
        [self.tableView reloadData];
        [self.tableView addSubview:self.refreshControl];
        [self.refreshControl endRefreshing];
    };
    FailureLoadBlock blockToExecuteWhenResponseFailed = ^(void){
        [self.tableView addSubview:self.refreshControl];
        [self.refreshControl endRefreshing];
    };
    [self getNewsFromVKWithSuccessBlock:blockToExecuteWhenResponseRecieved andFailureBlock:blockToExecuteWhenResponseFailed];
}

#pragma mark - Table view

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.responseDictionary) {
        NSInteger howManyItemsInRequest = [(NSArray*)[[self.responseDictionary objectForKey:@"response"] objectForKey:@"items"] count];
        return howManyItemsInRequest;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NewsCell *cell = [tableView dequeueReusableCellWithIdentifier:@"newsCell" forIndexPath:indexPath];
   
    [self setUpNewsCell:cell forIndexPath:indexPath andResponseObject:(NSDictionary*)self.responseDictionary];
    
    return cell;
}

- (void)setUpNewsCell:(NewsCell*)cell forIndexPath:(NSIndexPath*)indexPath andResponseObject:(NSDictionary*)responseObject{
    NSString *postSenderID = [[(NSArray*)[[responseObject objectForKey:@"response"] objectForKey:@"items"] objectAtIndex:indexPath.row] objectForKey:@"source_id"];
    NSLog(@"   check  %@ " , postSenderID);
    
    if ([postSenderID integerValue] > 0) {
        for (NSDictionary *profile in [[responseObject objectForKey:@"response"] objectForKey:@"profiles"]) {
            if ([[profile objectForKey:@"uid"] integerValue] == [postSenderID integerValue]) {
                
                //Name (Profile)
                [cell.nameOfPostSender setText:[[[profile objectForKey:@"first_name"] stringByAppendingString:@" "] stringByAppendingString:[profile objectForKey:@"last_name"]]];
                
                //Avatar
                NSURL *urlForAvatar = [NSURL URLWithString:[profile objectForKey:@"photo_medium_rec"]];
                NSData *dataForAvatar = [NSData dataWithContentsOfURL:urlForAvatar];
                UIImage *imageAvatar = [[UIImage alloc] initWithData:dataForAvatar];
                [cell.imageOfPostSender setImage:imageAvatar];
            }
        }
    } else {
        NSLog(@"%@", postSenderID);
        long long convertToPositiveLongLongValue = [postSenderID longLongValue];
        convertToPositiveLongLongValue = convertToPositiveLongLongValue * (-1);
        NSString *postSenderIDPositive = [NSString stringWithFormat:@"%lld", convertToPositiveLongLongValue];
        
        for (NSDictionary *group in [[responseObject objectForKey:@"response"] objectForKey:@"groups"]) {
            if ([[group objectForKey:@"gid"] integerValue] == [postSenderIDPositive integerValue]) {
                
                //Name (Group)
                [cell.nameOfPostSender setText:[group objectForKey:@"name"]];
                
                //Avatar
                NSURL *urlForAvatar = [NSURL URLWithString:[group objectForKey:@"photo_medium"]];
                NSData *dataForAvatar = [NSData dataWithContentsOfURL:urlForAvatar];
                UIImage *imageAvatar = [[UIImage alloc] initWithData:dataForAvatar];
                [cell.imageOfPostSender setImage:imageAvatar];
            }
        }
    }
    
    //Date
    [cell.dateOfPost setText:[[(NSArray*)[[responseObject objectForKey:@"response"] objectForKey:@"items"] objectAtIndex:indexPath.row] objectForKey:@"date"]];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (![self.arrayOfIndexPathesOfCellsWithImages containsObject:indexPath]) {
        return 98.0f;
    } else {
        return 236.0f;
    }
}



@end
