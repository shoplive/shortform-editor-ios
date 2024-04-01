//
//  EOImageCacheProtocol.h
//  EOBaseKit_Core
//
//    2024/1/26.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol EOImageCacheProtocol <NSObject>

- (UIImage * _Nullable)imageForKey:(NSString * _Nullable)key;

- (BOOL)containsImageForKey:(NSString * _Nullable)key;

- (void)setImage:(UIImage * _Nullable)image forKey:(NSString * _Nullable)key;

@end

NS_ASSUME_NONNULL_END
