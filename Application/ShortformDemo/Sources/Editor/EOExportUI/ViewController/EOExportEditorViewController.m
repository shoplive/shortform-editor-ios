//
//  EOExportEditorViewController.m
//  EOEasyEditorUI
//
//

#import "EOExportEditorViewController.h"
#import "EOVideoCoverResourcePickerView.h"
#import "EOExportUIHelper.h"

@interface EOExportEditorViewController ()<EOVideoCoverResourcePickerDelegate>

@property(nonatomic, strong) UIView *previewView;
@property (nonatomic, strong) EOVideoCoverResourcePickerView *pickerView;
@property (nonatomic, strong) UIImageView *coverView;
@property (nonatomic, strong) NSMutableArray<UIImage *> *frames;
// {zh} 获得的每个视频帧(不大于1s，一般1s取一帧),对应的视频时长比例（时长/1s） {en} For each video frame obtained (not more than 1s, generally 1s takes one frame), the corresponding video duration ratio (duration/1s)
@property (nonatomic, strong) NSMutableArray<NSNumber *> *durationRatios;
@property (nonatomic, strong) UIButton *cancelButton;
@property (nonatomic, strong) UIButton *finishButton;

@property (nonatomic, assign) BOOL isReselect;
@property (nonatomic, assign) BOOL isSwitch;


@end

@implementation EOExportEditorViewController

-(UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.frames = [NSMutableArray array];
        self.durationRatios = [NSMutableArray array];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [EOExportUIHelper eo_colorWithHex:@"000000"];
    self.isSwitch = NO;
    [self preViewLayout];
    [self.manager pause];
    [self.manager setVideoRatioTime:0 isSmooth:NO];
    [self.manager setVideoRatioTime:self.videoFrameTime isSmooth:NO];
    
    [self p_setupNavBackItem];
    
}

- (void)preViewLayout {
    CGFloat ratio = [self.manager getVideoSize].width/[self.manager getVideoSize].height;
    CGFloat previewViewHeight = EO_ScreenHeight() * 445.0/812.0;
    CGFloat newHeight = ratio>1 ? EO_ScreenWidth()/ratio : previewViewHeight;
    CGFloat newWidth = ratio>1 ? EO_ScreenWidth() : newHeight*ratio;
    CGFloat newX = (EO_ScreenWidth()-newWidth)/2;
    CGFloat newY = EO_NavBarHeight()+48+(previewViewHeight-newHeight)/2;
    self.previewView = [[UIView alloc] initWithFrame:CGRectMake(newX, newY, newWidth, newHeight)];
    [self.view addSubview:self.previewView];
    [self.manager setCanvasSize];
    [self.manager resetPlayeView:self.previewView];
    
    [self.view addSubview:self.pickerView];
    //     {zh} 相册封面     {en} album cover
    [self.view addSubview:self.coverView];
    self.coverView.frame = self.previewView.frame;
    // {zh} 轨道操作区域 {en} Track operation area
    self.pickerView.translatesAutoresizingMaskIntoConstraints = false;
    [self.pickerView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor].active = YES;
    [self.pickerView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor].active = YES;
    [self.pickerView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor].active = YES;
    [self.pickerView.heightAnchor constraintEqualToConstant:EO_HomeIndicatorHeight()+170].active = YES;
    
    [self setUpVideoClipSegmentData];
    if (self.coverImage) {
        self.coverView.image = self.coverImage;
    }
    if (self.isCoverImage) {
        self.pickerView.isSelectPickAlbumImage = YES;
        [self switchPreviewOrPickAlbumImage:YES];
    }
    self.previewView.layer.cornerRadius = 20;
    self.previewView.layer.masksToBounds = YES;
    self.coverView.layer.cornerRadius = 20;
    self.coverView.layer.masksToBounds = YES;
}

