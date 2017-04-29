//
//  SignUpViewController.m
//  StreamMusicPlayer
//
//  Created by Mac Developer001 on 8/8/16.
//  Copyright © 2016 SCN. All rights reserved.
//

#import "SignUpViewController.h"
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <FBSDKCoreKit/FBSDKAccessToken.h>
#import <FBSDKCoreKit/FBSDKGraphRequest.h>
#import "RegisterTask.h"
#import "LoginTask.h"
#import "GlobalVars.h"

@interface SignUpViewController ()
@property (weak, nonatomic) IBOutlet UITextField *emailField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@end

@implementation SignUpViewController {
    UIActivityIndicatorView *waitPopup;
    RegisterTask *registerTask;
    LoginTask *loginTask;
    NSString *email;
    NSString *password;
    NSString *facebookId;
}
@synthesize emailField;
@synthesize passwordField;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(handleSingleTap)];
    
    [self.view addGestureRecognizer:tap];
    [self.navigationController setNavigationBarHidden:NO animated:TRUE];
    
    waitPopup = [[GlobalVars sharedInstance] showWaitingDialog:self.view];
    registerTask = [[RegisterTask alloc] init];
    loginTask = [[LoginTask alloc] init];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)handleSingleTap {
    [self.view endEditing:TRUE];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == emailField) {
        [passwordField becomeFirstResponder];
    }
    if (textField == passwordField) {
        [self signupAction:nil];
        [passwordField resignFirstResponder];
    }
    return YES;
}

- (IBAction)signupAction:(id)sender {
    email = emailField.text;
    password = passwordField.text;
    facebookId = @"";
    if ([email isEqualToString:@""] || [password isEqualToString:@""])
        return;
    [self sendRegisterRequest];
}

- (IBAction)signupFacebookAction:(id)sender {
    FBSDKLoginManager *login = [[FBSDKLoginManager alloc] init];
    [login
     logInWithReadPermissions: @[@"email"]
     fromViewController:self
     handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
         if (error) {
             NSLog(@"Process error");
         } else if (result.isCancelled) {
             NSLog(@"Cancelled");
         } else {
             NSLog(@"Logged in");
             if ([FBSDKAccessToken currentAccessToken]) {
                 NSMutableDictionary* parameters = [NSMutableDictionary dictionary];
                 [parameters setValue:@"id,name,email" forKey:@"fields"];
                 
                 [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:parameters]
                  startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection,
                                               id result, NSError *error) {
                      email = [result objectForKey:@"email"];
                      password = @"";
                      facebookId = [result objectForKey:@"id"];
                      [self sendRegisterRequest];
                  }];
             }
         }
     }];
}

- (void)sendRegisterRequest {
    [waitPopup startAnimating];
    [registerTask sendRequest:email Password:password FacebookId:facebookId Response:^(int code, NSDictionary *result){
        [waitPopup stopAnimating];
        if (code == ERR_OK) {
            [loginTask sendRequest:email Password:password FacebookId:facebookId Response:^(int code, NSDictionary *result){
                [waitPopup stopAnimating];
                if (code == ERR_OK) {
                    GlobalVars *global = [GlobalVars sharedInstance];
                    global.sessionId = [result objectForKey:@"session_id"];
                    global.userId = [result objectForKey:@"user_id"];
                    global.email = [result objectForKey:@"email"];
                    global.password = [result objectForKey:@"password"];
                    global.facebookId = [result objectForKey:@"facebook_id"];
                    [self performSegueWithIdentifier:@"signupSuccess" sender:self];
                } else {    // 실패
                    [self presentViewController:[GlobalVars networkErrAlert] animated:TRUE completion:nil];
                }
            }];
            
            [waitPopup startAnimating];
        } else {
            [self presentViewController:[GlobalVars networkErrAlert] animated:TRUE completion:nil];
        }
    }];
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
