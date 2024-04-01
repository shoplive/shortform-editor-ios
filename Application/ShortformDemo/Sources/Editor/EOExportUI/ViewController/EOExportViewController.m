//
//  EOExportViewController.m
//  EOEasyEditorUI
//
//

#import "EOExportViewController.h"
#import "EOExportEditorViewController.h"
#import "EOExportUIHelper.h"
#import "EOExportConfigView.h"
//#import <Toast/UIView+Toast.h>
#import <Photos/Photos.h>
#if __has_include(<EOEasyEditor/EOExportModel.h>)
#import <EOEasyEditor/EOExportModel.h>
#endif
#if __has_include(<EOEasyEditorUI/EOExportManager.h>)
#import <EOEasyEditorUI/EOExportManager.h>
#else
#import <EffectOneKit/EOExportManager.h>
#import <EffectOneKit/EOExportModel.h>
#endif

@interface EOExportViewController ()<EOExportConfigViewDelegate, EOExportEditorViewControllerDelegate>

@property (nonatomic, strong) UIButton *backButton;
@property (nonatomic, strong) UIButton *finishButton;
@property (nonatomic, strong) UIButton *cancelButton;

@property (nonatomic, strong) UIImageView *coverView;
@property (nonatomic, strong) UIButton *coverEditBtn;
@property (nonatomic, strong) UIButton *resolutionBtn;
@property (nonatomic, strong) UISlider *videoSlider;
@property (nonatomic, strong) UILabel *progressLabel;

@property(nonatomic, strong) UIView *previewView;
@property(nonatomic, assign) CGRect originPreviewFrame;
@property (nonatomic, assign) int64_t videoFrameTime;
@property (nonatomic, assign) BOOL isCoverImage;
@property (nonatomic, assign) CMTime currentCMTime;
@property (nonatomic, strong) EOExportConfigView *configView;
@property (nonatomic, assign) NSInteger fpsIndex;
@property (nonatomic, assign) NSInteger presentIndex;
@property (nonatomic, assign) BOOL exportState;
@property (nonatomic, assign) BOOL isSelectCancelBtn;
@property (nonatomic, strong) UIImage *coverImg;
@property (nonatomic, strong) EOExportManager *manager;
@property (nonatomic, strong) EOExportModel *model;
@property (nonatomic, strong) NSLayoutConstraint *constraintToLeft;
@end

@implementation EOExportViewController

