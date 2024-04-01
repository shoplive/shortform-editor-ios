//
//  EOVideoCoverResourcePickerView.m
//  EOEasyEditorUI
//
//

#import "EOVideoCoverResourcePickerView.h"
#import "EOVideoCoverVideoFramePickerView.h"
#import "EOExportUIHelper.h"


@interface  EOVideoCoverResourcePickerView () <EOVideoCoverVideoFramePickerViewDelegate>

@property (nonatomic, strong) EOVideoCoverVideoFramePickerView *framePickerView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIView *segmentView;
@property (nonatomic, strong) UIButton *videoFrameBtn;
@property (nonatomic, strong) UIButton *importBtn;
@property (nonatomic, strong) UIView *selectView;
@property (nonatomic, strong) UIButton *reselectBtn;

@end


@implementation EOVideoCoverResourcePickerView

- (void)willMoveToSuperview:(UIView *)newSuperview {
    if (!newSuperview) {
        return;
    }
    self.backgroundColor = [UIColor clearColor];
    [self addSubview:self.titleLabel];
    [self addSubview:self.reselectBtn];
    [self addSubview:self.framePickerView];
    [self addSubview:self.segmentView];
    [self addSubview:self.selectView];
    [self addSubview:self.videoFrameBtn];
    [self addSubview:self.importBtn];
    
    self.framePickerView.userInteractionEnabled = YES;
    self.segmentView.userInteractionEnabled = YES;

    self.titleLabel.translatesAutoresizingMaskIntoConstraints = false;
    [self.titleLabel.leftAnchor constraintEqualToAnchor:self.leftAnchor constant:16].active = YES;
    [self.titleLabel.topAnchor constraintEqualToAnchor:self.topAnchor constant:20].active = YES;
    [self.titleLabel.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:-16].active = YES;
    [self.titleLabel.heightAnchor constraintEqualToConstant:20].active = YES;
    
    self.reselectBtn.translatesAutoresizingMaskIntoConstraints = false;
    [self.reselectBtn.centerXAnchor constraintEqualToAnchor:self.centerXAnchor].active = YES;
    [self.reselectBtn.topAnchor constraintEqualToAnchor:self.topAnchor constant:6].active = YES;
    [self.reselectBtn.widthAnchor constraintEqualToConstant:120].active = YES;
    [self.reselectBtn.heightAnchor constraintEqualToConstant:54].active = YES;

    self.framePickerView.translatesAutoresizingMaskIntoConstraints = false;
    [self.framePickerView.widthAnchor constraintEqualToAnchor:self.widthAnchor].active = YES;
    [self.framePickerView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor].active = YES;
    [self.framePickerView.topAnchor constraintEqualToAnchor:self.titleLabel.bottomAnchor constant:12].active = YES;
    [self.framePickerView.leftAnchor constraintEqualToAnchor:self.leftAnchor].active = YES;

    self.segmentView.translatesAutoresizingMaskIntoConstraints = false;
    [self.segmentView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor constant:-EO_HomeIndicatorHeight() - 4].active = YES;
    [self.segmentView.leftAnchor constraintEqualToAnchor:self.leftAnchor constant:25].active = YES;
    [self.segmentView.rightAnchor constraintEqualToAnchor:self.rightAnchor constant:-25].active = YES;
    [self.segmentView.heightAnchor constraintEqualToConstant:44].active = YES;

    self.videoFrameBtn.translatesAutoresizingMaskIntoConstraints = false;
    [self.videoFrameBtn.leftAnchor constraintEqualToAnchor:self.segmentView.leftAnchor].active = YES;
    [self.videoFrameBtn.topAnchor constraintEqualToAnchor:self.segmentView.topAnchor].active = YES;
    [self.videoFrameBtn.bottomAnchor constraintEqualToAnchor:self.segmentView.bottomAnchor].active = YES;
    [self.videoFrameBtn.widthAnchor constraintEqualToAnchor:self.segmentView.widthAnchor multiplier:0.5].active = YES;

    self.importBtn.translatesAutoresizingMaskIntoConstraints = false;
    [self.importBtn.rightAnchor constraintEqualToAnchor:self.segmentView.rightAnchor].active = YES;
    [self.importBtn.topAnchor constraintEqualToAnchor:self.segmentView.topAnchor].active = YES;
    [self.importBtn.bottomAnchor constraintEqualToAnchor:self.segmentView.bottomAnchor].active = YES;
    [self.importBtn.widthAnchor constraintEqualToAnchor:self.segmentView.widthAnchor multiplier:0.5].active = YES;

    self.selectView.translatesAutoresizingMaskIntoConstraints = false;
    [self.selectView.leftAnchor constraintEqualToAnchor:self.segmentView.leftAnchor].active = YES;
    [self.selectView.topAnchor constraintEqualToAnchor:self.segmentView.topAnchor].active = YES;
    [self.selectView.bottomAnchor constraintEqualToAnchor:self.segmentView.bottomAnchor].active = YES;
    [self.selectView.widthAnchor constraintEqualToAnchor:self.segmentView.widthAnchor multiplier:0.5].active = YES;
    
    self.reselectBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    [self.reselectBtn setTitleEdgeInsets:UIEdgeInsetsMake(self.reselectBtn.imageView.frame.size.height+14 ,-self.reselectBtn.imageView.frame.size.width, 0.0,0.0)];
    [self.reselectBtn setImageEdgeInsets:UIEdgeInsetsMake(-self.reselectBtn.titleLabel.bounds.size.height-14,(self.reselectBtn.frame.size.width-self.reselectBtn.imageView.bounds.size.width)/2.0,0.0,(self.reselectBtn.frame.size.width-self.reselectBtn.imageView.bounds.size.width)/2.0)];
    
    self.segmentView.layer.cornerRadius = 22;
    self.segmentView.layer.masksToBounds = YES;
    self.videoFrameBtn.layer.cornerRadius = 22;
    self.videoFrameBtn.layer.masksToBounds = YES;
    self.importBtn.layer.cornerRadius = 22;
    self.importBtn.layer.masksToBounds = YES;
    self.selectView.layer.cornerRadius = 22;
    self.selectView.layer.masksToBounds = YES;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = [UIFont systemFontOfSize:13];
        _titleLabel.textColor = [EOExportUIHelper eo_colorWithHex:@"FFFFFF" alpha:0.55];
        _titleLabel.text = EOExportUILocalization(@"eo_export_cover_operation");
    }
    return _titleLabel;
}

