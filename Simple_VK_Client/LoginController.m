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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"showNewsController"]) {
        [[segue destinationViewController] setManagedObjectContext:self.managedObjectContext];
    }
}

-(void)viewWillAppear:(BOOL)animated{
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"VKAccessToken"]) {
        [self performSegueWithIdentifier:@"showNewsController" sender:nil];
    }
}

- (IBAction)loginButton:(id)sender {

}

@end