-(UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

+ (void)startExportWithExportModel:(EOExportModel *)exportModel presentVC:(UIViewController *)viewController{
    EOExportViewController *export = [[EOExportViewController alloc] init];
    export.model = exportModel;
    export.modalPresentationStyle = UIModalPresentationFullScreen;
    [viewController presentViewController:export animated:YES completion:nil];
}

+ (void)startExportWithExportModel:(EOExportModel *)exportModel
                         presentVC:(UIViewController *)viewController
                        delegate:(id<EOExportViewControllerDelegate> _Nullable)delegate {
    EOExportViewController *export = [[EOExportViewController alloc] init];
    export.delegate = delegate;
    export.model = exportModel;
    export.modalPresentationStyle = UIModalPresentationFullScreen;
    [viewController presentViewController:export animated:YES completion:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor blackColor];
    self.manager = [[EOExportManager alloc] initWithExportModel:self.model];
    self.videoFrameTime = 0;
    self.fpsIndex = 1;
    self.presentIndex = 1;
    self.isCoverImage = NO;
    self.exportState = NO;
    self.isSelectCancelBtn = NO;
    [self p_setupNavBackItem];
    [self layoutUI];
    [self.manager setCanvasColor:[EOExportUIHelper eo_colorWithHex:@"000000"]];
    

    [self.manager getVideoCoverImage:self.model.originRatioSize success:^(UIImage * _Nonnull draftImg, UIImage * _Nonnull videoImg, int64_t videoFrameTime, NSString * _Nonnull coverType) {
        self.videoFrameTime = videoFrameTime;
        if ([coverType isEqualToString:@"image"]) {
            self.isCoverImage = YES;
        }
        if (draftImg) {
            self.coverView.image = draftImg;
            self.coverImg = draftImg;
        }
        else {
            self.coverView.image = videoImg;
            self.coverImg = videoImg;
        }
    }];
}

- (void)layoutUI {
    CGFloat ratio = [self.manager getVideoSize].width/[self.manager getVideoSize].height;
    CGFloat previewViewHeight = EO_ScreenHeight() * 445.0/812.0;
    CGFloat newHeight = ratio>1 ? EO_ScreenWidth()/ratio : previewViewHeight;
    CGFloat newWidth = ratio>1 ? EO_ScreenWidth() : newHeight*ratio;
    CGFloat newY = EO_NavBarHeight()+48+(previewViewHeight-newHeight)/2;
    [self.view addSubview:self.coverView];
    self.coverView.translatesAutoresizingMaskIntoConstraints = false;
    [self.coverView.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor].active = YES;
    [self.coverView.topAnchor constraintEqualToAnchor:self.view.topAnchor constant:newY].active = YES;
    [self.coverView.widthAnchor constraintEqualToConstant:newWidth].active = YES;
    [self.coverView.heightAnchor constraintEqualToConstant:newHeight].active = YES;
    self.coverView.layer.cornerRadius = 20;
    self.coverView.layer.masksToBounds = YES;
    
    [self.view addSubview:self.finishButton];
    self.finishButton.translatesAutoresizingMaskIntoConstraints = false;
    [self.finishButton.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor].active = YES;
    [self.finishButton.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor constant:-EO_HomeIndicatorHeight()-5].active = YES;
    [self.finishButton.widthAnchor constraintEqualToConstant:209].active = YES;
    [self.finishButton.heightAnchor constraintEqualToConstant:44].active = YES;
    self.finishButton.layer.masksToBounds = YES;
    self.finishButton.layer.cornerRadius = 22;
    
    [self.view addSubview:self.coverEditBtn];
    self.coverEditBtn.translatesAutoresizingMaskIntoConstraints = false;
    [self.coverEditBtn.rightAnchor constraintEqualToAnchor:self.view.centerXAnchor constant:-21].active = YES;
    [self.coverEditBtn.bottomAnchor constraintEqualToAnchor:self.finishButton.topAnchor constant:-62].active = YES;
    [self.coverEditBtn.widthAnchor constraintEqualToConstant:100].active = YES;
    [self.coverEditBtn.heightAnchor constraintEqualToConstant:54].active = YES;
    self.coverEditBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    [self.coverEditBtn setTitleEdgeInsets:UIEdgeInsetsMake(self.coverEditBtn.imageView.frame.size.height+14 ,-self.coverEditBtn.imageView.frame.size.width, 0.0,0.0)];
    [self.coverEditBtn setImageEdgeInsets:UIEdgeInsetsMake(-self.coverEditBtn.titleLabel.bounds.size.height-14,(self.coverEditBtn.frame.size.width-self.coverEditBtn.imageView.bounds.size.width)/2.0,0.0,(self.coverEditBtn.frame.size.width-self.coverEditBtn.imageView.bounds.size.width)/2.0)];
    
    [self.view addSubview:self.resolutionBtn];
    self.resolutionBtn.translatesAutoresizingMaskIntoConstraints = false;
    [self.resolutionBtn.leftAnchor constraintEqualToAnchor:self.view.centerXAnchor constant:21].active = YES;
    [self.resolutionBtn.bottomAnchor constraintEqualToAnchor:self.finishButton.topAnchor constant:-62].active = YES;
    [self.resolutionBtn.widthAnchor constraintEqualToConstant:80].active = YES;
    [self.resolutionBtn.heightAnchor constraintEqualToConstant:54].active = YES;
    self.resolutionBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    [self.resolutionBtn setTitleEdgeInsets:UIEdgeInsetsMake(self.resolutionBtn.imageView.frame.size.height+14 ,-self.resolutionBtn.imageView.frame.size.width, 0.0,0.0)];
    [self.resolutionBtn setImageEdgeInsets:UIEdgeInsetsMake(-self.resolutionBtn.titleLabel.bounds.size.height-14,(self.resolutionBtn.frame.size.width-self.resolutionBtn.imageView.bounds.size.width)/2.0,0.0,(self.resolutionBtn.frame.size.width-self.resolutionBtn.imageView.bounds.size.width)/2.0)];
    
    [self.view addSubview:self.videoSlider];
    self.videoSlider.translatesAutoresizingMaskIntoConstraints = false;
    [self.videoSlider.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor].active = YES;
    [self.videoSlider.centerYAnchor constraintEqualToAnchor:self.coverEditBtn.centerYAnchor].active = YES;
    [self.videoSlider.widthAnchor constraintEqualToConstant:227].active = YES;
    [self.videoSlider.heightAnchor constraintEqualToConstant:4].active = YES;
    
    [self.view addSubview:self.progressLabel];
    self.progressLabel.translatesAutoresizingMaskIntoConstraints = false;

    self.constraintToLeft = [self.progressLabel.leftAnchor constraintEqualToAnchor:self.videoSlider.leftAnchor constant:-17];
    self.constraintToLeft.active = YES;
    [self.progressLabel.bottomAnchor constraintEqualToAnchor:self.videoSlider.topAnchor constant:0].active = YES;
    [self.progressLabel.widthAnchor constraintEqualToConstant:34].active = YES;
    [self.progressLabel.heightAnchor constraintEqualToConstant:15].active = YES;
}

// {zh} 相册封面 {en} album cover
- (UIImageView *)coverView {
    if (!_coverView) {
        _coverView = [[UIImageView alloc] init];
        _coverView.contentMode = UIViewContentModeScaleAspectFill;
    }
    return _coverView;
}

- (void)p_setupNavBackItem {
    [self.view addSubview:self.backButton];
    [self.view addSubview:self.cancelButton];
    self.backButton.translatesAutoresizingMaskIntoConstraints = false;
    [self.backButton.topAnchor constraintEqualToAnchor:self.view.topAnchor constant:EO_StatusBarHeight()+8].active = YES;
    [self.backButton.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:16].active = YES;
    [self.backButton.widthAnchor constraintEqualToConstant:32].active = YES;
    [self.backButton.heightAnchor constraintEqualToConstant:32].active = YES;
    
    self.cancelButton.translatesAutoresizingMaskIntoConstraints = false;
    [self.cancelButton.topAnchor constraintEqualToAnchor:self.view.topAnchor constant:EO_StatusBarHeight()+8].active = YES;
    [self.cancelButton.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:16].active = YES;
    [self.cancelButton.heightAnchor constraintEqualToConstant:32].active = YES;
    [self.cancelButton.widthAnchor constraintEqualToConstant:70].active = YES;
}

- (void)clickBackButton:(UIButton *)sender {
    if (self.coverImg == self.coverView.image) {
        !self.model.onDismiss ?: self.model.onDismiss(nil, self.videoFrameTime, self.isCoverImage ? 1: 2);
    }
    else {
        !self.model.onDismiss ?: self.model.onDismiss(self.coverView.image, self.videoFrameTime, self.isCoverImage ? 1: 2);
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)coverEditBtnClick:(UIButton *)sender {
    EOExportEditorViewController *exportEditorVC = [[EOExportEditorViewController alloc] init];
    exportEditorVC.manager = self.manager;
    exportEditorVC.delegate = (id)self.delegate;
    exportEditorVC.videoFrameTime = self.videoFrameTime;
    if (self.isCoverImage) {
        exportEditorVC.isCoverImage = self.isCoverImage;
        exportEditorVC.coverImage = self.coverView.image;
    }
    exportEditorVC.modalPresentationStyle = UIModalPresentationFullScreen;
    __weak typeof(self) weakSelf = self;
    exportEditorVC.onDismiss = ^(UIImage * _Nullable videoFrameImage, int64_t videoFrameTime, BOOL isCoverImage) {
        __strong typeof(self) strongSelf = weakSelf;
        if (videoFrameImage) {
            strongSelf.isCoverImage = isCoverImage;
            strongSelf.videoFrameTime = videoFrameTime;
            strongSelf.coverView.image = videoFrameImage;
        }
    };
    [self presentViewController:exportEditorVC animated:YES completion:nil];
}

- (void)resolutionBtnClick:(UIButton *)sender {
    [self.configView showInView:[EOExportUIHelper eo_currentWindow]];
}

- (void)cancelBtnClick:(UIButton *)sender {
    if (!self.isSelectCancelBtn) {
        self.isSelectCancelBtn = YES;
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:EOExportUILocalization(@"eo_export_exit_title")
                                                                       message:EOExportUILocalization(@"eo_export_exit_message")
                                                                preferredStyle:UIAlertControllerStyleAlert];

        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:EOExportUILocalization(@"eo_export_cancel")
                                                               style:UIAlertActionStyleCancel
                                                             handler:^(UIAlertAction *action) {
            self.isSelectCancelBtn = NO;
        }];
         
        UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:EOExportUILocalization(@"eo_export_confirm")
                                                                style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction *action) {
            self.isSelectCancelBtn = NO;
            [self restoreState];
        }];
         
        [alert addAction:cancelAction];
        [alert addAction:confirmAction];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

