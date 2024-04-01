#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@class EOAuthorizationConfigInitializer;

@interface EOAuthorizationConfig : NSObject
@property (nonatomic, assign, readonly) BOOL isOnline;
@property (nonatomic, assign, readonly) BOOL isOversea;
@property (nonatomic, strong, readonly) NSString *licensePathForOffline;
@property (nonatomic, strong, readonly) NSString *licenseTokenForOnline;
@property (nonatomic, strong, readonly) NSMutableArray *licenseFunctions;

- (instancetype)initWithBlock:(void (^)(EOAuthorizationConfigInitializer *))block;
@end

NS_ASSUME_NONNULL_END
