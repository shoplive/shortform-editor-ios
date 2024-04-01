//
//  EODraftBoxController.h
//  EOEasyEditorUI-EOEasyEditorUI
//
//    2023/12/7.
//

#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN

@protocol EOVideoEditorViewControllerDelegate;
@interface EODraftBoxController : UIViewController

//delegate 设置代理，用于预览编辑页的下一步回调
+ (void)presentDraftVCDelegate:(id<EOVideoEditorViewControllerDelegate>)delegate;

//delegate 设置代理，用于预览编辑页的下一步回调
//presentVC 基于该控制器进行present,presentVC需要为置顶VC
+ (void)presentDraftVCDelegate:(id<EOVideoEditorViewControllerDelegate>)delegate presentVC:(UIViewController *)presentVC;

@end

NS_ASSUME_NONNULL_END
