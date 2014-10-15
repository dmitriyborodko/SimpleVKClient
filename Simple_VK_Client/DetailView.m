//
//  DetailView.m
//  Simple_VK_Client
//
//  Created by Dmitriy on 08/10/14.
//  Copyright (c) 2014 ALS. All rights reserved.
//

#import "DetailView.h"

@interface DetailView ()

@end

@implementation DetailView

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if (self.detailItem.text) {
        self.isCellWithText = YES;
    }
    dateFormat = [[NSDateFormatter alloc] init];
    [self configureView];
    self.arrayWithImageURLs = [[NSMutableArray alloc] initWithArray:[NSKeyedUnarchiver unarchiveObjectWithData:self.detailItem.dataWithArrayOfImages]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)configureView{
    [self.nameOfPoster setText:self.detailItem.name];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    //Date
    [dateFormat setDateFormat:@"YYYY-MM-dd\'T\'HH:mm:ssZZZZZ"];
    NSDate *formattedDate = [dateFormat dateFromString:[self.detailItem.date description]];
    [dateFormat setDateFormat:@"HH:mm:ss dd/MM"];
    [self.dateOfPost setText:[NSString stringWithFormat:@"%@",[dateFormat stringFromDate:formattedDate]]];
    
    //Likes and Reposts
    [self.likesOfPost setText:self.detailItem.likes];
    [self.repostOfPost setText:self.detailItem.reposts];
    
    //Avatar
    [self.avatarOfPoster setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.detailItem.imageAvatarURL]]
                            placeholderImage:[UIImage imageNamed:PLACEHOLDER_IMAGE]
                                     success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                         [self.avatarOfPoster setImage:image];
                                     }
                                     failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                         
                                     }];
    
    CALayer * layer = [self.avatarOfPoster layer];
    [layer setMasksToBounds:YES];
    [layer setCornerRadius:25.0];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (self.isCellWithText) {
        return 1 + [self.arrayWithImageURLs count];
    } else {
        return [self.arrayWithImageURLs count];
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.isCellWithText) {
        if (indexPath.row == 0) {
            // Text
            CGRect stringSize = [self.detailItem.text boundingRectWithSize:CGSizeMake(tableView.frame.size.width, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:FONT_SIZE_OF_THE_TEXT_CELL + 1]} context:nil];
            NSLog(@"%f",stringSize.size.height);
            UITextView *textView=[[UITextView alloc] initWithFrame:CGRectMake(5, 5, tableView.frame.size.width, stringSize.size.height + 15)];
            textView.font = [UIFont systemFontOfSize:FONT_SIZE_OF_THE_TEXT_CELL];
            textView.text = self.detailItem.text;
            textView.textColor = [UIColor blackColor];
            textView.editable = NO;
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:TEXT_CELL_IDENTIFIER forIndexPath:indexPath];
            [cell.textLabel setFont:[UIFont boldSystemFontOfSize:FONT_SIZE_OF_THE_TEXT_CELL]];
            [cell.contentView addSubview:textView];
            return cell;
        } else {
            //Images
            ImageCell *cell = [tableView dequeueReusableCellWithIdentifier:IMAGE_CELL_IDENTIFIER forIndexPath:indexPath];
            [cell.imageInCell setImageWithURLRequest:[NSURLRequest requestWithURL:[self.arrayWithImageURLs objectAtIndex:indexPath.row - 1]]
                                    placeholderImage:[UIImage imageNamed:PLACEHOLDER_IMAGE]
                                             success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                                 [cell.imageInCell setImage:image];
                                             }
                                             failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                                 
                                             }];
            return cell;
        }
    } else {
        //Images
        ImageCell *cell = [tableView dequeueReusableCellWithIdentifier:IMAGE_CELL_IDENTIFIER forIndexPath:indexPath];
        [cell.imageInCell setImageWithURLRequest:[NSURLRequest requestWithURL:[self.arrayWithImageURLs objectAtIndex:indexPath.row]]
                                placeholderImage:[UIImage imageNamed:PLACEHOLDER_IMAGE]
                                         success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                             [cell.imageInCell setImage:image];
                                         }
                                         failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                         }];
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.isCellWithText) {
        if (indexPath.row == 0) {
            CGRect stringSize = [self.detailItem.text boundingRectWithSize:CGSizeMake(tableView.frame.size.width, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:FONT_SIZE_OF_THE_TEXT_CELL + 1]} context:nil];
            return stringSize.size.height + 25;
        } else {
            return SIZE_OF_IMAGES;
        }
    } else {
        return SIZE_OF_IMAGES;
    }
}

@end
