//
//  EOVideoCoverResourcePickerView.h
//  EOEasyEditorUI
//
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, EOVideoCoverResourceType) {
    EOVideoCoverResourceTypeVideoFrame,
    EOVideoCoverResourceTypeAlbumImage,
};

@protocol EOVideoCoverResourcePickerDelegate <NSObject>

- (void)updatePreviewCurrentTimeWithRatio:(CGFloat)ratio;

- (void)switchPreviewOrPickAlbumImage:(BOOL)isSwitch isReselect:(BOOL)reselect;

@end

@interface EOVideoCoverResourcePickerView : UIView

@property (nonatomic, weak) id<EOVideoCoverResourcePickerDelegate> delegate;
@property (nonatomic, assign) BOOL isSelectPickAlbumImage;

- (void)updateVideoFrames:(NSArray<UIImage *> *)frames durationRatios:(NSArray<NSNumber *> *)durationRatioArr;

- (void)setVideoSliderValue:(CGFloat)value;

@end

NS_ASSUME_NONNULL_END
