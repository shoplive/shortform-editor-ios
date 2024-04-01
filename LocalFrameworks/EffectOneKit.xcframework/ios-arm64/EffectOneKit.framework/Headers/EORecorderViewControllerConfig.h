//
//  EORecorderViewControllerConfig.h
//  EOEasyRecorderUI
//
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class EORecorderSideBarConfig;
@class EORecorderViewControllerConfigInitializer;

@interface EORecorderViewControllerConfig : NSObject

@property (nonatomic, strong, readonly) EORecorderSideBarConfig *sideBarConfig;

- (instancetype)initWithInitializer:(EORecorderViewControllerConfigInitializer *)initializer;

@end

@interface EORecorderViewControllerConfigInitializer : NSObject

/// Right side bar config.
@property (nonatomic, strong) EORecorderSideBarConfig *sideBarConfig;

@end

#pragma mark - EORecorderSideBarConfig

typedef NSString * const EORecordSideBarItemKey NS_STRING_ENUM;

FOUNDATION_EXPORT EORecordSideBarItemKey EORecordBarItemRotateCameraKey;
FOUNDATION_EXPORT EORecordSideBarItemKey EORecordBarItemFlashKey;
FOUNDATION_EXPORT EORecordSideBarItemKey EORecordBarItemTimerKey;
FOUNDATION_EXPORT EORecordSideBarItemKey EORecordBarItemFiltersKey;
FOUNDATION_EXPORT EORecordSideBarItemKey EORecordBarItemBeautyKey;
FOUNDATION_EXPORT EORecordSideBarItemKey EORecordBarItemSpeedKey;

@interface EORecorderSideBarConfig : NSObject

/// Array of keys that presenting right side bar items.
/// Could change the order. Custom new items not supported yet.
/// default order: [
///     EORecordBarItemRotateCameraKey,
///     EORecordBarItemFlashKey,
///     EORecordBarItemTimerKey,
///     EORecordBarItemFiltersKey,
///     EORecordBarItemBeautyKey,
///     EORecordBarItemSpeedKey,
/// ]
@property (nonatomic, strong) NSMutableArray<EORecordSideBarItemKey> *itemKeys;

/// The number of side bar items that would not be folded,
/// count from the first object of `itemKeys`
/// default is `5`
@property (nonatomic, assign) NSUInteger unfoldCount;

@end

NS_ASSUME_NONNULL_END
