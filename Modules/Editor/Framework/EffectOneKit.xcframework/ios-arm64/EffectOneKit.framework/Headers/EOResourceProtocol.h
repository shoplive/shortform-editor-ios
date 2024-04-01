#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@class EOCommonResourceParam;
@class EOBeautyResourceParam;
@class EOMusicResourceParam;
@class EOFilterResourceParam;
@class EOTransitionResourceParam;
@protocol EOResourceProtocol;

@protocol EOResourceProtocol <NSObject>
- (NSString *)uniqueId;
- (NSString *)absPath;
- (NSString *)title;
- (NSString *)subTitle;
- (NSString *)tips;
- (NSString *)icon;
- (NSString *)builtInIcon;
- (BOOL)defaultOn;
- (NSArray<id<EOResourceProtocol>> *)subItems;

- (EOCommonResourceParam *)commonParam;
- (EOBeautyResourceParam *)beautyParam;
- (EOMusicResourceParam *)musicParam;
- (EOFilterResourceParam *)filterParam;
- (EOTransitionResourceParam *)transitionParam;

@end

NS_ASSUME_NONNULL_END
