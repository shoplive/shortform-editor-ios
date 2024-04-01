//
//  EOExportEditorViewController.h
//  EOEasyEditorUI
//
//

#import <UIKit/UIKit.h>

#if __has_include(<EOEasyEditorUI/EOExportManager.h>)
#import <EOEasyEditorUI/EOExportManager.h>
#else
#import <EffectOneKit/EOExportManager.h>
#endif

NS_ASSUME_NONNULL_BEGIN

@protocol EOExportEditorViewControllerDelegate <NSObject>

@optional
- (void)getPickSingleImageResourceWithCompletion:(nullable void(^)(NSURL * _Nullable pickImage, NSError * _Nullable error, BOOL cancel))completionBlock;

@end

@interface EOExportEditorViewController : UIViewController

@property (nonatomic, copy) void (^onDismiss)(UIImage * _Nullable videoFrameImage, int64_t videoFrameTime, BOOL isCoverImage);
@property (nonatomic, weak) id<EOExportEditorViewControllerDelegate> delegate;
@property (nonatomic, assign) int64_t videoFrameTime;
@property (nonatomic, strong) UIImage *coverImage;
@property (nonatomic, assign) BOOL isCoverImage;
@property (nonatomic, strong) EOExportManager *manager;

@end

NS_ASSUME_NONNULL_END
