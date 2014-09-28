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
@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UILabel *reasonLabel;
- (IBAction)back:(id)sender;

@property (strong, nonatomic) NSDictionary *order;
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
    self.backButton.layer.borderWidth = 1;
    self.backButton.layer.borderColor = [[UIColor blueColor] CGColor];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setOrder:(NSDictionary*)order {
    Lf(@"order hash id %@",[order valueForKey:@"order_hash_id"]);
    _order = order;
}

- (void)viewWillAppear:(BOOL)animated {
    NSDictionary* order = self.order;
    int status = [[order valueForKey:@"handle_status"] intValue];
    if (status>900&&status<1000) {
        self.orderStateLabel.text = @"支付金额与订单价格不符";
        self.reasonLabel.text = [NSString stringWithFormat:@"订单价格：%@\t实付金额：%@",[self formate:order[@"pay_btc"]], [self formate:order[@"btc_received"]]];
        self.orderStateLabel.textColor = [UIColor redColor];
    } else if (status>=1000) {
        self.orderStateLabel.text = @"支付成功";
        self.reasonLabel.text = @"";
    } else {
        self.orderStateLabel.text = @"支付未完成";
        self.reasonLabel.text = @"";
        self.orderStateLabel.textColor = [UIColor redColor];
    }
}

- (NSString *)formate:(id)value {
    if (value == (id)[NSNull null]) {
        return @"0";
    }
    double num = [value doubleValue];
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
    [formatter setUsesGroupingSeparator:YES];
    //[formatter setMinimumFractionDigits:8];
    [formatter setMaximumFractionDigits:8];
    return [formatter stringFromNumber:[NSNumber numberWithDouble:num / 100000000.000000000]];
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
