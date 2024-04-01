//
//  EORecorderConfig.h
//  EOEasyRecorderUI
//
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, EORecorderVideoResolution) {
    EORecorderVideoResolution540p = 0,
    EORecorderVideoResolution720p = 1,
    EORecorderVideoResolution1080p = 2,
    EORecorderVideoResolution4k = 3,
};

@class EORecorderConfigInitializer;
@class EORecorderViewControllerConfig;
@class EORecorderViewControllerConfigInitializer;

@interface EORecorderConfig : NSObject

@property (nonatomic, copy, readonly) NSString *modelPath;

@property (nonatomic, assign, readonly) AVCaptureDevicePosition cameraPosition;

@property (nonatomic, assign, readonly) EORecorderVideoResolution videoResolution;

@property (nonatomic, strong, readonly) EORecorderViewControllerConfig *recorderViewControllerConfig;

- (instancetype)initWithBlock:(void (^)(EORecorderConfigInitializer *))block;

@end

@interface EORecorderConfigInitializer : NSObject

/// default is `EOBaseKit.modelResourceDir`
@property (nonatomic, copy) NSString *modelPath;

/// default is `AVCaptureDevicePositionFront`
@property (nonatomic, assign) AVCaptureDevicePosition cameraPosition;

/// default is `EORecorderVideoResolution1080p` for front camera supported,
/// otherwise `EORecorderVideoResolution720p`.
/// which means iPhone newer than iPhone 7 (included) use 1080p.
@property (nonatomic, assign) EORecorderVideoResolution videoResolution;

- (void)configRecorderViewController:(void (^ _Nonnull)(EORecorderViewControllerConfigInitializer * _Nonnull))block;

@end

NS_ASSUME_NONNULL_END
