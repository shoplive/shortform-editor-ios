//
//  UIImage+EOExportUI.h
//  EOExportUI
//
//

#import <UIKit/UIKit.h>
#import <AVKit/AVKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImage (EOExportUI)

/// {zh}  生成颜色图 {en} Generate color map
/// @param color {zh} 颜色值 {en} color value
/// @param size {zh} 尺寸 {en} size
+ (UIImage *)eo_imageWithColor:(UIColor *)color size:(CGSize)size;
+ (UIImage *)eo_imageWithClipImage:(UIImage *)image;
+ (UIImage *)eo_imageNamed:(NSString *)name bundleName:(NSString *)bundleName;

/// {zh}  生成颜色图 {en} Generate color map
/// @param color {zh} 颜色值 {en} color value
- (UIImage *)eo_imageWithColor:(UIColor *)color;

/// {zh}  加载asset资源图片 {en} Load asset resource image
/// {zh}  若需要获取与预览区展示一致的图片，可参考 AVAsset+UIImage.h 里的方法 {en} If you need to get the same picture as the preview area display, you can refer to the method in AVAsset + UIImage.h
/// @param asset {zh} asset对象 {en} asset object
/// @param maxSize {zh} 最长边限制 {en} longest side limit
/// @param time {zh} 时间戳 {en}  timestamp
+ (UIImage *)eo_image:(AVAsset *)asset maxSize:(CGSize)maxSize time:(CMTime)time;


/// {zh}  重新生成指定尺寸图片对象 {en} Regenerate the image object of the specified size
/// @param reSize {zh} 新尺寸 {en}  new size
- (UIImage *)eo_imageWithNewSize:(CGSize)reSize;

///  Returns a new image which is scaled from this image.
///  The image will be stretched as needed.
/// @param size  The new size to be scaled, values should be positive.
/// @param contentMode The new image with the given size.
- (UIImage *)eo_imageByResizeToSize:(CGSize)size
                         contentMode:(UIViewContentMode)contentMode;

///  Draws the entire image in the specified rectangle, content changed with
///  the contentMode.
/// @param rect The rectangle in which to draw the image.
/// @param contentMode Draw content mode
/// @param clips A Boolean value that determines whether content are confined to the rect.
- (void)eo_drawInRect:(CGRect)rect
       withContentMode:(UIViewContentMode)contentMode
         clipsToBounds:(BOOL)clips;

/// {zh}  生成过滤透明度图片 {en} Generate filter transparency image
- (UIImage *)eo_imageWithoutAlpha;

/// {zh}  是否含有透明度 {en} Whether it contains transparency
- (BOOL)eo_hasAlpha;

/// {zh}  根据图片文件数据生成图片对象 {en} Generate image objects from image file data
/// @param data {zh} 图片文件数据 {en} image file data
/// @param scale {zh} 缩放比例 {en}  scale
/// @param maxSize {zh} 最长边限制 {en} longest side limit
/// @return {zh} 静态图/动图 {en}  static image/gif image

+ (UIImage *)eo_imageWithData:(NSData *)data scale:(CGFloat)scale maxSize:(CGFloat)maxSize;

/// {zh}  图片文件转NSData，默认以jpeg类型转NSData，gif图片文件不适用 {en} Image file to NSData, default to jpeg type to NSData, gif image file is not applicable
- (NSData *)eo_imageToData;

/// {zh}  角度修正 {en} Angle correction
- (UIImage *)eo_fixOrientation;

/// {zh}  获取原图正向尺寸 {en} Get the forward size of the original image
- (CGSize)eo_origialImageSize;

/// {zh} 根据图片旋转方向调整rect {en} Adjust the rect according to the rotation direction of the picture
- (CGRect)eo_fixCropRectWithRect:(CGRect)rect;

/// {zh}  图片裁剪 {en} image cropping
- (nullable UIImage *)eo_croppedImageWithRect:(CGRect)rect;
- (uint32_t)eo_ARGBAtPixel:(CGPoint)point;

@end

NS_ASSUME_NONNULL_END
