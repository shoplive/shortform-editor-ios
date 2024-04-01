#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface EORemoteAddrConfig : NSObject

// remote config domain
@property (nonatomic, copy) NSString *configDomain;

// remote config path
@property (nonatomic, copy) NSString *configPath;

// resource download domain
@property (nonatomic, copy) NSString *resourceDownloadDomain;

// resource download path
@property (nonatomic, copy) NSString *resourceDownloadPath;

// model download domain
@property (nonatomic, copy) NSString *modelDownloadDomain;

// model download path
@property (nonatomic, copy) NSString *modelDownloadPath;

// request headers
@property (nonatomic, strong) NSDictionary *headers;

// remote icon prefix
@property (nonatomic, copy) NSString *iconUrlPrefix;

- (instancetype)initWithConfigDomain:(NSString *)configDomain
                          configPath:(NSString *)configPath
                      resourceDomain:(NSString *)resourceDomain
                        resourcePath:(NSString *)resourcePath
                         modelDomain:(NSString *)modelDomain
                           modelPath:(NSString *)modelPath;

@end

NS_ASSUME_NONNULL_END
