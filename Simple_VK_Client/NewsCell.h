//
//  NewsCell.h
//  Simple_VK_Client
//
//  Created by Dmitriy on 01/10/14.
//  Copyright (c) 2014 ALS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NewsCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *nameOfPostSender;
@property (weak, nonatomic) IBOutlet UILabel *dateOfPost;
@property (weak, nonatomic) IBOutlet UILabel *textOfPost;
@property (weak, nonatomic) IBOutlet UILabel *likesOfPost;
@property (weak, nonatomic) IBOutlet UILabel *repostsOfPost;


@property (weak, nonatomic) IBOutlet UIImageView *imageOfPostSender;
@property (weak, nonatomic) IBOutlet UIImageView *imageOfPostOne;
@property (weak, nonatomic) IBOutlet UIImageView *imageOfPostTwo;


@end
