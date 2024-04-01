#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
typedef NS_ENUM(NSInteger, EOLicenseFuncType) {
    EO_EFFECT = 0,
    EO_AUDIO_BUILDIN_EFFECT = 100000,
    EO_AUDIO_ONEPOINT_EFFECT,
    EO_AUDIO_OFFLINE_TIMESCALER,    
};

typedef void (^EOAuthCompletionHandler)(BOOL success, NSString* errMsg);
@class EOAuthorizationConfig;

@interface EOAuthorization : NSObject

+ (instancetype)sharedInstance;
-(void)makeAuthWithConfig:(EOAuthorizationConfig*)config completionHandler:(EOAuthCompletionHandler)completionHandler;

@end

NS_ASSUME_NONNULL_END
