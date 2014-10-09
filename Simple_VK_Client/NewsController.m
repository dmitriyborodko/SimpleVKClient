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
    
//    self.tableView.bottomRefreshControl = [[UIRefreshControl alloc] init];
//    [self.tableView.bottomRefreshControl addTarget:self action:@selector(loadNewPosts) forControlEvents:UIControlEventValueChanged];
    
    self.arrayOfIndexPathesOfCellsWithImages = [[NSMutableArray alloc] init];
    
    self.imageDictionaryOfURLs = [[NSMutableDictionary alloc] init];
    [self loadImagesFromCacheWithRefresh:NO];
    
    //bottom pull to refresh view
//    UIView* footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 50)];
////    UILabel *label
//    UIActivityIndicatorView *activityIndicatorBottom = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(self.tableView.center.x - 25, 0, 50, 50)];
//    UILabel *pullToRefreshLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 150, 50)];
//    [pullToRefreshLabel setText:@"pull to refresh"];
//    [footerView addSubview:activityIndicatorBottom];
//    [footerView addSubview:pullToRefreshLabel];
////    [footerView setBackgroundColor:[UIColor redColor]];
//    self.tableView.tableFooterView = footerView;
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

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"showDetail"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        NewsItem *detailItem = [self.fetchedResultsController objectAtIndexPath:indexPath];
        [[segue destinationViewController] setDetailItem:detailItem];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize {
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 1.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}


- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if ((scrollView.contentOffset.y + scrollView.frame.size.height - 150) >= scrollView.contentSize.height)
    {
        NSLog(@"pull to refresh act");
        [self loadNewPosts];
    }
}


#pragma mark - Networking


- (void)getNewsFromVKWithSuccessBlock:(SuccessLoadBlock)successBlock andFailureBlock:(FailureLoadBlock)failureBlock {
    NSString *userID = [[NSUserDefaults standardUserDefaults] objectForKey:@"VKAccessUserId"];
    NSString *accessToken = [[NSUserDefaults standardUserDefaults] objectForKey:@"VKAccessToken"];
    NSString *URLString = @"https://api.vk.com/method/newsfeed.get";
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
        [parameters setObject:@"post" forKey:@"filters"];
        [parameters setObject:@(NUMBER_OF_NEWS_PER_LOAD) forKey:@"count"];
        [parameters setObject:userID forKey:@"owner_id"];
        [parameters setObject:accessToken forKey:@"access_token"];
    if (!self.isRefreshing) {
        //continue news
        id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][0];
        NSString *offset = [NSString stringWithFormat:@"%li",  (unsigned long)[sectionInfo numberOfObjects]];
        [parameters setObject:offset forKey:@"offset"];
    }
    
    //     News in JSON
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self.requestOprationManager GET:URLString parameters:parameters success:^(AFHTTPRequestOperation *operation, NSMutableDictionary *responseObject) {
//                    NSLog(@"JSON: %@", responseObject);
            NSLog(@"request DONE");
            self.responseDictionary = responseObject;
            [self saveNewsItemToCoreData:responseObject];
            self.isRefreshing = NO;
            successBlock();
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Error: %@", error);
            failureBlock();
            UIAlertView *alertError = [[UIAlertView alloc] initWithTitle:@"Connection error" message:[error description] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alertError show];
        }];
    });
    
}

