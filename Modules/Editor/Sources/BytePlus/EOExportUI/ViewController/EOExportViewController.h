//
//  EOExportViewController.h
//  EOEasyEditorUI
//
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@class EOExportModel;
@protocol EOExportViewControllerDelegate <NSObject>

@optional
- (void)exportVideoPath:(NSString *)videoPath videoImage:(UIImage *)videoImg;
- (void)getPickSingleImageResourceWithCompletion:(nullable void(^)(NSURL * _Nullable pickImage, NSError * _Nullable error, BOOL cancel))completionBlock;

@end

@interface EOExportViewController : UIViewController

+ (void)startExportWithExportModel:(EOExportModel *)exportModel presentVC:(UIViewController *)viewController;
+ (void)startExportWithExportModel:(EOExportModel *)exportModel
                        presentVC:(UIViewController *)viewController
                        delegate:(id<EOExportViewControllerDelegate> _Nullable)delegate;

@property (nonatomic, weak) id<EOExportViewControllerDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