- (void)restoreState {
    self.cancelButton.hidden = YES;
    self.backButton.hidden = NO;
    [self.manager cancelExport];
    self.exportState = NO;
    [UIView animateWithDuration:0.5f animations:^{
        self.videoSlider.hidden = YES;
        self.progressLabel.hidden = YES;
        self.coverEditBtn.hidden = NO;
        self.resolutionBtn.hidden = NO;
        self.finishButton.alpha = 1;
        if (self.isSelectCancelBtn) {
            self.isSelectCancelBtn = NO;
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    }];
}

- (void)hiddenState {
    self.backButton.hidden = YES;
    self.videoSlider.hidden = NO;
    self.cancelButton.hidden = NO;
    self.progressLabel.hidden = NO;
    self.coverEditBtn.hidden = YES;
    self.resolutionBtn.hidden = YES;
    self.exportState = YES;
    self.finishButton.alpha = 0.34;
}

- (void)finishButtonClick:(UIButton *)sender {
    if (![EOExportUIHelper isSupportExport]) {
        if (self.presentIndex == 2) {
//            [self.view makeToast:EOExportUILocalization(@"eo_export_nonsupport_1080P") duration:1.5f position:CSToastPositionCenter];
            return;
        }
        else if (self.presentIndex == 3) {
//            [self.view makeToast:EOExportUILocalization(@"eo_export_nonsupport_4K") duration:1.5f position:CSToastPositionCenter];
            return;
        }
    }
    !self.model.willExport ?: self.model.willExport();
    if (!self.exportState) {
        [self.manager saveCoverImage:self.coverView.image time:self.videoFrameTime canvasType:self.isCoverImage ? 1: 2];
        [self hiddenState];
        [self.manager shouldAddWaterMark:YES];
        [self.manager addWaterMarkImage:EOExportUIImage(@"eo_export_waterMark")];
        CGFloat WaterMarkWidth = 29;
        CGFloat WaterMarkHeight = 31;
        switch (self.presentIndex) {
            case 0:
                WaterMarkHeight = WaterMarkHeight * (540/375);
                WaterMarkWidth = WaterMarkWidth * (540/375);
                break;
            case 1:
                WaterMarkHeight = WaterMarkHeight * (720/375);
                WaterMarkWidth = WaterMarkWidth * (720/375);
                break;
            case 2:
                WaterMarkHeight = WaterMarkHeight * 1080/375;
                WaterMarkWidth = WaterMarkWidth * 1080/375;
                break;
            case 3:
                WaterMarkHeight = WaterMarkHeight * (2160/375);
                WaterMarkWidth = WaterMarkWidth * (2160/375);
                break;
            default:
                break;
        }
        [self.manager setWaterMarkSize:CGSizeMake(WaterMarkWidth, WaterMarkHeight)];
        [self.manager shouldAddCover:NO];
        __weak typeof(self) weakSelf = self;
        [self.manager exportVideoWithProgress:^(CGFloat progress) {
            __strong typeof(self) strongSelf = weakSelf;
            strongSelf.videoSlider.value = progress/100;
            strongSelf.progressLabel.text = [NSString stringWithFormat:@"%.f%@",progress,@"%"];
            strongSelf.constraintToLeft.constant = strongSelf.videoSlider.frame.size.width * progress / 100.0 - 17;
            [strongSelf.progressLabel setNeedsLayout];
        } resultBlock:^(NSError * _Nonnull error, id  _Nonnull result) {
            __strong typeof(self) strongSelf = weakSelf;
            if (error || !result) {
                if ([error.domain isEqualToString:@"cancelProcess"]) {
//                    [strongSelf.view makeToast:EOExportUILocalization(@"eo_export_exit_export_tip") duration:1.5f position:CSToastPositionCenter];
                }
                else {
//                    [strongSelf.view makeToast:EOExportUILocalization(@"eo_export_save_error") duration:1.5f position:CSToastPositionCenter];
                }
                [self restoreState];
            }
            else {
                NSURL *filePath = result;
                if (strongSelf.delegate && [self.delegate respondsToSelector:@selector(exportVideoPath:videoImage:)]) {
                    [strongSelf.delegate exportVideoPath:filePath.path videoImage:strongSelf.coverView.image];
                    [strongSelf restoreState];
                }
                else {
                    [strongSelf saveVideoToPhotoLibrary:filePath.path];
                }
            }
        }];
    }
    else{
//        [EOToast showText:EOExportUILocalization(@"eo_export_exporting_tips") duration:1.5f];
    }
}

/// {zh} 保存回调  {en} Save callback
- (void)saveVideoToPhotoLibrary:(NSString *)videoPath {
    __weak typeof(self) weakSelf = self;
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        PHAssetChangeRequest *changeRequest = [PHAssetChangeRequest creationRequestForAssetFromVideoAtFileURL:[NSURL fileURLWithPath:videoPath]];
        changeRequest.creationDate = [NSDate date];
    } completionHandler:^(BOOL success, NSError *error) {
        __strong typeof(self) strongSelf = weakSelf;
        if (success) {
            dispatch_async(dispatch_get_main_queue(), ^{
//                [strongSelf.view makeToast:EOExportUILocalization(@"eo_export_cover_savetolocal") duration:1.5f position:CSToastPositionCenter];
                [strongSelf restoreState];
            });
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [strongSelf.manager cancelExport];
//                [strongSelf.view makeToast:EOExportUILocalization(@"eo_export_save_error") duration:1.5f position:CSToastPositionCenter];
                [strongSelf restoreState];
            });
        }
        
    }];
}