-(void)deleteAllInstancesFromCoreData{
    self.arrayOfIndexPathesOfCellsWithImages = [[NSMutableArray alloc] init];
    [NSFetchedResultsController deleteCacheWithName:@"cache"];
    [NSFetchedResultsController deleteCacheWithName:nil];
    
    NSFetchRequest * newsFetchRequest = [[NSFetchRequest alloc] init];
    [newsFetchRequest setEntity:[NSEntityDescription entityForName:@"NewsItem" inManagedObjectContext:self.managedObjectContext]];
    [newsFetchRequest setIncludesPropertyValues:NO];
    NSError * error = nil;
    NSArray * arrayOfInstances = [self.managedObjectContext executeFetchRequest:newsFetchRequest error:&error];
    for (NSManagedObject * newsItem in arrayOfInstances) {
        [self.managedObjectContext deleteObject:newsItem];
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:[NSEntityDescription entityForName:@"DictionaryOfCachedImages" inManagedObjectContext:self.managedObjectContext]];
    NSArray *dictionaryArrayOfOne = [self.managedObjectContext executeFetchRequest:fetchRequest error:nil];
    for (DictionaryOfCachedImages *item in dictionaryArrayOfOne) {
        [self.managedObjectContext deleteObject:item];
    }
}

-(void)saveNewsItemToCoreData:(NSMutableDictionary*)responseObject{
    if (self.isRefreshing) {
        [self deleteAllInstancesFromCoreData];
        NSError *error;
        [self.managedObjectContext save:&error];
        if (error) {
//            NSLog(@"%@", error);
        }
        self.imageDictionaryOfURLs = [[NSMutableDictionary alloc] init];
    }
    for (NSDictionary *itemDictionary in (NSArray*)[[responseObject objectForKey:@"response"] objectForKey:@"items"]) {
        NSString *postSenderID = [itemDictionary objectForKey:@"source_id"];
        NSLog(@"   check  %@ " , postSenderID);
        
        NewsItem *newsItem = [NSEntityDescription insertNewObjectForEntityForName:@"NewsItem" inManagedObjectContext:self.managedObjectContext];
        
        //Date
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:[[itemDictionary objectForKey:@"date"] longLongValue]];
        newsItem.date = date;
        
        //Text
        if ([itemDictionary objectForKey:@"text"]) {
            newsItem.text =[itemDictionary objectForKey:@"text"];
        }
        
        //Image for preview
        if ([[[itemDictionary objectForKey:@"attachment"] objectForKey:@"type"]  isEqual: @"photo"]) {
            NSURL *urlForImageOneBig = [NSURL URLWithString:[[[itemDictionary objectForKey:@"attachment"] objectForKey:@"photo"] objectForKey:@"src_big"]];
            NSURL *urlForImageOne = [NSURL URLWithString:[[[itemDictionary objectForKey:@"attachment"] objectForKey:@"photo"] objectForKey:@"src"]];
            if (urlForImageOneBig) {
                newsItem.imageURL = [urlForImageOneBig absoluteString];
            } else {
                newsItem.imageURL = [urlForImageOne absoluteString];
            }
            UIImage *imageOne = [[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:newsItem.imageURL]]];
            [self.imageDictionaryOfURLs setObject:imageOne forKey:newsItem.imageURL];
        }
        
        //More images
        NSMutableArray *arrayOfImages = [[NSMutableArray alloc] init];
        for (NSDictionary *attachmentItem in [itemDictionary objectForKey:@"attachments"]) {
            [attachmentItem objectForKey:@"photo"];
            if ([[attachmentItem objectForKey:@"type"]  isEqual: @"photo"]) {
                NSURL *urlForImageBig = [NSURL URLWithString:[[attachmentItem objectForKey:@"photo"] objectForKey:@"src_big"]];
                NSURL *urlForImage = [NSURL URLWithString:[[attachmentItem objectForKey:@"photo"] objectForKey:@"src"]];
                if (urlForImageBig) {
                    [arrayOfImages addObject:urlForImageBig];
                } else {
                    [arrayOfImages addObject:urlForImage];
                }
            }
        }
        NSData *arrayData = [NSKeyedArchiver archivedDataWithRootObject:arrayOfImages];
        newsItem.dataWithArrayOfImages = arrayData;
     
        //Likes
        newsItem.likes =[[[itemDictionary objectForKey:@"likes"] objectForKey:@"count"] stringValue];
        
        //Reposts
        newsItem.reposts =[[[itemDictionary objectForKey:@"reposts"] objectForKey:@"count"] stringValue];
        
        
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
            //            NSLog(@"%@", postSenderID);
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
    self.responseDictionary = [[NSMutableDictionary alloc] init];
    if (self.isRefreshing) {
        [self saveImageCache];
    }
