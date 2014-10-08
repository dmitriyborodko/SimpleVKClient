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
    return 2;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.isCellWithText) {
        if (indexPath.row == 0) {
            NSString *label =  @"Sample String to get the Size for the textView Will definitely work ";
            CGSize stringSize = [self.detailItem.text sizeWithFont:[UIFont boldSystemFontOfSize:17]
                                  constrainedToSize:CGSizeMake(tableView.frame.size.width, MAXFLOAT)
                                      lineBreakMode:NSLineBreakByWordWrapping];
            NSLog(@"%f",stringSize.height);

            UITextView *textView=[[UITextView alloc] initWithFrame:CGRectMake(5, 5, tableView.frame.size.width, stringSize.height+10)];
            textView.font = [UIFont systemFontOfSize:15.0];
            textView.text = self.detailItem.text;
            textView.textColor = [UIColor blackColor];
            textView.editable = NO;
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"textCell" forIndexPath:indexPath];
            [cell.contentView addSubview:textView];
            
            return cell;
            
//            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"textCell" forIndexPath:indexPath];
//            cell.textLabel.text = self.detailItem.text;
//            return cell;
        } else {
            //Avatar
            ImageCell *cell = [tableView dequeueReusableCellWithIdentifier:@"imageCell" forIndexPath:indexPath];
            UIImage *imageAvatar = [[UIImage alloc] initWithData:self.detailItem.imageAvatar];
            [cell.imageInCell setImage:imageAvatar];
            return cell;
        }
    }
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"textCell" forIndexPath:indexPath];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.isCellWithText && indexPath.row == 0) {
        CGSize stringSize = [self.detailItem.text sizeWithFont:[UIFont boldSystemFontOfSize:15]
                                             constrainedToSize:CGSizeMake(tableView.frame.size.width, MAXFLOAT)
                                                 lineBreakMode:NSLineBreakByWordWrapping];
        return stringSize.height+25;
    } else {
        return 200;
    }
}

@end
