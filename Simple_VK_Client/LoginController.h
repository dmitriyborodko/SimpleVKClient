//
//  ViewController.h
//  Simple_VK_Client
//
//  Created by Dmitriy on 29/09/14.
//  Copyright (c) 2014 ALS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VKSdk.h"

@interface LoginController : UIViewController <VKSdkDelegate>

- (IBAction)loginButton:(id)sender;

@end

