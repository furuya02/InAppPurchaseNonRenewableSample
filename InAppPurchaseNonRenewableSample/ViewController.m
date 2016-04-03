//
//  ViewController.m
//  InAppPurchaseNonRenewableSample
//
//  Created by hirauchi.shinichi on 2016/04/03.
//  Copyright © 2016年 SAPPOROWORKS. All rights reserved.
//

#import "ViewController.h"
#import "AppDelegate.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (nonatomic) SKProduct *product;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    AppDelegate *application = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    application.viewController = self;


    // プロダクト情報の問い合わせ
    [self appendLog:@"\n>プロダクト情報の問い合わせ"];
    NSArray *identifiers = @[@"jp.ne.sapporoworks.InAppPurchaseNonRenewableSample.ProductId2"];

    [[CargoBay sharedManager] productsWithIdentifiers:[NSSet setWithArray:identifiers]
                                              success:^(NSArray *products, NSArray *invalidIdentifiers) {
                                                  if(products.count > 0){
                                                      for( SKProduct *product in products){

                                                          _product = product; // 有効なプロダクトを保存する

                                                          [self appendLog:@"\nプロダクト名:"];
                                                          [self appendLog:product.productIdentifier];
                                                          [self appendLog:@"\nタイトル:"];
                                                          [self appendLog:product.localizedTitle];
                                                          [self appendLog:@"\n詳細:"];
                                                          [self appendLog:product.localizedDescription];
                                                          [self appendLog:@"\n価格:"];
                                                          [self appendLog:product.price.description];
                                                      }
                                                  }
                                                  if( invalidIdentifiers.count > 0){
                                                      [self appendLog:@"\n[無効なプロダクト]"];
                                                      for( SKProduct *product in invalidIdentifiers){
                                                          [self appendLog:@"\nプロダクト名:"];
                                                          [self appendLog:product];
                                                      }
                                                  }
                                              } failure:^(NSError *error) {
                                                  [self appendLog:@"\n[エラー]"];
                                                  [self appendLog:error.description];
                                              }];
    
}
// リストアボタン
- (IBAction)tapRestoreButton:(id)sender {

    NSArray *purchaseData = [self readPurchaseData];

    [self appendLog:@"\npurchase_date_ms:"];
    [self appendLog:purchaseData[0]];

    [self appendLog:@"\npurchase_date:"];
    [self appendLog:purchaseData[1]];

    [self appendLog:@"\nunique_identifier:"];
    [self appendLog:purchaseData[2]];

    [self appendLog:@"\nunique_vendor_identifier:"];
    [self appendLog:purchaseData[2]];


}

// 購入ボタン
- (IBAction)tapPurchaseButton:(id)sender {
    [self appendLog:@"\n>購入開始"];
    SKPayment *payment = [SKPayment paymentWithProduct:_product];
    [[SKPaymentQueue defaultQueue] addPayment:payment];


}

// 購入完了の処理
- (void) purchased:(SKPaymentTransaction *)transaction {
    [self appendLog:@"\n>購入完了"];

    [[CargoBay sharedManager] verifyTransaction:transaction password:nil success:^(NSDictionary *json) {

        NSLog(json.description);


        NSString *status = [json objectForKey:@"status"];
        [self appendLog:@"\nStatus:"];
        [self appendLog:status];


        NSDictionary *receipt = [json objectForKey:@"receipt"];

        NSString *product_id = [receipt objectForKey:@"product_id"];
        [self appendLog:@"\nproduct_id:"];
        [self appendLog:product_id];


        NSString *purchase_date_ms = [receipt objectForKey:@"purchase_date_ms"];
        [self appendLog:@"\npurchase_date_ms:"];
        [self appendLog:purchase_date_ms];

        NSString *purchase_date = [receipt objectForKey:@"purchase_date"];
        [self appendLog:@"\npurchase_date:"];
        [self appendLog:purchase_date];

        NSString *unique_identifier = [receipt objectForKey:@"unique_identifier"];
        [self appendLog:@"\nunique_identifier:"];
        [self appendLog:unique_identifier];

        NSString *unique_vendor_identifier = [receipt objectForKey:@"unique_vendor_identifier"];
        [self appendLog:@"\nunique_vendor_identifier:"];
        [self appendLog:unique_vendor_identifier];

        // データ保存
        NSArray *purchaseData = @[purchase_date_ms, purchase_date, unique_identifier,unique_vendor_identifier ];
        [self savePurchaseData:purchaseData];

    } failure:^(NSError *error) {
        [self appendLog:@"\n>Error:"];
        [self appendLog:error.description];
    }];
}

// データ保存
- (BOOL) savePurchaseData :(NSArray *)purchaseData {

    [self appendLog:@"\n>iCloudへの保存"];

    // iCloudへのデータ保存
    NSUbiquitousKeyValueStore* cloudStore = [NSUbiquitousKeyValueStore defaultStore];
    [cloudStore setObject: purchaseData forKey: @"purchaseData"];
    return [cloudStore synchronize];
}

// データ読み込み
- (NSArray *) readPurchaseData {

    [self appendLog:@"\n>iCloudからの読み込み"];
    // iCloudからのデータ読み込み
    NSUbiquitousKeyValueStore* cloudStore = [NSUbiquitousKeyValueStore defaultStore];
    [cloudStore synchronize];
    return [cloudStore arrayForKey: @"purchaseData"];

}


// ログの追加
- (void) appendLog:(NSString *)log {
    self.textView.text = [NSString stringWithFormat:@"%@%@",self.textView.text,log];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