- (UIButton *)backButton {
    if (!_backButton) {
        _backButton = [UIButton buttonWithType:UIButtonTypeCustom];
        UIImage *image = EOExportUIImage(@"eo_export_back");
        [_backButton setImage:image forState:UIControlStateNormal];
        [_backButton addTarget:self action:@selector(clickBackButton:) forControlEvents:UIControlEventTouchUpInside];
        _backButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    }
    return _backButton;
}

- (UIButton *)cancelButton {
    if (!_cancelButton) {
        _cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_cancelButton setTitle:EOExportUILocalization(@"eo_export_cancel") forState:UIControlStateNormal];
        _cancelButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        [_cancelButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _cancelButton.titleLabel.font = [UIFont systemFontOfSize:16];
        _cancelButton.hidden = YES;
        [_cancelButton addTarget:self action:@selector(cancelBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        _cancelButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    }
    return _cancelButton;
}

- (UIButton *)finishButton {
    if (!_finishButton) {
        _finishButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 32, 32)];
        _finishButton.backgroundColor = [EOExportUIHelper eo_colorWithHex:@"0ECDEB"];
        [_finishButton setTitle:EOExportUILocalization(@"eo_export_main") forState:UIControlStateNormal];
        [_finishButton setTitleColor:[EOExportUIHelper eo_colorWithHex:@"162123"] forState:UIControlStateNormal];
        [_finishButton addTarget:self action:@selector(finishButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _finishButton;
}

- (UIButton *)coverEditBtn {
    if (!_coverEditBtn) {
        _coverEditBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _coverEditBtn.backgroundColor = [UIColor clearColor];
        [_coverEditBtn setImage:EOExportUIImage(@"eo_export_reselect") forState:UIControlStateNormal];
        [_coverEditBtn setTitle:EOExportUILocalization(@"eo_export_cover_editor") forState:UIControlStateNormal];
        _coverEditBtn.titleLabel.textColor = [EOExportUIHelper eo_colorWithHex:@"FFFFFF"];
        _coverEditBtn.titleLabel.font = [UIFont systemFontOfSize:12];
        [_coverEditBtn addTarget:self action:@selector(coverEditBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _coverEditBtn;
}

- (UIButton *)resolutionBtn {
    if (!_resolutionBtn) {
        _resolutionBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _resolutionBtn.backgroundColor = [UIColor clearColor];
        [_resolutionBtn setImage:EOExportUIImage(@"eo_export_resolution_720") forState:UIControlStateNormal];
        [_resolutionBtn setTitle:EOExportUILocalization(@"eo_export_resolution") forState:UIControlStateNormal];
        _resolutionBtn.titleLabel.textColor = [EOExportUIHelper eo_colorWithHex:@"FFFFFF"];
        _resolutionBtn.titleLabel.font = [UIFont systemFontOfSize:12];
        [_resolutionBtn addTarget:self action:@selector(resolutionBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _resolutionBtn;
}

- (UISlider *)videoSlider {
    if (!_videoSlider) {
        _videoSlider = [[UISlider alloc] init];
        _videoSlider.hidden = YES;
        CGSize s=CGSizeMake(1, 1);
        UIGraphicsBeginImageContextWithOptions(s, 0, [UIScreen mainScreen].scale);
        UIRectFill(CGRectMake(0, 0, 1, 1));
        UIImage *img=UIGraphicsGetImageFromCurrentImageContext();
        [_videoSlider setThumbImage:img forState:UIControlStateNormal];
        [_videoSlider setThumbImage:img forState:UIControlStateHighlighted];
        _videoSlider.value = 0;
        _videoSlider.userInteractionEnabled = NO;
        _videoSlider.minimumTrackTintColor = [EOExportUIHelper eo_colorWithHex:@"20D2EE"];
        _videoSlider.maximumTrackTintColor = [EOExportUIHelper eo_colorWithHex:@"FFFFFF" alpha:0.15];
    }
    return _videoSlider;
}

- (UILabel *)progressLabel {
    if (!_progressLabel) {
        _progressLabel = [[UILabel alloc] init];
        _progressLabel.text = @"0%";
        _progressLabel.hidden = YES;
        _progressLabel.textAlignment = NSTextAlignmentCenter;
        _progressLabel.font = [UIFont systemFontOfSize:11];
        _progressLabel.textColor = [EOExportUIHelper eo_colorWithHex:@"FFFFFF"];
    }
    return _progressLabel;
}

- (EOExportConfigView *)configView
{
    if (!_configView) {
        _configView = [[EOExportConfigView alloc] initWithFrame:CGRectMake(0, EO_ScreenHeight(), EO_ScreenWidth(), EO_ScreenHeight()) fpsArr:[self.manager exportFPSTitleArr] presentArr:[self.manager exportPresentTitleArr] fpsDefaultIndex:self.fpsIndex resolutionDefaultIndex:self.presentIndex];
        _configView.delegate = self;
    }
    return _configView;
}

- (void)didSelectSaveResolution:(NSInteger)resolutionIndex FPS:(NSInteger)fpsIndex {
    self.presentIndex = resolutionIndex;
    self.fpsIndex = fpsIndex;
    [self.manager setExportFPSSelectIndex:fpsIndex];
    [self.manager setExportPresentSelectIndex:resolutionIndex];
    switch (resolutionIndex) {
        case 0:
            [self.resolutionBtn setImage:EOExportUIImage(@"eo_export_resolution_540") forState:UIControlStateNormal];
            break;
        case 1:
            [self.resolutionBtn setImage:EOExportUIImage(@"eo_export_resolution_720") forState:UIControlStateNormal];
            break;
        case 2:
            [self.resolutionBtn setImage:EOExportUIImage(@"eo_export_resolution_1080") forState:UIControlStateNormal];
            break;
        case 3:
            [self.resolutionBtn setImage:EOExportUIImage(@"eo_export_resolution_4K") forState:UIControlStateNormal];
            break;
        default:
            break;
    }
    [self.configView dismiss];
}

- (void)didClickEmptyAreaInExportConfigView{
    [self.configView dismiss];
}

@end
