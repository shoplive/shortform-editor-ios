//
//  EOExportManager.h
//  EOEasyEditor
//
//    2024/1/11.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN
@class EOExportModel;
@interface EOExportManager : NSObject

- (instancetype)initWithExportModel:(EOExportModel *)model;

//获取封面图
- (void)getVideoCoverImage:(CGSize)videoSize success:(nullable void(^)(UIImage *draftImg, UIImage *videoImg, int64_t videoFrameTime, NSString *coverType))completionBlock;
//设置canvasSize
- (void)setCanvasSize;
//设置preview
- (void)resetPlayeView:(UIView *)preview;
//暂停视频
- (void)pause;
//设置视频到指定时间
- (void)setVideoRatioTime:(int64_t)videoFrameTime isSmooth:(BOOL)isSmooth;
//获取视频分辨率
- (CGSize)getVideoSize;
//导出视频
- (void)exportVideoWithProgress:(void (^_Nullable )(CGFloat progress))progressBlock resultBlock:(void (^)(NSError *error,id result))exportBlock;
//取消导出
- (void)cancelExport;
//保存封面图片
- (void)saveCoverImage:(UIImage *)coverImg time:(int64_t)videoFrameTime canvasType:(int)type;
//获取FPS数组
- (NSArray *)exportFPSTitleArr;
//获取分辨率数组
- (NSArray *)exportPresentTitleArr;
//设置FPS
- (void)setExportFPSSelectIndex:(NSInteger)index;
//设置分辨率
- (void)setExportPresentSelectIndex:(NSInteger)index;
//视频抽帧（单帧）
- (void)getProcessedPreviewImageAtTime:(NSTimeInterval)atTime
                         preferredSize:(CGSize)size
                           isLastImage:(BOOL)isLastImage
                           compeletion:(void (^)(UIImage *image, NSTimeInterval atTime))compeletion;
//视频抽帧（多帧）
- (void)getPreviewImages:(NSArray *)atTimes
           preferredSize:(CGSize)size
              withEffect:(BOOL)withEffect
              frameBlock:(void (^)(UIImage *image, NSTimeInterval atTime))frameBlock;
//视频抽帧（当前帧）
- (UIImage *)capturePreviewUIImage;
//获取视频总时长
- (NSTimeInterval)totalVideoDuration;
//从EO相册选取照片，只能选取单张
- (void)getPickSingleImageResourceWithCompletion:(nullable void(^)(NSURL * _Nullable pickImage, NSError * _Nullable error, BOOL cancel))completionBlock;
//获取主轨时长
- (CGFloat)mainTrackMaxEnd;
//导出是否添加封面
- (void)shouldAddCover:(BOOL)isCover;
//是否添加水印
- (void)shouldAddWaterMark:(BOOL)shouldAddWaterMark;
//设置水印图片
- (void)addWaterMarkImage:(UIImage *)waterMarkImage;
//设置水印大小（720为标准）,waterMarkSize为计算后的值，计算方式：当前视频分辨率/720*size的宽高
- (void)setWaterMarkSize:(CGSize)waterMarkSize;
//图片裁剪页面
- (void)pushCropVC:(UIViewController *)vc imagePath:(NSString *)imagePath Completion:(nullable void(^)(NSString *imagePath))completionBlock;
//设置画布颜色（默认黑色）
- (void)setCanvasColor:(UIColor *)color;

@end

NS_ASSUME_NONNULL_END
