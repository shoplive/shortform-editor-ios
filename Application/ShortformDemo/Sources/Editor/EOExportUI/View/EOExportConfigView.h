//
//  EOExportConfigView.h
//  EOEasyEditorUI
//
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol EOExportConfigViewDelegate <NSObject>

- (void)didSelectSaveResolution:(NSInteger)resolutionIndex FPS:(NSInteger)fpsIndex;

- (void)didClickEmptyAreaInExportConfigView;

@end

@interface EOExportConfigView : UIView

@property (nonatomic, weak) id<EOExportConfigViewDelegate> delegate;

- (instancetype)initWithFrame:(CGRect)frame
                       fpsArr:(NSArray<NSString *>*)fpsArr
                   presentArr:(NSArray<NSString *> *)resolutionArr
                       fpsDefaultIndex:(NSInteger)fpsIndex
       resolutionDefaultIndex:(NSInteger)resolutionIndex;

/// {zh} 导出配置页面显示在父View中 {en} Export configuration page displayed in parent View
/// @param parentView {zh} 父View {en} parentView
- (void)showInView:(UIView *)parentView;

/// {zh}  导出配置页面隐藏 {en} Export configuration page hide
- (void)dismiss;

@end

NS_ASSUME_NONNULL_END
