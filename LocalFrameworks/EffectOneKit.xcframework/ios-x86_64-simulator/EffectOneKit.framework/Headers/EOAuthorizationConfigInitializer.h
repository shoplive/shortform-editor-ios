
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface EOAuthorizationConfigInitializer : NSObject

@property (nonatomic, assign) BOOL isOnline;
@property (nonatomic, assign) BOOL isOversea;
@property (nonatomic, strong) NSString *licensePathForOffline;
@property (nonatomic, strong) NSString *licenseTokenForOnline;
@property (nonatomic, strong) NSMutableArray *licenseFunctions;

@end

NS_ASSUME_NONNULL_END
