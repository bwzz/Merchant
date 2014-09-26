//
//  LoginViewController.m
//  Merchant
//
//  Created by wanghb on 14-9-25.
//  Copyright (c) 2014年 bifubao. All rights reserved.
//

#import "LoginViewController.h"
#import "UserApi.h"

@interface LoginViewController () <UITextFieldDelegate>
@property (strong, nonatomic) UserApi  *userapi;
@property (weak, nonatomic) IBOutlet UITextField *usernameLabel;
@property (weak, nonatomic) IBOutlet UITextField *passwordLabel;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
- (IBAction)doLogin:(id)sender;
@end

@implementation LoginViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.usernameLabel becomeFirstResponder];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    if ([self.usernameLabel isFirstResponder]) {
        [self.passwordLabel becomeFirstResponder];
    } else if ([self.passwordLabel isFirstResponder]) {
        [self doLogin:self];
    }
    return YES;
}

- (IBAction)doLogin:(id)sender {
    Lf(@"username %@ password %@", self.usernameLabel.text, self.passwordLabel.text);
    if ([self.usernameLabel.text isEqualToString:@""] || [self.passwordLabel.text isEqualToString:@""]) {
        UIAlertView *at = [[UIAlertView alloc] initWithTitle:@"user name and password shoud not be empty" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [at show];
        return;
    }
    if (self.userapi == nil) {
        self.userapi = [[UserApi alloc] initWithDefaultHostNameAndController:self];
    }
    Handler* handler = [[Handler alloc] init];
    handler.succedHandler = ^(Result* r) {
        [self dismissViewControllerAnimated:YES completion:nil];
        [self.userapi createAppForRefreshToken:nil];
    };
    handler.failedHandler = ^(Result* r) {
        UIAlertView *at = [[UIAlertView alloc] initWithTitle:@"user name and password dose not match" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [at show];
    };
    [self.userapi loginWithName:self.usernameLabel.text password:self.passwordLabel.text handler:handler];
}
@end
