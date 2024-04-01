//
//  EOExportUIBundle.h
//  EOExportUI-EOExportUI
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface EOExportUIBundle : NSObject
+ (NSBundle *)resourceBundle;
+ (UIImage *)resourceBundleImage:(NSString *)img;
@end

NS_ASSUME_NONNULL_END
