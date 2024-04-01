//
//  EOExportUIHelper.h
//  EOExportUI
//
//

#import <UIKit/UIKit.h>
#import "EOExport.h"

#define EOExportTopMargnValue 28.0
#define EOExportBottomMargnValue 34.0

FOUNDATION_EXTERN CGSize EO_export_aspectFitMaxSize(CGSize size, CGSize maxSize);
FOUNDATION_EXTERN CGSize EO_export_aspectFitMinSize(CGSize size, CGSize minSize);
FOUNDATION_EXTERN CGRect EO_export_fixCropRectForImage(CGRect rect, UIImage * _Nullable image);
FOUNDATION_EXTERN NSArray<NSValue *> * _Nullable EO_export_defaultCropForImage(CGSize imageSize, CGSize canvasSize);

NS_ASSUME_NONNULL_BEGIN

@interface EOExportUIHelper : NSObject

+(CGFloat)EO_topBarMargn;

+(CGFloat)EO_topBarMargn:(UINavigationController*)nav ;

+ (UIEdgeInsets)EO_safeAreaInsets;

+ (CAShapeLayer *)EO_topRoundCornerShapeLayerWithFrame:(CGRect)frame
                                             radius:(CGFloat)radius;

+ (UIFont *)eo_export_pingFangRegular:(CGFloat)size;

+ (UIWindow *)eo_currentWindow;

+ (UIColor *)eo_colorWithHex:(NSString *)hexString;

+ (UIColor *)eo_colorWithHex:(NSString *)hexString alpha:(CGFloat)alpha;

+ (BOOL)isSupportExport;

@end

NS_ASSUME_NONNULL_END

FOUNDATION_EXTERN CGFloat EO_ScreenWidth(void);

FOUNDATION_EXTERN CGFloat EO_ScreenHeight(void);

//  {zh} 刘海屏判断  {en} Notch screen judgment
FOUNDATION_STATIC_INLINE BOOL EO_IsIphoneXseries(void) {
    BOOL isIPhoneX = NO;
    if (@available(iOS 11.0, *)) {
        isIPhoneX = [EOExportUIHelper EO_safeAreaInsets].bottom > 0.0;
    }
    return isIPhoneX;
}

FOUNDATION_STATIC_INLINE CGFloat EO_SingleLineWidth(void) {
    return 1 / [UIScreen mainScreen].scale;
}

FOUNDATION_STATIC_INLINE CGFloat EO_BottomMargn(void) {
    UIUserInterfaceIdiom userInterfaceIdiom = UIDevice.currentDevice.userInterfaceIdiom;
    return EO_IsIphoneXseries() ? (userInterfaceIdiom == UIUserInterfaceIdiomPad ? 20 : 34) : 0;
}

FOUNDATION_STATIC_INLINE CGFloat EO_TopBarMargn(void) {
    return [EOExportUIHelper EO_topBarMargn];
}

/**  {zh} 导航栏高度  *  {en} Navigation bar height */
FOUNDATION_STATIC_INLINE CGFloat EO_NavBarHeight(void) {
    return EO_IsIphoneXseries() ? 88 : 64;
}

/**  {zh} 标签栏高度  *  {en} Tab Bar Height */
FOUNDATION_STATIC_INLINE CGFloat EO_TabBarHeight(void) {
    return EO_IsIphoneXseries() ? 83 : 49;
}

/**  {zh} 底部横条高度  *  {en} Bottom bar height */
FOUNDATION_STATIC_INLINE CGFloat EO_HomeIndicatorHeight(void) {
    return EO_IsIphoneXseries() ? 34 : 0;
}


/// Get status bar's height
///
/// You should call it at active state, otherwise it will return 0.
FOUNDATION_STATIC_INLINE CGFloat EO_StatusBarHeight(void) {
    BOOL isStatusBarHidden = NO;
    CGRect statusBarFrame;
    if (@available(iOS 13.0, *)) {
        for (UIWindowScene* windowScene in [UIApplication sharedApplication].connectedScenes) {
            if (windowScene.activationState == UISceneActivationStateForegroundActive)
            {
                UIStatusBarManager *mgr = windowScene.statusBarManager;
                isStatusBarHidden = mgr.isStatusBarHidden;
                statusBarFrame = mgr.statusBarFrame;
                break;
            }
        }
    } else {
        isStatusBarHidden = UIApplication.sharedApplication.isStatusBarHidden;
        statusBarFrame = UIApplication.sharedApplication.statusBarFrame;
    }
    return !isStatusBarHidden ? statusBarFrame.size.height : (EO_IsIphoneXseries() ? 44.f : 20.f);
}
