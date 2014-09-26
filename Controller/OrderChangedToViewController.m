//
//  OrderChangedToViewController.m
//  Merchant
//
//  Created by wanghb on 14-9-23.
//  Copyright (c) 2014年 bifubao. All rights reserved.
//

#import "OrderChangedToViewController.h"

@interface OrderChangedToViewController ()
@property (weak, nonatomic) IBOutlet UILabel *orderStateLabel;
- (IBAction)back:(id)sender;
@end

@implementation OrderChangedToViewController

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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setOrder:(NSDictionary*)order {
    Lf(@"order hash id %@",[order valueForKey:@"order_hash_id"]);
    int status = [[order valueForKey:@"handle_status"] intValue];
    if (status>900&&status<1000) {
        self.orderStateLabel.text = @"unfull payment";
    } else if (status>=1000) {
        self.orderStateLabel.text = @"payment completed";
    } else {
        self.orderStateLabel.text = @"order unpayed";
    }
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

- (IBAction)back:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
@end
