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
    
    NSString *appID = APP_ID;
    NSString *scope = APP_ACCESSIBILITY_SCOPE;
    NSString *authLink = [NSString stringWithFormat:LOGIN_URL, appID, scope];
    NSURL *nsurl = [NSURL URLWithString:authLink];
    
    self.webView.delegate = self;
    NSURLRequest *nsrequest = [NSURLRequest requestWithURL:nsurl];
    [self.webView loadRequest:nsrequest];
}

-(void)webViewDidFinishLoad:(UIWebView *)webView {
    if ([self.webView.request.URL.absoluteString rangeOfString:@"access_token"].location != NSNotFound) {
        NSString *accessToken = [self stringBetweenString:@"access_token="
                                                andString:@"&"
                                              innerString:[[[webView request] URL] absoluteString]];
        NSArray *userAr = [[[[webView request] URL] absoluteString] componentsSeparatedByString:@"&user_id="];
        NSString *user_id = [userAr lastObject];
        NSLog(@"User id: %@", user_id);
        if(user_id){
            [[NSUserDefaults standardUserDefaults] setObject:user_id forKey:ACCESS_USER_ID];
        }
        if(accessToken){
            [[NSUserDefaults standardUserDefaults] setObject:accessToken forKey:ACCESS_TOKEN];
            [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:ACCESS_TOKEN_DATE];
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

@end
