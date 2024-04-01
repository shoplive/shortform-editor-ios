//
//  EOExportConfigView.m
//  EOEasyEditorUI
//
//

#import "EOExportConfigView.h"
#import "EOPopSelectView.h"
#import "EOExportUIHelper.h"

@interface EOExportConfigView()

@property (nonatomic, strong) UILabel *fpsLabel;
@property (nonatomic, strong) UILabel *presentLabel;
@property (nonatomic, strong) UIView *backgroundView;
@property (nonatomic, strong) UIView *emptyView;
@property (nonatomic, strong) UIButton *resetBtn;
@property (nonatomic, strong) UIButton *saveBtn;

@property (nonatomic, strong) EOPopSelectView *fpsSelectView;
@property (nonatomic, strong) EOPopSelectView *presentSelectView;
@property (nonatomic, copy) NSArray<NSString *> *fpsArr;
@property (nonatomic, copy) NSArray<NSString *> *presentArr;
@property (nonatomic, assign) NSInteger fpsIndex;
@property (nonatomic, assign) NSInteger presentIndex;

@end


@implementation EOExportConfigView

- (instancetype)initWithFrame:(CGRect)frame fpsArr:(NSArray<NSString *> *)fpsArr presentArr:(NSArray<NSString *> *)resolutionArr fpsDefaultIndex:(NSInteger)fpsIndex resolutionDefaultIndex:(NSInteger)resolutionIndex
{
    self = [super initWithFrame:frame];
    if (self) {
        _fpsArr = fpsArr;
        self.fpsIndex = fpsIndex;
        self.presentIndex = resolutionIndex;
        _presentArr = resolutionArr;
        [self buildLayout];
        [self addGestureAction];
    }
    return self;
}

- (void)buildLayout
{
    self.backgroundColor = [UIColor clearColor];
    [self addSubview:self.backgroundView];
    [self addSubview:self.emptyView];
    [self.emptyView addSubview:self.fpsSelectView];
    [self.emptyView addSubview:self.presentSelectView];
    [self.emptyView addSubview:self.fpsLabel];
    [self.emptyView addSubview:self.presentLabel];
    [self.emptyView addSubview:self.resetBtn];
    [self.emptyView addSubview:self.saveBtn];
    self.resetBtn.layer.cornerRadius = 8.0;
    self.resetBtn.layer.masksToBounds = YES;
    self.saveBtn.layer.cornerRadius = 8.0;
    self.saveBtn.layer.masksToBounds = YES;
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:self.bounds byRoundingCorners:UIRectCornerTopLeft | UIRectCornerTopRight cornerRadii:CGSizeMake(8, 8)];
    CAShapeLayer *layer = [CAShapeLayer layer];
    layer.path = path.CGPath;
    self.emptyView.layer.mask = layer;
}

- (void)addGestureAction
{
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickBackGround)];
    [self.backgroundView addGestureRecognizer:tap];
    self.backgroundView.userInteractionEnabled = YES;
}

#pragma mark - setter

- (void)setDelegate:(id<EOExportConfigViewDelegate>)delegate
{
    _delegate = delegate;
}

#pragma mark - UI懒加载

- (UIView *)emptyView
{
    if (!_emptyView) {
        _emptyView = [[UIView alloc] initWithFrame:CGRectMake(0, EO_ScreenHeight(), self.frame.size.width, 252+EO_HomeIndicatorHeight())];
        _emptyView.backgroundColor = [EOExportUIHelper eo_colorWithHex:@"1B1B1B"];
    }
    return _emptyView;
}

- (UIView *)backgroundView
{
    if (!_backgroundView) {
        _backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        _backgroundView.backgroundColor = [UIColor clearColor];
    }
    return _backgroundView;
}

- (EOPopSelectView *)presentSelectView
{
    if (!_presentSelectView) {
        __weak typeof(self) weakSelf = self;
        _presentSelectView = [[EOPopSelectView alloc] initWithFrame:CGRectMake(16, 38, EO_ScreenWidth() - 32, 60)
                                                          dataSource:self.presentArr
                                                  defaultSelectIndex:self.presentIndex
                                                         SelectBlock:^(NSInteger selectIndex) {
            __strong typeof(self) strongSelf = weakSelf;
            strongSelf.presentIndex = selectIndex;
        }];
    }
    return _presentSelectView;
}

- (EOPopSelectView *)fpsSelectView
{
    if (!_fpsSelectView) {
        __weak typeof(self) weakSelf = self;
        _fpsSelectView = [[EOPopSelectView alloc] initWithFrame:CGRectMake(16, 116, EO_ScreenWidth() - 32, 60)
                                                      dataSource:self.fpsArr
                                              defaultSelectIndex:self.fpsIndex
                                                     SelectBlock:^(NSInteger selectIndex) {
            __strong typeof(self) strongSelf = weakSelf;
            strongSelf.fpsIndex = selectIndex;
        }];
    }
    return _fpsSelectView;
}

