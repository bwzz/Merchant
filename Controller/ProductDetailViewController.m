//
//  ProductDetailViewController.m
//  Merchant
//
//  Created by wanghb on 14-9-22.
//  Copyright (c) 2014年 bifubao. All rights reserved.
//

#import "ProductDetailViewController.h"
#import "OrderApi.h"
#import "OrderChangedToViewController.h"
#import "OrderOfProductTableViewController.h"

@interface ProductDetailViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *orderQrImageView;
@property (weak, nonatomic) IBOutlet UILabel *productDetailLabel;
@property (weak, nonatomic) IBOutlet UILabel *btcPriceLabel;
@property (weak, nonatomic) IBOutlet UILabel *cnyPriceLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *requestOrderProgress;

@property (strong, nonatomic) OrderApi *orderApi;
@property (strong, nonatomic) NSTimer *refreshTimer;
@property (strong, nonatomic) NSDictionary *currentOrder;
@property (atomic) BOOL disappeared;

@end

@implementation ProductDetailViewController

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

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.disappeared = YES;
    L(@"view did appear");
    Lf(@"product %@", self.product);
    // 状态机从这里开始
    [self checkAndRefreshOrder];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    self.disappeared = NO;
    L(@"view did viewDidDisappear");
    if (self.refreshTimer != nil) {
        [self.refreshTimer invalidate];
        self.refreshTimer = nil;
    }
    Lf(@"product %@", self.product);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)setProduct:(NSDictionary*) product{
    L(product[@"product_name"]);
    self.navigationItem.title = product[@"product_name"];
    _product = product;
}

- (void)checkAndRefreshOrder {
    if (self.currentOrder == nil) {
        // fetch order
        [self refreshProductOrder:self.product[@"product_hash_id"]];
    } else {
        // check order status
        if (self.orderApi == nil) {
            self.orderApi = [[OrderApi alloc] initWithDefaultHostNameAndController:self];
        }
        Handler* handler = [[Handler alloc] init];
        handler.succedHandler = ^(Result* r) {
            [self updateOrderInformation:r.result];
            self.currentOrder = r.result;
            int status = [[r.result valueForKey:@"handle_status"] intValue];
            [self handleOrderStatus:status];
        };
        [self.orderApi detail:self.currentOrder[@"order_hash_id"] handler:handler];
    }
}

-(void)refreshProductOrder:(NSString*) productHashId {
    self.orderQrImageView.alpha = 0.1f;
    [self.requestOrderProgress startAnimating];
    [self.requestOrderProgress setHidesWhenStopped:YES];
    Handler * handler = [[Handler alloc] init];
    handler.succedHandler = ^(Result* r) {
        [self updateOrderInformation:r.result];
        self.currentOrder = r.result;
        [self checkAndRefreshOrder];
    };
    if (self.orderApi == nil) {
        self.orderApi = [[OrderApi alloc] initWithDefaultHostNameAndController:self];
    }
    [self.orderApi createInternal:productHashId handler:handler];
}

-(void)updateOrderInformation:(NSDictionary*) order {
    if (self.currentOrder == nil || ![self.currentOrder[@"pay_btc"] isEqualToString:order[@"pay_btc"]]) {
        // show qrcode
        NSString *stringToEncode = [NSString stringWithFormat:@"bitcoin:%@?amount=%@&order_hash_id=%@",order[@"onchain_receive_btc_address"],order[@"pay_btc"],order[@"order_hash_id"]];
        self.orderQrImageView.image = [self generateQrImage:stringToEncode];
    }
    self.orderQrImageView.alpha = 1.0f;
    [self.requestOrderProgress stopAnimating];
    self.btcPriceLabel.text = order[@"pay_btc"];
    self.cnyPriceLabel.text = order[@"pay_cny"];
    self.productDetailLabel.text = order[@"product"][@"product_desc"];
}

 #pragma mark - Navigation

 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
 {
     // Get the new view controller using [segue destinationViewController].
     // Pass the selected object to the new view controller.
     L(@"prepare segue");
     if ([[segue identifier] isEqualToString:@"OrderChangedTo"]) {
         [[segue destinationViewController] setOrder:self.currentOrder];
         // 在prepareForSegue之后执行，使这个controller达到初始状态
         self.currentOrder = nil;
     } else if ([[segue identifier] isEqualToString:@"orderList"]) {
         [[segue destinationViewController] setProduct:self.product];
     }
 }

- (void)handleOrderStatus:(int) status {
    Lf(@"handle status %d", status);
    if (!self.disappeared) {
        return;
    }
    if (status < 900) {
        // uncomplete, check again after 5s
        self.refreshTimer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(checkAndRefreshOrder) userInfo:nil repeats:NO];
    } else {
        [self.refreshTimer invalidate];
        self.refreshTimer = nil;
        [self performSegueWithIdentifier:@"OrderChangedTo" sender:self];
    }
}

- (UIImage*)generateQrImage:(NSString*) string {
    // Generate the image
    CIImage *qrCode = [self createQRForString:string];
    // Convert to an UIImage
    UIImage *qrCodeImg = [self createNonInterpolatedUIImageFromCIImage:qrCode withScale:3*[[UIScreen mainScreen] scale]];
    return qrCodeImg;
}

// Gennerate ORCode
- (CIImage *)createQRForString:(NSString *)qrString
{
    // Need to convert the string to a UTF-8 encoded NSData object
    NSData *stringData = [qrString dataUsingEncoding:NSUTF8StringEncoding];
    
    // Create the filter
    CIFilter *qrFilter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    // Set the message content and error-correction level
    [qrFilter setValue:stringData forKey:@"inputMessage"];
    [qrFilter setValue:@"M" forKey:@"inputCorrectionLevel"];
    
    // Send the image back
    return qrFilter.outputImage;
}

- (UIImage *)createNonInterpolatedUIImageFromCIImage:(CIImage *)image withScale:(CGFloat)scale
{
    // Render the CIImage into a CGImage
    CGImageRef cgImage = [[CIContext contextWithOptions:nil] createCGImage:image fromRect:image.extent];
    
    // Now we'll rescale using CoreGraphics
    UIGraphicsBeginImageContext(CGSizeMake(image.extent.size.width * scale, image.extent.size.width * scale));
    CGContextRef context = UIGraphicsGetCurrentContext();
    // We don't want to interpolate (since we've got a pixel-correct image)
    CGContextSetInterpolationQuality(context, kCGInterpolationNone);
    CGContextDrawImage(context, CGContextGetClipBoundingBox(context), cgImage);
    // Get the image out
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    // Tidy up
    UIGraphicsEndImageContext();
    CGImageRelease(cgImage);
    return scaledImage;
}

@end
