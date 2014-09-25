//
//  ProductTableViewController.m
//  Merchant
//
//  Created by wanghb on 14-9-22.
//  Copyright (c) 2014年 bifubao. All rights reserved.
//

#import "ProductTableViewController.h"
#import "ProductApi.h"
#import "ProductDetailViewController.h"
#import "UserApi.h"

@interface ProductTableViewController ()
@property (strong, nonatomic) ProductApi *productApi;
@end

@implementation ProductTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if([userDefaults valueForKey:@"rsa_private_key"] == nil || [userDefaults valueForKey:@"token"]==nil) {
        [self launchLogin];
    } else {
        self.productApi =[[ProductApi alloc] initWithDefaultHostName];
        [self refreshProducts];
    }
    
    // setup pull refresh
    UIRefreshControl *refresh = [[UIRefreshControl alloc] init];
    [refresh addTarget:self action:@selector(refreshProducts) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refresh;
}

- (void)refreshProducts {
    Handler* handler = [[Handler alloc] init];
    handler.succedHandler = ^(Result* result) {
        self.products = result.result[@"items"];
        [self.tableView reloadData];
        [self.refreshControl endRefreshing];
    };
    ProductApi* api = [[ProductApi alloc] initWithDefaultHostName];
    [api listWithPageNo:1 andPageSize:100 handler:handler];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.products count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *TableSampleIdentifier = @"ProductCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:TableSampleIdentifier];
    if (cell == nil) {
        NSLog(@"%s %ld", "hehe", (long)indexPath.row);
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:TableSampleIdentifier];
    };
    
    NSDictionary *product = (self.products)[indexPath.row];
    
    cell.textLabel.text = product[@"product_name"];
    cell.detailTextLabel.text = product[@"seller_hint"];
    return cell;
}

/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
 {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
 } else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }
 }
 */

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
 {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([[segue identifier] isEqualToString:@"showProductDetail"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        NSDictionary *product = (self.products)[indexPath.row];
        [[segue destinationViewController] setProduct:product];
    }
    
}

- (void)launchLogin {
    [self performSegueWithIdentifier:@"Login" sender:self];
}
@end
