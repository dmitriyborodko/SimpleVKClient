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
    [self configureView];
    
    //Load Images
    self.arrayOfImages = [[NSMutableArray alloc] init];
    NSMutableArray *arrayWithImageURLs = [[NSMutableArray alloc] initWithArray:[NSKeyedUnarchiver unarchiveObjectWithData:self.detailItem.dataWithArrayOfImages]];
    for (NSURL *imageURL in arrayWithImageURLs) {
        UIImage *image = [[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:imageURL]];
        if (image) {
            [self.arrayOfImages addObject:image];
        }
    }
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
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"YYYY-MM-dd\'T\'HH:mm:ssZZZZZ"];
    NSDate *formattedDate = [dateFormat dateFromString:[self.detailItem.date description]];
    [dateFormat setDateFormat:@"HH:mm:ss dd/MM"];
    [self.dateOfPost setText:[NSString stringWithFormat:@"%@",[dateFormat stringFromDate:formattedDate]]];
    [self.likesOfPost setText:self.detailItem.likes];
    [self.repostOfPost setText:self.detailItem.reposts];
    
    //Avatar
    UIImage *imageAvatar = [[UIImage alloc] initWithData:self.detailItem.imageAvatar];
    [self.avatarOfPoster setImage:imageAvatar];
    CALayer * layer = [self.avatarOfPoster layer];
    [layer setMasksToBounds:YES];
    [layer setCornerRadius:25.0];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (self.isCellWithText) {
        return 1 + [self.arrayOfImages count];
    } else {
        return [self.arrayOfImages count];
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.isCellWithText) {
        if (indexPath.row == 0) {
            // Text
//            CGSize stringSize = [self.detailItem.text sizeWithFont:[UIFont systemFontOfSize:FONT_SIZE_OF_THE_TEXT_CELL + 1]
//                                  constrainedToSize:CGSizeMake(tableView.frame.size.width, MAXFLOAT)
//                                      lineBreakMode:NSLineBreakByWordWrapping];
            CGRect stringSize = [self.detailItem.text boundingRectWithSize:CGSizeMake(tableView.frame.size.width, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:FONT_SIZE_OF_THE_TEXT_CELL + 1]} context:nil];
            NSLog(@"%f",stringSize.size.height);
            UITextView *textView=[[UITextView alloc] initWithFrame:CGRectMake(5, 5, tableView.frame.size.width, stringSize.size.height + 15)];
            textView.font = [UIFont systemFontOfSize:FONT_SIZE_OF_THE_TEXT_CELL];
            textView.text = self.detailItem.text;
            textView.textColor = [UIColor blackColor];
            textView.editable = NO;
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"textCell" forIndexPath:indexPath];
            [cell.textLabel setFont:[UIFont boldSystemFontOfSize:FONT_SIZE_OF_THE_TEXT_CELL]];
            [cell.contentView addSubview:textView];
            return cell;
            
        } else {
            //Images
            ImageCell *cell = [tableView dequeueReusableCellWithIdentifier:@"imageCell" forIndexPath:indexPath];
            [cell.imageInCell setImage:[self.arrayOfImages objectAtIndex:indexPath.row - 1]];
            return cell;
        }
    } else {
        //Images
        ImageCell *cell = [tableView dequeueReusableCellWithIdentifier:@"imageCell" forIndexPath:indexPath];
        [cell.imageInCell setImage:[self.arrayOfImages objectAtIndex:indexPath.row]];
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.isCellWithText) {
        if (indexPath.row == 0) {
//            CGSize stringSize = [self.detailItem.text sizeWithFont:[UIFont systemFontOfSize:FONT_SIZE_OF_THE_TEXT_CELL + 1]
//                                                 constrainedToSize:CGSizeMake(tableView.frame.size.width, MAXFLOAT)
//                                                     lineBreakMode:NSLineBreakByWordWrapping];
            CGRect stringSize = [self.detailItem.text boundingRectWithSize:CGSizeMake(tableView.frame.size.width, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:FONT_SIZE_OF_THE_TEXT_CELL + 1]} context:nil];
            return stringSize.size.height + 25;
        } else {
            UIImage *imageToSizeCell = [self.arrayOfImages objectAtIndex:indexPath.row - 1];
            return imageToSizeCell.size.height;
        }
    } else {
        UIImage *imageToSizeCell = [self.arrayOfImages objectAtIndex:indexPath.row];
        return imageToSizeCell.size.height;
    }
}

@end
