//
//  OrderOfProductTableViewController.m
//  Merchant
//
//  Created by wanghb on 14-9-26.
//  Copyright (c) 2014年 bifubao. All rights reserved.
//

#import "OrderOfProductTableViewController.h"
#import "ProductApi.h"
#import "OrderTableViewCell.h"

@interface OrderOfProductTableViewController ()
@property (nonatomic) ProductApi* productApi;
@property (nonatomic) NSMutableArray* orders;
@property (nonatomic) int pageNum;
@property (nonatomic) BOOL hasMoreData;
@property (nonatomic) BOOL isLoading;
@end

static int pageSize = 50;

@implementation OrderOfProductTableViewController

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
    
    // setup pull refresh
    UIRefreshControl *refresh = [[UIRefreshControl alloc] init];
    [refresh addTarget:self action:@selector(refreshOrders) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refresh;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (self.orders == nil) {
        self.productApi = [[ProductApi alloc] initWithDefaultHostNameAndController:self];
        [self refreshOrders];
    }
}

-(void)setProduct:(NSDictionary*) product{
    L(product[@"product_name"]);
    _product = product;
}

- (void)refreshOrders {
    Handler* handler = [[Handler alloc] init];
    handler.succedHandler = ^(Result* result) {
        self.orders = [[NSMutableArray alloc] initWithArray:result.result[@"items"]];
        [self reloadData:[self.orders count] < [result.result[@"total_count"] intValue]];
        [self.refreshControl endRefreshing];
        self.pageNum = 1;
    };
    handler.failedHandler = ^(Result* result) {
        [self.refreshControl endRefreshing];
    };
    handler.networkErrorHandler = ^(MKNetworkOperation *errorOp, NSError* error) {
        [self.refreshControl endRefreshing];
    };
    self.isLoading = YES;
    [self.productApi orderList:self.product[@"product_id"] page:1 pageSize:pageSize handler:handler];
}

- (void)reloadData:(BOOL)hasMoreData {
    Lf(@"reload data %lu %hhd", (unsigned long)[self.orders count], hasMoreData);
    self.hasMoreData = hasMoreData;
    [self.tableView reloadData];
    self.tableView.tableFooterView = nil;
    if (hasMoreData) {
        UIView *tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.tableView.bounds.size.width, 40.0f)];
        UIActivityIndicatorView *tableFooterActivityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(75.0f, 10.0f, 20.0f, 20.0f)];
        [tableFooterActivityIndicator setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
        [tableFooterActivityIndicator startAnimating];
        [tableFooterActivityIndicator setCenter:tableFooterView.center];
        [tableFooterView addSubview:tableFooterActivityIndicator];
        self.tableView.tableFooterView = tableFooterView;
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    Lf(@"end dragging %f %f %f",scrollView.contentOffset.y, scrollView.contentSize.height, scrollView.frame.size.height);
    if(self.tableView.tableFooterView != nil && scrollView.contentOffset.y > 0 && scrollView.contentOffset.y > ((scrollView.contentSize.height - scrollView.frame.size.height))) {
        Lf(@"load more data from %d",[self.orders count]);
        Handler* handler = [[Handler alloc] init];
        handler.succedHandler = ^(Result* result) {
            NSMutableArray* items = result.result[@"items"];
            [self.orders addObjectsFromArray:items];
            [self reloadData:[self.orders count] < [result.result[@"total_count"] intValue]];
            [self.refreshControl endRefreshing];
            ++ self.pageNum;
            self.isLoading = NO;
        };
        handler.failedHandler = ^(Result* result) {
            [self.refreshControl endRefreshing];
            self.isLoading = NO;
        };
        handler.networkErrorHandler = ^(MKNetworkOperation *errorOp, NSError* error) {
            [self.refreshControl endRefreshing];
            self.isLoading = NO;
        };
        self.isLoading = YES;
        [self.productApi orderList:self.product[@"product_id"] page:self.pageNum pageSize:pageSize handler:handler];
    }
}

- (void)loadMoreData {
    if (!self.hasMoreData || self.isLoading) {
        return;
    }
    Lf(@"load more data from %d",[self.orders count]);
    Handler* handler = [[Handler alloc] init];
    handler.succedHandler = ^(Result* result) {
        NSMutableArray* items = result.result[@"items"];
        [self.orders addObjectsFromArray:items];
        [self reloadData:[self.orders count] < [result.result[@"total_count"] intValue]];
        [self.refreshControl endRefreshing];
        ++ self.pageNum;
        self.isLoading = NO;
    };
    handler.failedHandler = ^(Result* result) {
        [self.refreshControl endRefreshing];
        self.isLoading = NO;
    };
    handler.networkErrorHandler = ^(MKNetworkOperation *errorOp, NSError* error) {
        [self.refreshControl endRefreshing];
        self.isLoading = NO;
    };
    self.isLoading = YES;
    [self.productApi orderList:self.product[@"product_id"] page:self.pageNum pageSize:pageSize handler:handler];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath*)indexPath {
//    Lf(@"willDisplayCell %d %d", indexPath.row, [self.orders count]);
    if (self.hasMoreData && indexPath.row == [self.orders count] - 1) {
        [self loadMoreData];
    }
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
    return [self.orders count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *TableSampleIdentifier = @"OrderCell";
    OrderTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:TableSampleIdentifier];
    if (cell == nil) {
        cell = [[OrderTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:TableSampleIdentifier];
    };
    NSDictionary *order = (self.orders)[indexPath.row];
    [cell setOrder:order];
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
