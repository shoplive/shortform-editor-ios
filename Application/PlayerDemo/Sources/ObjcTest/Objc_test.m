//
//  Objc_test.m
//  ShopLivePlayerDemo
//
//  Created by sangmin han on 5/27/24.
//  Copyright © 2024 com.app. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "ShopLivePlayerDemo-Bridging-Header.h"
#import <ShopLiveSDK/ShopLiveSDK-Swift.h>
#import <ShopliveSDKCommon/ShopliveSDKCommon-Swift.h>


@interface ViewController : UIViewController <ShopLiveSDKDelegate>

// Class properties and methods

@end


@implementation ViewController : UIViewController

- (void) viewDidLoad {
    [super viewDidLoad];

}


-(void) handleDownloadCouponWith:(NSString *)couponId result:(void (^)(ShopLiveCouponResult * _Nonnull))result {
    ShopLiveCouponResult *coupontResult = [[ShopLiveCouponResult alloc] initWithCouponId:@"test"
                                                                                 success:false message:@"test"
                                                                                 status: ShopLiveResultStatusHIDE alertType: ShopLiveResultAlertTypeALERT];


}

@end
