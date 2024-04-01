//
//  EOVideoCoverVideoFramePickerView.h
//  EOEasyEditorUI
//
//

#import <UIKit/UIKit.h>


NS_ASSUME_NONNULL_BEGIN

@interface EOVideoCoverVideoFramePickerItem : UICollectionViewCell

@property (nonatomic, strong) UIImageView *imageView;

@end

@protocol EOVideoCoverVideoFramePickerViewDelegate <NSObject>

- (void)updatePreviewCurrentTimeWithRatio:(CGFloat)ratio;

@end

@interface EOVideoCoverVideoFramePickerView : UIView

@property (nonatomic, weak) id<EOVideoCoverVideoFramePickerViewDelegate> delegate;

- (void)updateVideoFrames:(NSArray<UIImage *> *)frames durationRatios:(NSArray<NSNumber *> *)durationRatios;

- (void)setVideoSliderValue:(CGFloat)value;

@end


NS_ASSUME_NONNULL_END
