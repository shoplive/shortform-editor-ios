#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol EOResourceProtocol;

@protocol EOResourceLoaderProtocol <NSObject>
@required

/// load config json by panel key
/// - Parameters:
///   - panelKey: panel key
///   - localOnly: only builtin config will be used if YES is set
///   - completion: completion block, result is legal only if error != nil
- (void) loadConfigByPanelKey:(NSString *)panelKey
                    localOnly:(BOOL)localOnly
                   completion:(nullable void (^)(NSString *panelKey, NSArray<id<EOResourceProtocol>> * _Nullable, NSError * _Nullable))completion;

/// download resource by EOResourceItem
/// - Parameters:
///   - item: resource item
///   - progress: progress callback block
///   - completion: completion block, result is legal only if error != nil
- (void) loadResourceByItem:(id<EOResourceProtocol>)resource
                   progress:(nullable void (^)(id<EOResourceProtocol> _Nullable resource, CGFloat progress))progress
                 completion:(nullable void (^)(id<EOResourceProtocol> _Nullable resource, NSError * _Nullable error))completion;

/// download resource by EOResourceItem Array
/// - Parameters:
///   - items: resource item array
///   - progress: progress callback block
///   - completion: completion block, result is legal only if error != nil
- (void) loadResourceByItemArray:(NSArray<id<EOResourceProtocol>> *)resourceArray
                        progress:(nullable void (^)(NSArray<id<EOResourceProtocol>> * _Nullable resourceArray, CGFloat progress))progress
                      completion:(nullable void (^)(NSArray<id<EOResourceProtocol>> * _Nullable resourceArray, NSError * _Nullable error))completion;

- (BOOL) resouceLoaded:(id<EOResourceProtocol>)resource;

/// cancel all tasks haven't started
- (void) cancel;

@end

NS_ASSUME_NONNULL_END