- (UIButton *)reselectBtn {
    if (!_reselectBtn) {
        _reselectBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _reselectBtn.backgroundColor = [UIColor clearColor];
        _reselectBtn.hidden = YES;
        [_reselectBtn setImage:EOExportUIImage(@"eo_export_reselect") forState:UIControlStateNormal];
        [_reselectBtn setTitle:EOExportUILocalization(@"eo_export_cover_selectagain") forState:UIControlStateNormal];
        _reselectBtn.titleLabel.textColor = [EOExportUIHelper eo_colorWithHex:@"FFFFFF"];
        _reselectBtn.titleLabel.font = [UIFont systemFontOfSize:13];
        [_reselectBtn addTarget:self action:@selector(reselectBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _reselectBtn;
}

- (EOVideoCoverVideoFramePickerView *)framePickerView {
    if (!_framePickerView) {
        _framePickerView = [[EOVideoCoverVideoFramePickerView alloc] init];
        _framePickerView.delegate = self;
    }
    return _framePickerView;
}

- (UIView *)segmentView {
    if (!_segmentView) {
        _segmentView = [[UIView alloc] init];
        _segmentView.backgroundColor = [EOExportUIHelper eo_colorWithHex:@"FFFFFF" alpha:0.15];
    }
    return _segmentView;
}

- (UIView *)selectView {
    if (!_selectView) {
        _selectView = [[UIView alloc] init];
        _selectView.backgroundColor = [EOExportUIHelper eo_colorWithHex:@"FFFFFF" alpha:0.15];
    }
    return _selectView;
}

- (UIButton *)videoFrameBtn {
    if (!_videoFrameBtn) {
        _videoFrameBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _videoFrameBtn.backgroundColor = [UIColor clearColor];
        [_videoFrameBtn setTitle:EOExportUILocalization(@"eo_export_cover_frame") forState:UIControlStateNormal];
        _videoFrameBtn.titleLabel.font = [UIFont systemFontOfSize:13];
        [_videoFrameBtn setTitleColor:[EOExportUIHelper eo_colorWithHex:@"FFFFFF"] forState:UIControlStateNormal];
        [_videoFrameBtn setTitleColor:[EOExportUIHelper eo_colorWithHex:@"FFFFFF"] forState:UIControlStateSelected];
        [_videoFrameBtn addTarget:self action:@selector(videoFrameBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _videoFrameBtn;
}

- (UIButton *)importBtn {
    if (!_importBtn) {
        _importBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _importBtn.backgroundColor = [UIColor clearColor];
        [_importBtn setTitle:EOExportUILocalization(@"eo_export_cover_album") forState:UIControlStateNormal];
        _importBtn.titleLabel.font = [UIFont systemFontOfSize:13];
        [_importBtn setTitleColor:[EOExportUIHelper eo_colorWithHex:@"FFFFFF"] forState:UIControlStateNormal];
        [_importBtn setTitleColor:[EOExportUIHelper eo_colorWithHex:@"FFFFFF"] forState:UIControlStateSelected];
        [_importBtn addTarget:self action:@selector(importBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _importBtn;
}

- (void)reselectBtnClick:(UIButton *)sender {
    [self.delegate switchPreviewOrPickAlbumImage:YES isReselect:YES];
}

- (void)setVideoSliderValue:(CGFloat)value{
    [self.framePickerView setVideoSliderValue:value];
}

- (void)videoFrameBtnClick:(UIButton *)sender {
    NSLayoutConstraint *constraintToRemove = nil;
    for (NSLayoutConstraint *constraint in self.selectView.superview.constraints) {
        if (constraint.firstItem == self.selectView) {
            constraintToRemove = constraint;
            [self.selectView.superview removeConstraint:constraintToRemove];
        }
    }
    [UIView animateWithDuration:0.2 animations:^{
        [self.selectView.leftAnchor constraintEqualToAnchor:self.segmentView.leftAnchor].active = YES;
        [self.selectView.topAnchor constraintEqualToAnchor:self.segmentView.topAnchor].active = YES;
        [self.selectView.bottomAnchor constraintEqualToAnchor:self.segmentView.bottomAnchor].active = YES;
        [self.selectView.widthAnchor constraintEqualToAnchor:self.segmentView.widthAnchor multiplier:0.5].active = YES;
        [self.selectView.superview layoutIfNeeded];
        self.titleLabel.hidden = NO;
        self.framePickerView.hidden = NO;
        self.reselectBtn.hidden = YES;
    }];
    [self.delegate switchPreviewOrPickAlbumImage:NO isReselect:NO];
}

- (void)importBtnClick:(UIButton *)sender {
    if (self.isSelectPickAlbumImage) {
        [self selectPickAlbumImage];
    }
    [self.delegate switchPreviewOrPickAlbumImage:YES isReselect:NO];
}

- (void)setIsSelectPickAlbumImage:(BOOL)isSelectPickAlbumImage {
    _isSelectPickAlbumImage = isSelectPickAlbumImage;
    if (isSelectPickAlbumImage) {
        [self selectPickAlbumImage];
    }
}
- (void)selectPickAlbumImage {
    NSLayoutConstraint *constraintToRemove = nil;
    for (NSLayoutConstraint *constraint in self.selectView.superview.constraints) {
        if (constraint.firstItem == self.selectView) {
            constraintToRemove = constraint;
            [self.selectView.superview removeConstraint:constraintToRemove];
        }
    }
    [UIView animateWithDuration:0.2 animations:^{
        [self.selectView.rightAnchor constraintEqualToAnchor:self.segmentView.rightAnchor].active = YES;
        [self.selectView.topAnchor constraintEqualToAnchor:self.segmentView.topAnchor].active = YES;
        [self.selectView.bottomAnchor constraintEqualToAnchor:self.segmentView.bottomAnchor].active = YES;
        [self.selectView.widthAnchor constraintEqualToAnchor:self.segmentView.widthAnchor multiplier:0.5].active = YES;
        [self.selectView.superview layoutIfNeeded];
        self.titleLabel.hidden = YES;
        self.framePickerView.hidden = YES;
        self.reselectBtn.hidden = NO;
    }];
}

- (void)updateVideoFrames:(NSArray<UIImage *> *)frames durationRatios:(NSArray<NSNumber *> *)durationRatioArr {
    [self.framePickerView updateVideoFrames:frames durationRatios:durationRatioArr];
}

- (void)updatePreviewCurrentTimeWithRatio:(CGFloat)ratio {
    [self.delegate updatePreviewCurrentTimeWithRatio:ratio];
}

@end
