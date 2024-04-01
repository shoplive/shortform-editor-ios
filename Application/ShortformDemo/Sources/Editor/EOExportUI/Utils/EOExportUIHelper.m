//
//  EOExportUIHelper.m
//  EOExportUI
//
//

#import "EOExportUIHelper.h"
#include <sys/utsname.h>

CGFloat EO_ScreenWidth(void)
{
    return [[UIScreen mainScreen] bounds].size.width;
}

CGFloat EO_ScreenHeight(void)
{
    return [[UIScreen mainScreen] bounds].size.height;;
}

@implementation EOExportUIHelper

+ (CGFloat)EO_topBarMargn
{
    return [EOExportUIHelper EO_topBarMargn:[EOExportUIHelper eo_export_currentViewController].navigationController];
}

+ (CGFloat)EO_topBarMargn:(UINavigationController *)nav
{
    CGFloat topBarMargn = EO_StatusBarHeight();
    if(nav != nil && [nav.navigationBar isHidden] == NO) {
        topBarMargn += nav.navigationBar.frame.size.height;
    }
    return topBarMargn;
}

+ (UIEdgeInsets)EO_safeAreaInsets {
    if (@available(iOS 11.0, *)) {
        return [EOExportUIHelper eo_export_currentWindow].safeAreaInsets;
    } else {
        return UIEdgeInsetsZero;
    }
}

+ (CAShapeLayer *)EO_topRoundCornerShapeLayerWithFrame:(CGRect)frame
                                             radius:(CGFloat)radius
{
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    CGFloat maskRadius = radius;
    shapeLayer.path = [UIBezierPath bezierPathWithRoundedRect:frame
                                            byRoundingCorners:UIRectCornerTopLeft | UIRectCornerTopRight
                                                  cornerRadii:CGSizeMake(maskRadius, maskRadius)].CGPath;
    return shapeLayer;
}

+ (UIViewController *)eo_export_currentViewController
{
    UIViewController *topViewController = nil;
    
    UIWindow* window = [EOExportUIHelper eo_export_currentWindow];
   
    UIViewController *rootViewController = window.rootViewController;
    if ([rootViewController isKindOfClass:[UITabBarController class]]) {
        topViewController = [(UITabBarController *)rootViewController selectedViewController];
    } else {
        topViewController = rootViewController;
    }
    if ([topViewController isKindOfClass:[UINavigationController class]]) {
        topViewController = [(UINavigationController *)topViewController topViewController];
    }
    while (topViewController.presentedViewController) {
        topViewController = topViewController.presentedViewController;
        if ([topViewController isKindOfClass:[UINavigationController class]]) {
            UINavigationController *presentedNavigationController = (UINavigationController *)topViewController;
            topViewController = [presentedNavigationController topViewController];
        }
    }
    return topViewController;
}

+ (UIWindow *)eo_export_currentWindow
{
    UIWindow* window = nil;
   
    if (@available(iOS 13.0, *))
    {
      for (UIWindowScene* windowScene in [UIApplication sharedApplication].connectedScenes)
      {
          if (windowScene.activationState == UISceneActivationStateForegroundActive)
          {
              window = windowScene.windows.firstObject;
              break;
          }
      }
    }

    return window ? window : [UIApplication sharedApplication].keyWindow;
}

+ (UIFont *)eo_export_pingFangRegular:(CGFloat)size
{
    return [EOExportUIHelper eo_export_fontWithName:@"PingFangSC-Regular" size:size];
}

+ (UIFont *)eo_export_fontWithName:(NSString *)fontName size:(CGFloat)fontSize
{
    UIFont *font = [UIFont fontWithName:fontName size:fontSize];
    if (!font) {
        font = [UIFont systemFontOfSize:fontSize];
    }
    return font;
}

+ (NSArray *)iphoneDeviceModel {
    return @[@"iPhone5,1",//iPhone 5
             @"iPhone5,2",//iPhone 5
             @"iPhone5,3",//iPhone 5c
             @"iPhone5,4",//iPhone 5c
             @"iPhone6,1",//iPhone 5s
             @"iPhone6,2",//iPhone 5s
             @"iPhone7,2",//iPhone 6
             @"iPhone7,1",//iPhone 6 Plus
             @"iPhone8,1",//iPhone 6s
             @"iPhone8,2",//iPhone 6s Plus
             @"iPhone8,4"//iPhone SE
    ];
}

