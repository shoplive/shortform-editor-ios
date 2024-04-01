#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class EORemoteAddrConfig;

@interface EOSDK : NSObject

+(void)setLocalizationDictionary:(NSDictionary*)dict;
+(void)setIconDictionary:(NSDictionary*)dict;

/// example:
/// {
///     "Primary" : {
///         "dark" : "FF0ECDEB", //ARGB
///         "light" : "FF0ECDEB"
///     },
///     "Secondary" : {
///         "dark" : "FF0ECDEB",
///         "light" : "FF0ECDEB"
///     }
/// }
+(void)setColorDictionary:(NSDictionary<NSString *, NSDictionary<NSString *, NSString *> *> *)dict;

/// return eo documents path by appending "effectone" to document path
+(NSString*)getEODocumentRootDir;

/// set token for para platform
+(void)setResourceToken:(NSString *)token;

/// resource base dir, to which remote resource will be downloaded
/// - Parameter dir: base dir
+(void)setResourceBaseDir:(NSString*)dir;

/// builit in resource base dir, where built in resources locate
/// - Parameter dir: base dir
+(void)setBuiltInResourceDir:(NSString*)dir;

/// set remote config & download domain & path
/// - Parameter remoteAddrConfig: remote addr config
+(void)setRemoteAddrConfig:(EORemoteAddrConfig *)remoteAddrConfig;

/// set builtin config json
/// - Parameter builtInDict: config dictionary
/// key: EO panel key, eg. EOPanelKeyPreEditor_Music
/// value: json file path
+(void)setBuiltInConfigFileDictionary:(NSDictionary *)builtInDict;

/// set wether use remote resource
/// - Parameters:
///   - remoteConfig: use remote config file, request will be published if set YES
///   - remoteResource: use remote resource, request will be published if set YES
+(void)useRemoteConfig:(BOOL)remoteConfig useRemoteResource:(BOOL)remoteResource;

/// set default builtin config files
/// - Parameter baseDir: base dir for config files
+(void)setResourceDefaultBuiltInConfig:(NSString *)baseDir;

/// init sdk and set default config
/// - Parameter dataBlock: completion block
+ (void)initSDK:(nullable void(^)(void))dataBlock;

/// clear resource base dir
+ (void)clearResource;

/// return default resource dir, append "EffectResource" to bundlePath
+ (NSString *)defaultResourceDir:(NSString *)parentDir;

/// return default License dir, append "License" to bundlePath
+ (NSString *)defaultLicenseDir:(NSString *)parentDir;

/// return default panel config dir, append "EffectResource/Panel_configs" to bundlePath
+ (NSString *)defaultPanelConfigDir:(NSString *)parentDir;

/// once called, config file fetched last time will be used
+ (void)enableConfigPreload;

@end

NS_ASSUME_NONNULL_END
