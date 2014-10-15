//
//  ViewController.m
//  Simple_VK_Client
//
//  Created by Dmitriy on 29/09/14.
//  Copyright (c) 2014 ALS. All rights reserved.
//

#import "LoginController.h"

@interface LoginController ()

@end

@implementation LoginController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationItem setHidesBackButton:YES]; 
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:SHOW_NEWS_CONTROLLER_IDENTIFIER]) {
    }
}

-(void)viewWillAppear:(BOOL)animated{
    if ([[NSUserDefaults standardUserDefaults] objectForKey:ACCESS_TOKEN]) {
        [self performSegueWithIdentifier:SHOW_NEWS_CONTROLLER_IDENTIFIER sender:nil];
    }
}

- (IBAction)loginButton:(id)sender {

}

@end