+ (BOOL)isSupportExport {
    struct utsname systemInfo;
    uname(&systemInfo);

    NSString *deviceModel = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
    if ([[EOExportUIHelper iphoneDeviceModel] containsObject:deviceModel]) {
        return NO;
    }
    else {
        return YES;
    }
}

CGSize EO_export_aspectFitMaxSize(CGSize size, CGSize maxSize) {
    if (maxSize.width <= 0 || maxSize.height <= 0 || size.width <= 0 || size.height <= 0) {
        return CGSizeZero;
    }
    CGFloat wRatio = size.width / maxSize.width;
    CGFloat hRatio = size.height / maxSize.height;
    CGSize resultSize = CGSizeZero;
    if (wRatio >= hRatio) {
        resultSize = CGSizeMake(maxSize.width, maxSize.width * size.height / size.width);
    } else {
        resultSize = CGSizeMake(maxSize.height * size.width / size.height, maxSize.height);
    }
    return resultSize;
}

CGSize EO_export_aspectFitMinSize(CGSize size, CGSize minSize) {
    if (minSize.width <= 0 || minSize.height <= 0 || size.width <= 0 || size.height <= 0) {
        return CGSizeZero;
    }

    CGFloat wRatio = size.width / minSize.width;
    CGFloat hRatio = size.height / minSize.height;
    CGSize resultSize = CGSizeZero;
    if (wRatio <= hRatio) {
        CGFloat compressWidth = minSize.width;
        CGFloat compressHeight = compressWidth * size.height / size.width;
        resultSize = CGSizeMake(compressWidth, compressHeight);
    } else {
        CGFloat compressHeight = minSize.height;
        CGFloat compressWidth = compressHeight * size.width / size.height;
        resultSize = CGSizeMake(compressWidth, compressHeight);
    }
    return resultSize;
}

CGRect EO_export_fixCropRectForImage(CGRect rect, UIImage *image) {
    CGAffineTransform rectTransform;
    switch (image.imageOrientation) {
        case UIImageOrientationLeft:
            rectTransform = CGAffineTransformTranslate(CGAffineTransformMakeRotation(90 / 180.0f * M_PI), 0, -image.size.height);
            break;
        case UIImageOrientationRight:
            rectTransform = CGAffineTransformTranslate(CGAffineTransformMakeRotation(-90 / 180.0f * M_PI), -image.size.width, 0);
            break;
        case UIImageOrientationDown:
            rectTransform = CGAffineTransformTranslate(CGAffineTransformMakeRotation(-180 / 180.0f * M_PI), -image.size.width, -image.size.height);
            break;
        default:
            rectTransform = CGAffineTransformIdentity;
    };

    rectTransform = CGAffineTransformScale(rectTransform, image.scale, image.scale);
    CGRect transformedCropSquare = CGRectApplyAffineTransform(rect, rectTransform);
    return transformedCropSquare;
}

CGSize EO_limitMaxSize(CGSize size ,CGSize maxSize) {
    if (maxSize.width <= 0 || maxSize.height <= 0 || size.width <= 0 || size.height <= 0) {
        return CGSizeZero;
    }
    
    CGFloat sRatio = size.width / size.height;
    CGFloat tRatio = maxSize.width / maxSize.height;
    
    if (sRatio >= tRatio) {
        return CGSizeMake(maxSize.width, maxSize.width / sRatio);
    } else {
        return CGSizeMake(maxSize.height * sRatio, maxSize.height);
    }
}

CGFloat floatInRange(CGFloat value, CGFloat minValue, CGFloat maxValue) {
    value = MIN(maxValue, value);
    value = MAX(minValue, value);
    return value;
}

CGFloat guardNormalized(CGFloat value) {
    return floatInRange(value, 0.0, 1.0);
}

CGPoint guardInZeroToOne(CGPoint point) {
    CGFloat x = guardNormalized(point.x);
    CGFloat y = guardNormalized(point.y);
    return CGPointMake(x, y);
}

