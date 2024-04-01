#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@protocol EONetworkCoreProtocol;
@protocol EOResourceLoaderProtocol;
@protocol EOUnzipProtocol;
@protocol EOWebImageProtocol;
@protocol EOResourcePickerProtocol;
@protocol EOImageCacheProtocol;

@interface EOInjectContainer : NSObject

@property(nonatomic, strong, nullable) id<EONetworkCoreProtocol> networkSharedImpl;
@property(nonatomic, strong, nullable) id<EOResourceLoaderProtocol> resourceLoaderSharedImpl;
@property(nonatomic, strong, nullable) id<EOUnzipProtocol> unzipSharedImpl;
@property(nonatomic, strong, nullable) id<EOWebImageProtocol> webImageSharedImpl;
@property(nonatomic, strong, nullable) id<EOResourcePickerProtocol> resourcePickerSharedImpl;
@property(nonatomic, strong, nullable) id<EOImageCacheProtocol> imageCacheImpl;

+ (instancetype)shared;

@end

NS_ASSUME_NONNULL_END
