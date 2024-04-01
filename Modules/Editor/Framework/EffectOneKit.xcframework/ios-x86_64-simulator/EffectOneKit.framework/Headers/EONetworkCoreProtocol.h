#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol EONetworkCoreProtocol <NSObject>

@required
- (void)GET:(NSString *)URLString
 parameters:(nullable id)parameters
    headers:(nullable NSDictionary <NSString *, NSString *> *)headers
    success:(nullable void (^)(NSData * _Nullable response))success
    failure:(nullable void (^)(NSError * _Nonnull error))failure;

- (void)downloadWithRequest:(NSURLRequest *)request
                   progress:(void (^)(NSProgress *downloadProgress)) downloadProgressBlock
                destination:(NSURL * (^)(NSURL *targetPath, NSURLResponse *response))destination
          completionHandler:(void (^)(NSURLResponse *response, NSURL *  _Nullable filePath, NSError *  _Nullable error))completionHandler;

- (void)dataWithRequest:(NSURLRequest *)request
      completionHandler:(nullable void (^)(NSURLResponse *response, id _Nullable responseObject, NSError * _Nullable error))completionHandler;

@end

NS_ASSUME_NONNULL_END
