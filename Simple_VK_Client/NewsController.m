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
#import "ModelHandler.h"

@interface NewsController ()

@end

@implementation NewsController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.requestOprationManager = [AFHTTPRequestOperationManager manager];
    self.navigationController.navigationItem.hidesBackButton = YES;
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(refreshInvoked:forState:) forControlEvents:UIControlEventValueChanged];
    
    self.arrayOfIndexPathesOfCellsWithImages = [[NSMutableArray alloc] init];
    self.isLoading = YES;
    self.activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.dateFormat = [[NSDateFormatter alloc] init];
}

- (IBAction)exitButton:(id)sender{
    
    
    [self.requestOprationManager GET:LOGUOT_URL parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
    }];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:ACCESS_USER_ID];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:ACCESS_TOKEN];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:ACCESS_TOKEN_DATE];
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
    
    self.isRefreshing = YES;
    self.isLoading = YES;
    [self deleteAllInstancesFromCoreData];
    
    [self.navigationController popToRootViewControllerAnimated:YES];
    
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:SHOW_DETAIL_IDENTIFIER]) {
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
    if ((scrollView.contentOffset.y + scrollView.frame.size.height - 100) >= scrollView.contentSize.height)
    {
        NSLog(@"pull to refresh act");
        [self loadNewPosts];
    }
}


#pragma mark - Networking


- (void)getNewsFromVKWithSuccessBlock:(SuccessLoadBlock)successBlock andFailureBlock:(FailureLoadBlock)failureBlock {
//    NSString *userID = [[NSUserDefaults standardUserDefaults] objectForKey:ACCESS_USER_ID];
//    NSString *accessToken = [[NSUserDefaults standardUserDefaults] objectForKey:ACCESS_TOKEN];
    NSString *URLString = GET_NEWS_FEED_URL;
//    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
//        [parameters setObject:@"post" forKey:@"filters"];
//        [parameters setObject:@(NUMBER_OF_NEWS_PER_LOAD) forKey:@"count"];
//        [parameters setObject:userID forKey:@"owner_id"];
//        [parameters setObject:accessToken forKey:@"access_token"];
//    if (!self.isRefreshing) {
//        //continue news
//        [parameters setObject:self.fromLoadString forKey:@"from"];
//    }
    NSMutableDictionary *parameters = [ModelHandler formNewsParametersWithRefreshing:self.isRefreshing andFromString:self.fromLoadString];
    
    //     News in JSON
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
        self.isRefreshing = NO;
    }];
}

-(void)deleteAllInstancesFromCoreData{
    self.arrayOfIndexPathesOfCellsWithImages = [[NSMutableArray alloc] init];
    [NSFetchedResultsController deleteCacheWithName:@"cache"];
    
    [ModelHandler returnClearManagedObjectContext:self.managedObjectContext];
    
}

-(void)saveNewsItemToCoreData:(NSMutableDictionary*)responseObject{
    if (self.isRefreshing) {
        [self deleteAllInstancesFromCoreData];
        NSError *error;
        [self.managedObjectContext save:&error];
        if (error) {
            NSLog(@"%@", error);
        }
    }
    self.managedObjectContext = [ModelHandler saveResponseObject:responseObject andReturnManagedObjectContext:self.managedObjectContext];
   
    //From (to load from that post)
    self.fromLoadString = [ModelHandler fromFieldInResponse:responseObject];
    
    self.responseDictionary = [[NSMutableDictionary alloc] init];
}

-(void)loadNewsFromCoreDataForCell:(NewsCell*)cell OnIndexPath:(NSIndexPath*)indexPath{
    NewsItem *newsItemFromCoreData = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    //Name
    [cell.nameOfPostSender setText:newsItemFromCoreData.name];
    
    //Avatar
    [cell.imageOfPostSender setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:newsItemFromCoreData.imageAvatarURL]]
                               placeholderImage:[UIImage imageNamed:PLACEHOLDER_IMAGE]
                                        success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                            [cell.imageOfPostSender setImage:image];
                                        }
                                        failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                        }];
    CALayer * layer = [cell.imageOfPostSender layer];
    [layer setMasksToBounds:YES];
    [layer setCornerRadius:25.0];
    
    //Date
    [self.dateFormat setDateFormat:@"YYYY-MM-dd\'T\'HH:mm:ssZZZZZ"];
    NSDate *formattedDate = [self.dateFormat dateFromString:[newsItemFromCoreData.date description]];
    [self.dateFormat setDateFormat:@"HH:mm:ss dd/MM"];
    [cell.dateOfPost setText:[NSString stringWithFormat:@"%@",[self.dateFormat stringFromDate:formattedDate]]];
    
    //Text
    [cell.textOfPost setText:newsItemFromCoreData.text];
    
    //Image preview
    cell.imageOfPostOne.hidden = YES;
    if (!(newsItemFromCoreData.imageURL == nil)) {
        cell.imageOfPostOne.hidden = NO;
        [self.arrayOfIndexPathesOfCellsWithImages addObject:indexPath];
        [cell.imageOfPostOne setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:newsItemFromCoreData.imageURL]]
                                   placeholderImage:[UIImage imageNamed:PLACEHOLDER_IMAGE]
                                            success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                                [cell.imageOfPostOne setImage:image];
                                            }
                                            failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {                                            }];
    }
    
    //Likes
    [cell.likesOfPost setText:newsItemFromCoreData.likes];
    
    //Reposts
    [cell.repostsOfPost setText:newsItemFromCoreData.reposts];
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
        [self.activityIndicatorView stopAnimating];
    };
    FailureLoadBlock blockToExecuteWhenResponseFailed = ^(void){
    };
    if (!self.isLoading && !self.isRefreshing) {
        self.activityIndicatorView.center = self.bottomView.center;
        [self.view addSubview:self.activityIndicatorView];
        [self.activityIndicatorView startAnimating];
        self.isLoading = YES;
        [self getNewsFromVKWithSuccessBlock:blockToExecuteWhenResponseRecieved andFailureBlock:blockToExecuteWhenResponseFailed];
    }
}

#pragma mark - Table view

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];
    return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NewsCell *cell = [tableView dequeueReusableCellWithIdentifier:NEWS_CELL_IDENTIFIER forIndexPath:indexPath];
    
    [self setUpNewsCell:cell forIndexPath:indexPath andResponseObject:(NSDictionary*)self.responseDictionary];
    
    return cell;
}

- (void)setUpNewsCell:(NewsCell*)cell forIndexPath:(NSIndexPath*)indexPath andResponseObject:(NSDictionary*)responseObject{
    [self loadNewsFromCoreDataForCell:cell OnIndexPath:indexPath];
    }

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (![self.arrayOfIndexPathesOfCellsWithImages containsObject:indexPath]) {
        return HEIGHT_OF_CELL_SMALL;
    } else {
        return HEIGHT_OF_CELL_BIG;
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self performSegueWithIdentifier:SHOW_DETAIL_IDENTIFIER sender:nil];
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    return nil;
}


#pragma mark - Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController{
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:ENTITY_NEWS_ITEM];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"date" ascending:NO];
    NSArray *sortDescriptors = @[sortDescriptor];
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:@"cache"];
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
    [self.tableView endUpdates];
    self.isLoading = NO;
}

@end
