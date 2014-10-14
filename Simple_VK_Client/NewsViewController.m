//
//  NewsController.m
//  Simple_VK_Client
//
//  Created by Dmitriy on 30/09/14.
//  Copyright (c) 2014 ALS. All rights reserved.
//

#import "NewsViewController.h"
#import "NewsCell.h"
#import "NewsItem.h"
#import "ModelHandler.h"

@interface NewsViewController ()

@end

@implementation NewsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationItem.hidesBackButton = YES;
    [ModelHandler initModelHandler];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(refreshInvoked:forState:) forControlEvents:UIControlEventValueChanged];
    
    self.arrayOfIndexPathesOfCellsWithImages = [[NSMutableArray alloc] init];
    self.isLoading = YES;
    self.activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    dateFormat = [[NSDateFormatter alloc] init];
}

- (IBAction)exitButton:(id)sender{
    [ModelHandler quitVK];
    
    self.isRefreshing = YES;
    self.isLoading = YES;
    self.arrayOfIndexPathesOfCellsWithImages = [[NSMutableArray alloc] init];
    [NSFetchedResultsController deleteCacheWithName:@"cache"];
    [ModelHandler returnClearManagedObjectContext:self.managedObjectContext];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:SHOW_DETAIL_IDENTIFIER]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        NewsItem *detailItem = [self.fetchedResultsController objectAtIndexPath:indexPath];
        [[segue destinationViewController] setDetailItem:detailItem];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if ((scrollView.contentOffset.y + scrollView.frame.size.height - 100) >= scrollView.contentSize.height)
    {
        NSLog(@"pull to refresh act");
        [self loadNewPosts];
    }
}

#pragma mark - Data Managing

- (void)loadNewsFromCoreDataForCell:(NewsCell*)cell OnIndexPath:(NSIndexPath*)indexPath{
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
    [dateFormat setDateFormat:@"YYYY-MM-dd\'T\'HH:mm:ssZZZZZ"];
    NSDate *formattedDate = [dateFormat dateFromString:[newsItemFromCoreData.date description]];
    [dateFormat setDateFormat:@"HH:mm:ss dd/MM"];
    [cell.dateOfPost setText:[NSString stringWithFormat:@"%@",[dateFormat stringFromDate:formattedDate]]];
    
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
        self.isRefreshing = NO;
    };
    FailureLoadBlock blockToExecuteWhenResponseFailed = ^(void){
        [self.tableView addSubview:self.refreshControl];
        [self.refreshControl endRefreshing];
        self.isRefreshing = NO;
    };
    self.isRefreshing = YES;
    self.arrayOfIndexPathesOfCellsWithImages = [[NSMutableArray alloc] init];
    [NSFetchedResultsController deleteCacheWithName:@"cache"];
    self.managedObjectContext = [ModelHandler getNewsFromVKWithSuccessBlock:blockToExecuteWhenResponseRecieved failureBlock:blockToExecuteWhenResponseFailed isRefreshing:self.isRefreshing andManagedObjectContext:self.managedObjectContext];
}

- (void)loadNewPosts {
    SuccessLoadBlock blockToExecuteWhenResponseRecieved = ^(void){
        [self.activityIndicatorView stopAnimating];
        self.isRefreshing = NO;
    };
    FailureLoadBlock blockToExecuteWhenResponseFailed = ^(void){
        [self.activityIndicatorView stopAnimating];
        self.isRefreshing = NO;
    };
    if (!self.isLoading && !self.isRefreshing) {
        self.activityIndicatorView.center = self.bottomView.center;
        [self.view addSubview:self.activityIndicatorView];
        [self.activityIndicatorView startAnimating];
        self.isLoading = YES;
        self.managedObjectContext = [ModelHandler getNewsFromVKWithSuccessBlock:blockToExecuteWhenResponseRecieved failureBlock:blockToExecuteWhenResponseFailed isRefreshing:self.isRefreshing andManagedObjectContext:self.managedObjectContext];
    }
}

#pragma mark - Table view

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];
    return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NewsCell *cell = [tableView dequeueReusableCellWithIdentifier:NEWS_CELL_IDENTIFIER forIndexPath:indexPath];
    
    [self setUpNewsCell:cell forIndexPath:indexPath];
    
    return cell;
}

- (void)setUpNewsCell:(NewsCell*)cell forIndexPath:(NSIndexPath*)indexPath{
    [self loadNewsFromCoreDataForCell:cell OnIndexPath:indexPath];
    }

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (![self.arrayOfIndexPathesOfCellsWithImages containsObject:indexPath]) {
        return HEIGHT_OF_CELL_SMALL;
    } else {
        return HEIGHT_OF_CELL_BIG;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
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