//    [self loadImagesFromCacheWithRefresh:YES];
}

-(void)loadNewsFromCoreDataForCell:(NewsCell*)cell OnIndexPath:(NSIndexPath*)indexPath{
//    NSError *error = nil;
//    NewsItem *newsItemFromCoreData = [[self.managedObjectContext executeFetchRequest:[self.fetchedResultsController fetchRequest] error:&error] objectAtIndex:indexPath.row];
    NewsItem *newsItemFromCoreData = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    //Name
    [cell.nameOfPostSender setText:newsItemFromCoreData.name];
    
    //Avatar
    UIImage *imageAvatar = [[UIImage alloc] initWithData:newsItemFromCoreData.imageAvatar];
    [cell.imageOfPostSender setImage:imageAvatar];
    CALayer * layer = [cell.imageOfPostSender layer];
    [layer setMasksToBounds:YES];
    [layer setCornerRadius:25.0];
    
    //Date
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"YYYY-MM-dd\'T\'HH:mm:ssZZZZZ"];
    NSDate *formattedDate = [dateFormat dateFromString:[newsItemFromCoreData.date description]];
    [dateFormat setDateFormat:@"HH:mm:ss dd/MM"];
    [cell.dateOfPost setText:[NSString stringWithFormat:@"%@",[dateFormat stringFromDate:formattedDate]]];
    
    //Text
    if (newsItemFromCoreData.text) {
        [cell.textOfPost setText:newsItemFromCoreData.text];
    } else {
        [cell.textOfPost setText:newsItemFromCoreData.text];
    }
    
    //Image preview
    UIImage *imagePreview = [self.imageDictionaryOfURLs objectForKey:newsItemFromCoreData.imageURL];
    [cell.imageOfPostOne setImage:imagePreview];
    if (imagePreview) {
        [self.arrayOfIndexPathesOfCellsWithImages addObject:indexPath];
    }
    
    //Likes
    [cell.likesOfPost setText:newsItemFromCoreData.likes];
    
    //Reposts
    [cell.repostsOfPost setText:newsItemFromCoreData.reposts];
}

-(void)loadImagesFromCacheWithRefresh:(BOOL)refresh{
    //    Load images from cache
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"DictionaryOfCachedImages"];
//    NSEntityDescription *entity = [NSEntityDescription entityForName:@"DictionaryOfCachedImages" inManagedObjectContext:self.managedObjectContext];
//    [fetchRequest setEntity:entity];
    NSError *error = nil;
    NSArray *dictionaryArrayOfOne = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if ([dictionaryArrayOfOne firstObject] == nil) {
        NSLog(@"Trouble with reading image cache");
    }
    DictionaryOfCachedImages *dictionaryOfImages = [dictionaryArrayOfOne firstObject];
    
    for (NewsItem *newsItem in self.fetchedResultsController.fetchedObjects) {
        if (newsItem.imageURL) {
            //Тут надо картинку брать не из сети, а из другой энтити, в которую я буду записывать в другом методе!!! Каждый раз когда я обновляю - нужно переписывать кэш.
//            UIImage *imageOne = [[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:newsItem.imageURL]]];
            self.imageDictionaryOfURLs = (NSMutableDictionary*) [NSKeyedUnarchiver unarchiveObjectWithData:dictionaryOfImages.dictionary];
//            UIImage *image = [[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:newsItem.imageURL]]];
//            if (imageOne) {
//                [self.imageDictionaryOfURLs setObject:imageOne forKey:newsItem.imageURL];
//            }
        }
    }
}

