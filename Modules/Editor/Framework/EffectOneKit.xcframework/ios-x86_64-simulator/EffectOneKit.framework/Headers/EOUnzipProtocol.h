#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol EOUnzipProtocol <NSObject>

- (BOOL) unzipFile:(NSString *)zipFile toDestFolder:(NSString *)folder;

@end

NS_ASSUME_NONNULL_END
