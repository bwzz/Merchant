//
//  ProductDetailViewController.m
//  Merchant
//
//  Created by wanghb on 14-9-22.
//  Copyright (c) 2014年 bifubao. All rights reserved.
//

#import "ProductDetailViewController.h"
#import "ProductApi.h"
#import "OrderApi.h"

@interface ProductDetailViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *orderQrImageView;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *productDetailLabel;
@property (strong, nonatomic) ProductApi *productApi;
@property (strong, nonatomic) OrderApi *orderApi;

- (IBAction)refreshOrder:(id)sender;
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)setProduct:(NSDictionary*) product{
    L(product[@"product_name"]);
    self.navigationItem.title = product[@"product_name"];
    
    // fetch product detail
    Handler * productHandler = [[Handler alloc] init];
    productHandler.succedHandler = ^(Result* r) {
        L(r.result);
        _product = r.result;
        self.productDetailLabel.text = [r.result description];
    };
    self.productApi = [[ProductApi alloc] initWithDefaultHostName];
    [self.productApi productDetail:product[@"product_id"] handler:productHandler];
    [self refreshProductOrder:product[@"product_hash_id"]];
}

-(void)refreshProductOrder:(NSString*) productHashId {
    Handler * handler = [[Handler alloc] init];
    handler.succedHandler = ^(Result* r) {
        L(r.result);
        self.timeLabel.text = r.result[@"creation_time"];
        // Get the string
        NSString *stringToEncode = [NSString stringWithFormat:@"bitcoin:%@?amount=%@&order_hash_id=%@",r.result[@"onchain_receive_btc_address"],r.result[@"amont"],r.result[@"order_hash_id"]];
        
        // Generate the image
        CIImage *qrCode = [self createQRForString:stringToEncode];
        
        // Convert to an UIImage
        UIImage *qrCodeImg = [self createNonInterpolatedUIImageFromCIImage:qrCode withScale:3*[[UIScreen mainScreen] scale]];
        
        // And push the image on to the screen
        self.orderQrImageView.image = qrCodeImg;
    };
    if (self.orderApi == nil) {
        self.orderApi = [[OrderApi alloc] initWithDefaultHostName];
    }
    [self.orderApi createInternal:productHashId handler:handler];
}

- (IBAction)refreshOrder:(id)sender {
    [self refreshProductOrder:self.product[@"product_hash_id"]];
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
