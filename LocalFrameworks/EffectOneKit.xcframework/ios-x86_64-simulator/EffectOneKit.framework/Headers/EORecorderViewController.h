//
//  EORecorderViewController.h
//  EOEasyRecorderUI
//
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXPORT NSString * const EORecorderViewControllerErrorDomain;

typedef NS_ENUM(NSInteger, EORecorderViewControllerError) {
    EORecorderViewControllerErrorUnknown = 201,
    EORecorderViewControllerErrorCreationUnAuth = 202,
    EORecorderViewControllerErrorCameraUnAuth = 203,
    EORecorderViewControllerErrorMicrophoneUnAuth = 204,
    EORecorderViewControllerErrorNoPresenter = 205,
};

@class EORecorderViewController;
@class EORecorderConfig;
@class EORecordInfo;

@protocol EORecorderViewControllerDelegate <NSObject>

@optional
- (void)recorderViewController:(EORecorderViewController *)recorderViewController didFinishRecordingMediaWithInfo:(EORecordInfo *)info;
- (void)recorderViewControllerDidCancel:(EORecorderViewController *)recorderViewController;
- (void)recorderViewControllerDidTapAlbum:(EORecorderViewController *)recorderViewController;

@end

@interface EORecorderViewController : UIViewController

@property (nonatomic, weak) id<EORecorderViewControllerDelegate> delegate;

- (nullable instancetype)initWithConfig:(EORecorderConfig *)config error:(NSError * _Nullable __autoreleasing * _Nullable)error;

- (instancetype)initWithNibName:(NSString * _Nullable)nibNameOrNil bundle:(NSBundle * _Nullable)nibBundleOrNil NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

+ (void)requestMediaAuthWithCompletion:(void (^)(BOOL granted))completion;

+ (void)startRecorderWithConfig:(EORecorderConfig *)config
                     completion:(void (^)(NSError * _Nullable error))completion;

+ (void)startRecorderWithConfig:(EORecorderConfig *)config
                      presenter:(UIViewController *)presenter
                       delegate:(id<EORecorderViewControllerDelegate> _Nullable)delegate
                     completion:(void (^)(NSError * _Nullable error))completion;

@end

NS_ASSUME_NONNULL_END
