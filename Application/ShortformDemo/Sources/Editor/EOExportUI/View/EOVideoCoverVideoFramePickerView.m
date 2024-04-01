//
//  EOVideoCoverVideoFramePickerView.m
//  EOEasyEditorUI
//
//

#import "EOVideoCoverVideoFramePickerView.h"
#import "EOExport.h"

static NSString * const EOVideoCoverVideoFramePickerIdentifier = @"EOEVideoCoverVideoFramePickerIdentifier";

@interface EOVideoCoverVideoFramePickerItem ()


@end

@implementation EOVideoCoverVideoFramePickerItem

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self addSubview:self.imageView];
        self.imageView.translatesAutoresizingMaskIntoConstraints = false;
        [self.imageView.topAnchor constraintEqualToAnchor:self.topAnchor].active = YES;
        [self.imageView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor].active = YES;
        [self.imageView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor].active = YES;
        [self.imageView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor].active = YES;
    }
    return self;
}

- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc] init];
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.clipsToBounds = YES;
    }
    return _imageView;
}

@end

@interface EOVideoCoverVideoFramePickerView () <UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, strong) UICollectionView *videoFramesView;
@property (nonatomic, copy) NSArray<UIImage *> *frames;
@property (nonatomic, copy) NSArray<NSNumber *> *durationRatios;
@property (nonatomic, strong) UISlider *videoSlider;
@property (nonatomic, assign) NSInteger itemWidth;

@end

@implementation EOVideoCoverVideoFramePickerView

- (void)willMoveToSuperview:(UIView *)newSuperview {
    if (!newSuperview) {
        return;
    }
    [self addSubview:self.videoFramesView];
    [self addSubview:self.videoSlider];
    self.itemWidth = 0;
    
    self.videoFramesView.translatesAutoresizingMaskIntoConstraints = false;
    [self.videoFramesView.heightAnchor constraintEqualToConstant:26].active = YES;
    [self.videoFramesView.rightAnchor constraintEqualToAnchor:self.rightAnchor constant:-20].active = YES;
    [self.videoFramesView.leftAnchor constraintEqualToAnchor:self.leftAnchor constant:20].active = YES;
    [self.videoFramesView.topAnchor constraintEqualToAnchor:self.topAnchor constant:6].active = YES;
    self.videoFramesView.layer.cornerRadius = 4;
    self.videoFramesView.layer.masksToBounds = YES;
    
    self.videoSlider.translatesAutoresizingMaskIntoConstraints = false;
    [self.videoSlider.leftAnchor constraintEqualToAnchor:self.leftAnchor constant:20].active = YES;
    [self.videoSlider.topAnchor constraintEqualToAnchor:self.topAnchor].active = YES;
    [self.videoSlider.rightAnchor constraintEqualToAnchor:self.rightAnchor constant:-20].active = YES;
    [self.videoSlider.heightAnchor constraintEqualToConstant:36].active = YES;
}

- (void)updateVideoFrames:(NSArray<UIImage *> *)frames durationRatios:(NSArray<NSNumber *> *)durationRatios {
    self.frames = frames;
    if (self.itemWidth == 0) {
        self.itemWidth = (self.frame.size.width-40)/frames.count;
        CGFloat spacing = (self.frame.size.width-self.itemWidth*frames.count)/2;
        [self.videoFramesView.rightAnchor constraintEqualToAnchor:self.rightAnchor constant:-spacing].active = YES;
        [self.videoFramesView.leftAnchor constraintEqualToAnchor:self.leftAnchor constant:spacing].active = YES;
        [self.videoSlider.rightAnchor constraintEqualToAnchor:self.rightAnchor constant:-spacing].active = YES;
        [self.videoSlider.leftAnchor constraintEqualToAnchor:self.leftAnchor constant:spacing].active = YES;
    }
    self.durationRatios = durationRatios;
    [self.videoFramesView reloadData];
}

- (UICollectionView *)videoFramesView {
    if (!_videoFramesView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.minimumLineSpacing = 0;
        layout.minimumInteritemSpacing = 0;
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        layout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);
        _videoFramesView = [[UICollectionView alloc] initWithFrame:CGRectZero
                                              collectionViewLayout:layout];
        _videoFramesView.backgroundColor = [UIColor clearColor];
        _videoFramesView.showsVerticalScrollIndicator = NO;
        _videoFramesView.showsHorizontalScrollIndicator = NO;
        _videoFramesView.allowsMultipleSelection = NO;
        _videoFramesView.scrollEnabled = NO;
        _videoFramesView.delegate = self;
        _videoFramesView.dataSource = self;
        [_videoFramesView registerClass:[EOVideoCoverVideoFramePickerItem class]
             forCellWithReuseIdentifier:EOVideoCoverVideoFramePickerIdentifier];
        
    }
    return _videoFramesView;
}

- (UISlider *)videoSlider {
    if (!_videoSlider) {
        _videoSlider = [[UISlider alloc] init];
        [_videoSlider setThumbImage:EOExportUIImage(@"eo_export_slider") forState:UIControlStateNormal];
        [_videoSlider setThumbImage:EOExportUIImage(@"eo_export_slider") forState:UIControlStateHighlighted];
        _videoSlider.value = 0;
        _videoSlider.minimumTrackTintColor = [UIColor clearColor];
        _videoSlider.maximumTrackTintColor = [UIColor clearColor];
        [_videoSlider addTarget:self action:@selector(onSliderValueChanged:)
                forControlEvents:UIControlEventValueChanged];
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(fontSliderTapped:)];
        [_videoSlider addGestureRecognizer:pan];
    }
    return _videoSlider;
}

- (void)setVideoSliderValue:(CGFloat)value {
    self.videoSlider.value = value;
}

- (void)onSliderValueChanged:(UISlider *)sender {
    if ([self.delegate respondsToSelector:@selector(updatePreviewCurrentTimeWithRatio:)]) {
        [self.delegate updatePreviewCurrentTimeWithRatio:sender.value];
    }
}

- (void) fontSliderTapped:(UITapGestureRecognizer *)tapGesture {
    CGPoint touchPoint = [tapGesture locationInView:self.videoSlider];
    CGFloat value = (self.videoSlider.maximumValue - self.videoSlider.minimumValue) * (touchPoint.x / self.videoSlider.frame.size.width );
    if (value>1) {
        value = 1;
    }
    else if (value < 0) {
        value = 0;
    }
    [self.videoSlider setValue:value animated:YES];
    if ([self.delegate respondsToSelector:@selector(updatePreviewCurrentTimeWithRatio:)]) {
        [self.delegate updatePreviewCurrentTimeWithRatio:value];
    }
}

#pragma mark - UICollectionView

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.frames count];
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    EOVideoCoverVideoFramePickerItem *cell = [collectionView dequeueReusableCellWithReuseIdentifier:EOVideoCoverVideoFramePickerIdentifier forIndexPath:indexPath];
    UIImage *image = self.frames[indexPath.row];
    cell.imageView.image = image;
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(self.itemWidth, 25);
}

@end
