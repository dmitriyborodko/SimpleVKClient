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

- (IBAction)loginButton:(id)sender {
    [VKSdk initializeWithDelegate:self andAppId:@"4568899"];
    [VKSdk authorize:@[VK_PER_FRIENDS, VK_PER_WALL] revokeAccess:YES forceOAuth:YES];
}


- (void)vkSdkTokenHasExpired:(VKAccessToken *)expiredToken{
    
}

- (void)vkSdkShouldPresentViewController:(UIViewController *)controller{
    
}

- (void)vkSdkNeedCaptchaEnter:(VKError *)captchaError{
    
}

- (void)vkSdkUserDeniedAccess:(VKError *)authorizationError{
    [[[UIAlertView alloc] initWithTitle:@"Access denied" message:@"So you can't continue, bro =(" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
}

- (void)vkSdkReceivedNewToken:(VKAccessToken *)newToken{
    NSLog(@"SDK Did Receive New Token");
    NSLog(@"%@", [[VKSdk getAccessToken] userId]);
    [self performSegueWithIdentifier:@"showNewsController" sender:nil];
}


@end