NSArray<NSValue *> * EO_export_defaultCropForImage(CGSize imageSize, CGSize canvasSize) {
    CGSize previewSize = imageSize;
    CGSize cropSize = EO_limitMaxSize(canvasSize, previewSize);
    if (previewSize.width > 0 && previewSize.height > 0 && cropSize.width > 0 && cropSize.height > 0) {
        NSMutableArray *result = [NSMutableArray array];
        CGFloat halfCropWidth = cropSize.width * 0.5;
        CGFloat halfPreViewWidth = previewSize.width * 0.5;
        CGFloat halfCropHeight = cropSize.height * 0.5;
        CGFloat halfPreViewHeight = previewSize.height * 0.5;

        CGFloat upperLeftX = (halfPreViewWidth - halfCropWidth);
        CGFloat upperLeftY = (halfPreViewHeight - halfCropHeight);

        CGFloat uppeRightX = (upperLeftX + cropSize.width);
        CGFloat upperRightY = upperLeftY;

        CGFloat lowerLeftX = upperLeftX;
        CGFloat lowerLeftY = (upperLeftY + cropSize.height);

        CGFloat lowerRightX = uppeRightX;
        CGFloat lowerRightY = lowerLeftY;

        CGPoint upperLeftPoint  = CGPointMake(upperLeftX / previewSize.width, upperLeftY / previewSize.height);
        CGPoint upperRightPoint = CGPointMake(uppeRightX / previewSize.width, upperRightY / previewSize.height);
        CGPoint lowerLeftPoint  = CGPointMake(lowerLeftX / previewSize.width, lowerLeftY / previewSize.height);
        CGPoint lowerRightPoint = CGPointMake(lowerRightX / previewSize.width, lowerRightY / previewSize.height);

        [result addObject:@(guardInZeroToOne(upperLeftPoint))];
        [result addObject:@(guardInZeroToOne(upperRightPoint))];
        [result addObject:@(guardInZeroToOne(lowerLeftPoint))];
        [result addObject:@(guardInZeroToOne(lowerRightPoint))];
        return [result copy];
    }

    return @[@(CGPointMake(0, 0)),
             @(CGPointMake(1, 0)),
             @(CGPointMake(0, 1)),
             @(CGPointMake(1, 1))];
}

+ (UIWindow *)eo_currentWindow
{
    UIWindow* window = nil;
   
    if (@available(iOS 13.0, *))
    {
      for (UIWindowScene* windowScene in [UIApplication sharedApplication].connectedScenes)
      {
          if (windowScene.activationState == UISceneActivationStateForegroundActive)
          {
              window = windowScene.windows.firstObject;
              break;
          }
      }
    }

    return window ? window : [UIApplication sharedApplication].keyWindow;
}

+ (UIColor *)eo_colorWithHex:(NSString *)hexString
{
    return [self eo_colorWithHex:hexString alpha:1.0];
}

+ (UIColor *)eo_colorWithHex:(NSString *)hexString alpha:(CGFloat)alpha
{
    CGFloat red = 0.0;
    CGFloat green = 0.0;
    CGFloat blue = 0.0;
    CGFloat mAlpha = alpha;
    NSInteger minusLength = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];

    if ([hexString hasPrefix:@"#"]) {
        scanner.scanLocation = 1;
        minusLength = 1;
    }
    if ([hexString hasPrefix:@"0x"]) {
        scanner.scanLocation = 2;
        minusLength = 2;
    }
    unsigned int hexValue = 0;
    [scanner scanHexInt:&hexValue];
    switch (hexString.length - minusLength) {
        case 3:
            mAlpha = 1.0;
            red = ((hexValue & 0xF00) >> 8) / 15.0;
            green = ((hexValue & 0x0F0) >> 4) / 15.0;
            blue = (hexValue & 0x00F) / 15.0;
            break;
        case 4:
            red = ((hexValue & 0xF000) >> 12) / 15.0;
            green = ((hexValue & 0x0F00) >> 8) / 15.0;
            blue = ((hexValue & 0x00F0) >> 4) / 15.0;
            mAlpha = (hexValue & 0x00F) / 15.0;
            break;
        case 6:
            red = ((hexValue & 0xFF0000) >> 16) / 255.0;
            green = ((hexValue & 0x00FF00) >> 8) / 255.0;
            blue = (hexValue & 0x0000FF) / 255.0;
            break;
        case 8:
            red = ((hexValue & 0xFF000000) >> 24) / 255.0;
            green = ((hexValue & 0x00FF0000) >> 16) / 255.0;
            blue = ((hexValue & 0x0000FF00) >> 8) / 255.0;
            mAlpha = (hexValue & 0x000000FF) / 255.0;
            break;
        default:
            NSAssert(NO, @"Color Hex String Format Error");
            break;
    }

    return [UIColor colorWithRed:red green:green blue:blue alpha:mAlpha];
}

@end