-(void)saveImageCache{
    DictionaryOfCachedImages *dictionaryOfCachedImages = [NSEntityDescription insertNewObjectForEntityForName:@"DictionaryOfCachedImages" inManagedObjectContext:self.managedObjectContext];
    dictionaryOfCachedImages.dictionary = [NSKeyedArchiver archivedDataWithRootObject:self.imageDictionaryOfURLs];
    [self.managedObjectContext save:nil];
}


- (void)refreshInvoked:(id)sender forState:(UIControlState)state {
    SuccessLoadBlock blockToExecuteWhenResponseRecieved = ^(void){
        [self.tableView addSubview:self.refreshControl];
        [self.refreshControl endRefreshing];
    };
    FailureLoadBlock blockToExecuteWhenResponseFailed = ^(void){
        [self.tableView addSubview:self.refreshControl];
        [self.refreshControl endRefreshing];
    };
        self.isRefreshing = YES;
        [self getNewsFromVKWithSuccessBlock:blockToExecuteWhenResponseRecieved andFailureBlock:blockToExecuteWhenResponseFailed];
}

- (void)loadNewPosts {
    SuccessLoadBlock blockToExecuteWhenResponseRecieved = ^(void){
        [self.tableView addSubview:self.tableView.bottomRefreshControl];
        [self.tableView.bottomRefreshControl endRefreshing];
        self.isLoading = NO;
    };
    FailureLoadBlock blockToExecuteWhenResponseFailed = ^(void){
        [self.tableView addSubview:self.tableView.bottomRefreshControl];
        [self.tableView.bottomRefreshControl endRefreshing];
        self.isLoading = NO;
    };
    self.isRefreshing = NO;
    if (!self.isLoading) {
        self.isLoading = YES;
        [self getNewsFromVKWithSuccessBlock:blockToExecuteWhenResponseRecieved andFailureBlock:blockToExecuteWhenResponseFailed];
    }
}


//- (void)scrollViewDidScroll:(UIScrollView *)scrollView
//{
//    if ((scrollView.contentOffset.y + scrollView.frame.size.height) >= scrollView.contentSize.height)
//    {
//        if (!self.isLoadingMoreData)
//        {
//            self.loadingMoreData = YES;
//            
//            // proceed with the loading of more data
//        }
//    }
//}

#pragma mark - Table view

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//    if (self.responseDictionary) {
//        NSInteger howManyItemsInRequest = [(NSArray*)[[self.responseDictionary objectForKey:@"response"] objectForKey:@"items"] count];
//        
//        return howManyItemsInRequest;
//    }
    
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];
    return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NewsCell *cell = [tableView dequeueReusableCellWithIdentifier:@"newsCell" forIndexPath:indexPath];
    
    [self setUpNewsCell:cell forIndexPath:indexPath andResponseObject:(NSDictionary*)self.responseDictionary];
    
    return cell;
}

- (void)setUpNewsCell:(NewsCell*)cell forIndexPath:(NSIndexPath*)indexPath andResponseObject:(NSDictionary*)responseObject{
    [self loadNewsFromCoreDataForCell:cell OnIndexPath:indexPath];
    }

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (![self.arrayOfIndexPathesOfCellsWithImages containsObject:indexPath]) {
        return 98.0f;
    } else {
        return 236.0f;
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self performSegueWithIdentifier:@"showDetail" sender:nil];
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    return nil;
}


#pragma mark - Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController{
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"NewsItem"];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"date" ascending:NO];
    NSArray *sortDescriptors = @[sortDescriptor];
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;
    NSError *error = nil;
    if (![self.fetchedResultsController performFetch:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    return _fetchedResultsController;
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller{
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    UITableView *tableView = self.tableView;
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
        case NSFetchedResultsChangeUpdate:
            [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
            break;
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller{
//    [self.tableView reloadData];
    [self.tableView endUpdates];
}

@end
