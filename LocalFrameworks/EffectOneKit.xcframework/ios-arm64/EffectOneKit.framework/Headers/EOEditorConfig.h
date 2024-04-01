//
//  EOUIConfig.h
//  Pods
//
//    2023/10/23.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class EOVideoEditorViewControllerConfig;
@class EOEditorConfigInitializer;

@interface EOEditorConfig : NSObject

@property (nonatomic, strong, readonly) EOVideoEditorViewControllerConfig *videoEditorConfig;

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithBlock:(void (^)(EOEditorConfigInitializer *))block NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
