//
//  AuthorizationController.m
//  Simple_VK_Client
//
//  Created by Dmitriy on 01/10/14.
//  Copyright (c) 2014 ALS. All rights reserved.
//

#import "AuthorizationController.h"

@interface AuthorizationController ()

@end

@implementation AuthorizationController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    NSString *appID = @"4568899";
    NSString *scope = @"wall,friends";
    NSString *authLink = [NSString stringWithFormat:@"http://api.vk.com/oauth/authorize?client_id=%@&scope=%@&redirect_uri=http://api.vk.com/blank.html&display=touch&revoke=1&response_type=token", appID, scope];
    NSURL *nsurl = [NSURL URLWithString:authLink];
    
    self.webView.delegate = self;
    NSURLRequest *nsrequest = [NSURLRequest requestWithURL:nsurl];
    [self.webView loadRequest:nsrequest];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//-(void)webViewDidStartLoad:(UIWebView *)webView{
//    UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(self.view.center.x, self.view.center.y, 20.0f, 20.0f)];
//    [activityIndicator ]
//}

-(void)webViewDidFinishLoad:(UIWebView *)webView {
    if ([self.webView.request.URL.absoluteString rangeOfString:@"access_token"].location != NSNotFound) {
        NSString *accessToken = [self stringBetweenString:@"access_token="
                                                andString:@"&"
                                              innerString:[[[webView request] URL] absoluteString]];
        NSArray *userAr = [[[[webView request] URL] absoluteString] componentsSeparatedByString:@"&user_id="];
        NSString *user_id = [userAr lastObject];
        NSLog(@"User id: %@", user_id);
        if(user_id){
            [[NSUserDefaults standardUserDefaults] setObject:user_id forKey:@"VKAccessUserId"];
        }
        if(accessToken){
            [[NSUserDefaults standardUserDefaults] setObject:accessToken forKey:@"VKAccessToken"];
            [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:@"VKAccessTokenDate"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
        NSLog(@"vkWebView response: %@",[[[webView request] URL] absoluteString]);
        [self dismissViewControllerAnimated:YES completion:nil];
    } else if ([self.webView.request.URL.absoluteString rangeOfString:@"error"].location != NSNotFound) {
        NSLog(@"Error: %@", self.webView.request.URL.absoluteString);
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    
}

- (NSString*)stringBetweenString:(NSString*)start
                       andString:(NSString*)end
                     innerString:(NSString*)str
{
    NSScanner* scanner = [NSScanner scannerWithString:str];
    [scanner setCharactersToBeSkipped:nil];
    [scanner scanUpToString:start intoString:NULL];
    if ([scanner scanString:start intoString:NULL]) {
        NSString* result = nil;
        if ([scanner scanUpToString:end intoString:&result]) {
            return result;
        }
    }
    return nil;
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