- (UILabel *)fpsLabel
{
    if (!_fpsLabel) {
        _fpsLabel = [[UILabel alloc] initWithFrame:CGRectMake(16, 20, 300, 18)];
        _fpsLabel.text = EOExportUILocalization(@"eo_export_resolution_res");
        _fpsLabel.font = [EOExportUIHelper eo_export_pingFangRegular:14];
        _fpsLabel.textColor = [EOExportUIHelper eo_colorWithHex:@"FFFFFF" alpha:0.55];
    }
    return _fpsLabel;
}

- (UILabel *)presentLabel
{
    if (!_presentLabel) {
        _presentLabel = [[UILabel alloc] initWithFrame:CGRectMake(16, 98, 300, 18)];
        _presentLabel.text = EOExportUILocalization(@"eo_export_resolution_fps");
        _presentLabel.font = [EOExportUIHelper eo_export_pingFangRegular:14];
        _presentLabel.textColor = [EOExportUIHelper eo_colorWithHex:@"FFFFFF" alpha:0.55];
    }
    return _presentLabel;
}

- (UIButton *)saveBtn {
    if (!_saveBtn) {
        _saveBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _saveBtn.backgroundColor = [EOExportUIHelper eo_colorWithHex:@"0ECDEB"];
        [_saveBtn setTitleColor:[EOExportUIHelper eo_colorWithHex:@"161823"] forState:UIControlStateNormal];
        [_saveBtn setTitle:EOExportUILocalization(@"eo_export_resolution_save") forState:UIControlStateNormal];
        [_saveBtn addTarget:self action:@selector(saveClick:) forControlEvents:UIControlEventTouchUpInside];
        _saveBtn.titleLabel.font = [EOExportUIHelper eo_export_pingFangRegular:15];
        _saveBtn.frame = CGRectMake(EO_ScreenWidth()/2+7, self.emptyView.frame.size.height-9-44-EO_HomeIndicatorHeight(), (EO_ScreenWidth()-46)/2, 44);

    }
    return _saveBtn;
}

- (UIButton *)resetBtn {
    if (!_resetBtn) {
        _resetBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _resetBtn.backgroundColor = [EOExportUIHelper eo_colorWithHex:@"FFFFFF" alpha:0.06];
        [_resetBtn setTitleColor:[EOExportUIHelper eo_colorWithHex:@"FFFFFF"] forState:UIControlStateNormal];
        [_resetBtn setTitle:EOExportUILocalization(@"eo_export_resolution_reset") forState:UIControlStateNormal];
        [_resetBtn addTarget:self action:@selector(resetClick:) forControlEvents:UIControlEventTouchUpInside];
        _resetBtn.titleLabel.font = [EOExportUIHelper eo_export_pingFangRegular:15];
        _resetBtn.frame = CGRectMake(16, self.emptyView.frame.size.height-9-44-EO_HomeIndicatorHeight(), (EO_ScreenWidth()-46)/2, 44);
    }
    return _resetBtn;
}

- (void)saveClick:(UIButton *)sender {
    [self.delegate didSelectSaveResolution:self.presentIndex FPS:self.fpsIndex];
}

- (void)resetClick:(UIButton *)sender {
    self.presentIndex = 1;
    self.fpsIndex = 1;
    [self.presentSelectView setupCollectViewSelectIndex:self.presentIndex];
    [self.fpsSelectView setupCollectViewSelectIndex:self.fpsIndex];
}

- (void)clickBackGround
{
    [self.delegate didClickEmptyAreaInExportConfigView];
}

#pragma mark - UIView显示和移除方法
- (void)showInView:(UIView *)parentView
{
    if (parentView) {
        [parentView addSubview:self];
        [UIView animateWithDuration:0.15f
                         animations:^{
            self.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
            self.emptyView.frame = CGRectMake(0, EO_ScreenHeight()-252-EO_HomeIndicatorHeight(), EO_ScreenWidth(), 252+EO_HomeIndicatorHeight());
        }];
    }
}

- (void)dismiss
{
    [UIView animateWithDuration:0.15f
                     animations:^{
        self.frame = CGRectMake(0, EO_ScreenHeight(), self.frame.size.width, self.frame.size.height);
        self.emptyView.frame = CGRectMake(0, EO_ScreenHeight(), EO_ScreenWidth(), 252+EO_HomeIndicatorHeight());
    } completion:^(BOOL finished) {
        if(finished){
            [self removeFromSuperview];
        }
    }];
}


@end
