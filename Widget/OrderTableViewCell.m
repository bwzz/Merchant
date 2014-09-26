//
//  OrderTableViewCell.m
//  Merchant
//
//  Created by wanghb on 14-9-26.
//  Copyright (c) 2014年 bifubao. All rights reserved.
//

#import "OrderTableViewCell.h"

@interface OrderTableViewCell()

@property (weak, nonatomic) IBOutlet UILabel *emailLabel;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;

@end
@implementation OrderTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void) setOrder:(NSDictionary*) order {
    if (order[@"user_buyer"] != nil) {
        NSString* email = order[@"user_buyer"][@"user_email"];
        if ([email hasSuffix:@"@_bifubao_.com"]) {
            self.emailLabel.text = order[@"user_buyer"][@"mobile_phone_num"];
        } else {
            self.emailLabel.text = email;
        }
    } else {
        self.emailLabel.text = @"链上支付";
    }
    self.timeLabel.text = order[@"last_modify_time"];
    int handleStatus = [order[@"handle_status"] integerValue];
    if(handleStatus < 1000) {
        self.statusLabel.text = @"支付失败";
        self.statusLabel.textColor = [UIColor redColor];
    } else {
        self.statusLabel.text = @"支付成功";
        self.statusLabel.textColor = [UIColor blackColor];
    }
}
@end