- (void)cancelButtonClick:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)finishButtonClick:(UIButton *)sender {
    if (!self.isSwitch) {
        CGFloat ratioTime = self.videoFrameTime * 1.0 / USEC_PER_SEC;
        UIImage *currentImage = [self.manager capturePreviewUIImage];
       !self.onDismiss ?: self.onDismiss(currentImage, self.videoFrameTime,NO);
       [self dismissViewControllerAnimated:YES completion:nil];
    }
    else {
        !self.onDismiss ?: self.onDismiss(self.coverView.image,0,YES);
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    
}

- (void)setCoverImage:(UIImage *)coverImage {
    _coverImage = coverImage;
}

- (void)setIsCoverImage:(BOOL)isCoverImage {
    _isCoverImage = isCoverImage;
}

- (void)p_setupNavBackItem {
    [self.view addSubview:self.cancelButton];
    self.cancelButton.translatesAutoresizingMaskIntoConstraints = false;
    [self.cancelButton.topAnchor constraintEqualToAnchor:self.view.topAnchor constant:EO_StatusBarHeight()+8].active = YES;
    [self.cancelButton.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:16].active = YES;
    [self.cancelButton.widthAnchor constraintEqualToConstant:70].active = YES;
    [self.cancelButton.heightAnchor constraintEqualToConstant:32].active = YES;
    
    [self.view addSubview:self.finishButton];
    self.finishButton.translatesAutoresizingMaskIntoConstraints = false;
    [self.finishButton.topAnchor constraintEqualToAnchor:self.view.topAnchor constant:EO_StatusBarHeight()+8].active = YES;
    [self.finishButton.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-16].active = YES;
    [self.finishButton.heightAnchor constraintEqualToConstant:32].active = YES;
    [self.finishButton.widthAnchor constraintEqualToConstant:70].active = YES;
}

- (void)setUpVideoClipSegmentData {
    if (self.frames.count) return;
    [self.frames removeAllObjects];
    CGSize size = self.previewView.frame.size;
    NSTimeInterval durationStep = [self.manager totalVideoDuration] / 12;
    NSMutableArray *timeArray = [NSMutableArray arrayWithCapacity:0];
    for (NSInteger index = 0; index < 12; index++) {
        [timeArray addObject:[NSNumber numberWithFloat:durationStep * index]];
    }
    __weak typeof(self) weakSelf = self;
    [self.manager getPreviewImages:[timeArray copy] preferredSize:size withEffect:YES frameBlock:^(UIImage * _Nonnull image, NSTimeInterval atTime) {
        __strong typeof(self) strongSelf = weakSelf;
        if (image) {
            [strongSelf.frames addObject:image];
            if (strongSelf.frames.count == 12) {
                [strongSelf.pickerView updateVideoFrames:strongSelf.frames durationRatios:strongSelf.durationRatios];
            }
        }
    }];
}

#pragma mark - DVEVideoCoverResourcePickerDelegate
- (void)updatePreviewCurrentTimeWithRatio:(CGFloat)ratio {
    self.videoFrameTime = ratio * [self.manager mainTrackMaxEnd] * USEC_PER_SEC;
    [self.manager setVideoRatioTime:self.videoFrameTime isSmooth:NO];
}

- (void)backImageResourcePickerView {
    if (!self.isReselect) {
        self.pickerView.isSelectPickAlbumImage = NO;
    }
    [self switchPreviewOrPickAlbumImage:YES isReselect:self.isReselect];
}

- (void)switchPreviewOrPickAlbumImage:(BOOL)isSwitch isReselect:(BOOL)reselect{
    self.isReselect = reselect;
    self.isSwitch = isSwitch;
    if (isSwitch) {
        if (!self.pickerView.isSelectPickAlbumImage || reselect) {
            __weak typeof(self) weakSelf = self;
            if (self.delegate && [self.delegate respondsToSelector:@selector(getPickSingleImageResourceWithCompletion:)]) {
                [self.delegate getPickSingleImageResourceWithCompletion:^(NSURL * _Nullable pickImage, NSError * _Nullable error, BOOL cancel) {
                    if (pickImage) {
                        [weakSelf.manager pushCropVC:weakSelf imagePath:[pickImage path] Completion:^(NSString * _Nonnull imagePath) {
                            if (imagePath.length) {
                                weakSelf.coverView.image = [UIImage imageWithContentsOfFile:imagePath];
                                weakSelf.pickerView.isSelectPickAlbumImage = YES;
                                [weakSelf switchPreviewOrPickAlbumImage:YES];
                            }
                        }];
                    }
                }];
            } else {
                [self.manager getPickSingleImageResourceWithCompletion:^(NSURL * _Nullable pickImage, NSError * _Nullable error, BOOL cancel) {
                    if (pickImage) {
                        [weakSelf.manager pushCropVC:weakSelf imagePath:[pickImage path] Completion:^(NSString * _Nonnull imagePath) {
                            if (imagePath.length) {
                                weakSelf.coverView.image = [UIImage imageWithContentsOfFile:imagePath];
                                weakSelf.pickerView.isSelectPickAlbumImage = YES;
                                [weakSelf switchPreviewOrPickAlbumImage:YES];
                            }
                        }];
                    }
                }];
            }
        }
        else {
            [self switchPreviewOrPickAlbumImage:isSwitch];
        }
    }
    else {
        [self switchPreviewOrPickAlbumImage:isSwitch];
    }
}


- (void)switchPreviewOrPickAlbumImage:(BOOL)isSwitch {
    self.previewView.hidden = isSwitch;
    self.isSwitch = isSwitch;
    self.coverView.hidden = !isSwitch;
}

- (EOVideoCoverResourcePickerView *)pickerView {
    if (!_pickerView) {
        _pickerView = [[EOVideoCoverResourcePickerView alloc] init];
        _pickerView.delegate = self;
    }
    return _pickerView;
}

- (UIButton *)cancelButton {
    if (!_cancelButton) {
        _cancelButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 80, 32)];
        [_cancelButton setTitle:EOExportUILocalization(@"eo_export_cancel") forState:UIControlStateNormal];
        [_cancelButton setTitleColor:[EOExportUIHelper eo_colorWithHex:@"FFFFFF"] forState:UIControlStateNormal];
        [_cancelButton addTarget:self action:@selector(cancelButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        _cancelButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    }
    return _cancelButton;
}

- (UIButton *)finishButton {
    if (!_finishButton) {
        _finishButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 80, 32)];
        [_finishButton setTitle:EOExportUILocalization(@"eo_export_cover_finish") forState:UIControlStateNormal];
        _finishButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        [_finishButton setTitleColor:[EOExportUIHelper eo_colorWithHex:@"FFFFFF"] forState:UIControlStateNormal];
        [_finishButton addTarget:self action:@selector(finishButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _finishButton;
}

// {zh} 相册封面 {en} album cover
- (UIImageView *)coverView {
    if (!_coverView) {
        _coverView = [[UIImageView alloc] init];
        _coverView.hidden = YES;
        _coverView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _coverView;
}

- (void)setVideoFrameTime:(int64_t)videoFrameTime {
    _videoFrameTime = videoFrameTime;
    [self.pickerView setVideoSliderValue:videoFrameTime * 1.0 / USEC_PER_SEC / [self.manager mainTrackMaxEnd]];
}

@end
