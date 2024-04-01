//
//  EOVideoEditorViewController.h
//  Pods
//
//    2023/10/23.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXPORT NSString * const EOEditorViewControllerErrorDomain;

typedef NS_ENUM(NSInteger, EOEditorViewControllerError) {
    EOEditorViewControllerErrorUnknown = 501,
    EOEditorViewControllerErrorCreationUnAuth = 502,
    EOEditorViewControllerErrorNoPresenter = 503,
};

@class EOEditorConfig;
@class EOEditorSceneConfig;
@class EOEditResult;
@class EOVideoEditorViewController;
@class EOExportModel;

@protocol EOVideoEditorViewControllerDelegate <NSObject>

@optional
- (void)videoEditorViewControllerDidCancel:(EOVideoEditorViewController *)videoEditorViewController;
- (void)videoEditorViewController:(EOVideoEditorViewController *)editorViewController didFinishEditingMediaWithResult:(EOEditResult *)result;
- (void)videoEditorViewControllerTapNext:(EOExportModel *)exportModel presentVC:(UIViewController *)viewController;
@end

@interface EOVideoEditorViewController : UIViewController

@property (nonatomic, weak) id<EOVideoEditorViewControllerDelegate> delegate;

+ (void)startEditorWithConfig:(EOEditorConfig *)config
                  sceneConfig:(EOEditorSceneConfig *)sceneConfig
                    presenter:(UIViewController *)presenter
                     delegate:(id<EOVideoEditorViewControllerDelegate> _Nullable)delegate
                   completion:(void (^)(NSError * _Nullable error))completion;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
