//
//  UIImage+EOExportUI.m
//  EOExportUI
//
//

#import "UIImage+EOExportUI.h"
#import <MobileCoreServices/MobileCoreServices.h>

@implementation UIImage (EOExportUI)

+ (UIImage *)eo_imageWithColor:(UIColor *)color size:(CGSize)size
{
    if (!color || size.width <= 0 || size.height <= 0) {
        return nil;
    }
    CGRect rect = CGRectMake(0.0f, 0.0f, size.width, size.height);
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, color.CGColor);
    CGContextFillRect(context, rect);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

+ (UIImage *)eo_imageWithClipImage:(UIImage *)image {
    UIGraphicsBeginImageContextWithOptions(image.size, NO, 0);
    UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(0, 0, image.size.width, image.size.height)];
    [path addClip];
    [image drawAtPoint:CGPointZero];
    UIImage *newImage =  UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

- (UIImage *)eo_imageWithColor:(UIColor *)color
{
    if (!color) {
        return nil;
    }

    UIImage *newImage = nil;

    CGRect imageRect = (CGRect){CGPointZero,self.size};
    UIGraphicsBeginImageContextWithOptions(imageRect.size, NO, self.scale);

    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextTranslateCTM(context, 0.0, -(imageRect.size.height));

    CGContextClipToMask(context, imageRect, self.CGImage);// {zh} 选中选区 获取不透明区域路径 {en} Select the selection to get the path of the opaque area
    CGContextSetFillColorWithColor(context, color.CGColor);// {zh} 设置颜色 {en} Set color
    CGContextFillRect(context, imageRect);// {zh} 绘制 {en} Draw

    newImage = UIGraphicsGetImageFromCurrentImageContext();// {zh} 提取图片 {en} Extract image
    UIGraphicsEndImageContext();
    return newImage;
}

+ (UIImage *)eo_imageNamed:(NSString *)name bundleName:(NSString *)bundleName {
    NSBundle *bundle = [NSBundle bundleWithPath:[NSBundle.mainBundle.bundlePath stringByAppendingString:[NSString stringWithFormat:@"/%@.bundle", bundleName]]];
    UIImage *image = [UIImage imageNamed:name inBundle:bundle compatibleWithTraitCollection:nil];
    return image;
}

+ (UIImage *)eo_image:(AVAsset *)asset maxSize:(CGSize)maxSize time:(CMTime)time
{
    AVAssetImageGenerator *gen = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    //  {zh} 设定缩略图的方向，如果不设定，可能会在视频旋转90/180/270°时，获取到的缩略图是被旋转过的，而不是正向的。  {en} Set the direction of the thumbnail. If you don't set it, the obtained thumbnail may be rotated instead of forward when the video is rotated 90/180/270 °.
    gen.appliesPreferredTrackTransform = YES;
    //  {zh} 设置图片的最大size(分辨率)  {en} Set the maximum size (resolution) of the image
    gen.maximumSize = maxSize;
    NSError *error = nil;
    CMTime actualTime;
    CGImageRef image = [gen copyCGImageAtTime:time actualTime:&actualTime error:&error];
    if (error) {
        return nil;
    }
    UIImage *thumb = [[UIImage alloc] initWithCGImage:image];
    CGImageRelease(image);
    return thumb;
}

- (UIImage *)eo_imageWithNewSize:(CGSize)reSize
{
    UIGraphicsBeginImageContext(CGSizeMake(reSize.width, reSize.height));
    [self drawInRect:CGRectMake(0, 0, reSize.width, reSize.height)];
    UIImage *eo_imageWithNewSize = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return eo_imageWithNewSize;
}

- (UIImage *)eo_imageByResizeToSize:(CGSize)size
                         contentMode:(UIViewContentMode)contentMode {
    if (size.width <= 0 || size.height <= 0) return nil;
    UIGraphicsBeginImageContextWithOptions(size, NO, self.scale);
    [self eo_drawInRect:CGRectMake(0, 0, size.width, size.height) withContentMode:contentMode clipsToBounds:NO];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (void)eo_drawInRect:(CGRect)rect
       withContentMode:(UIViewContentMode)contentMode
         clipsToBounds:(BOOL)clips {
    CGRect drawRect = _EOCGRectFitWithContentMode(rect, self.size, contentMode);
    if (drawRect.size.width == 0 || drawRect.size.height == 0) return;
    if (clips) {
        CGContextRef context = UIGraphicsGetCurrentContext();
        if (context) {
            CGContextSaveGState(context);
            CGContextAddRect(context, rect);
            CGContextClip(context);
            [self drawInRect:drawRect];
            CGContextRestoreGState(context);
        }
    } else {
        [self drawInRect:drawRect];
    }
}


/**
 Resize rect to fit the size using a given contentMode.
 
 @param rect The draw rect
 @param size The content size
 @param mode The content mode
 @return A resized rect for the given content mode.
 @discussion UIViewContentModeRedraw is same as UIViewContentModeScaleToFill.
 */
static CGRect _EOCGRectFitWithContentMode(CGRect rect, CGSize size, UIViewContentMode mode) {
    rect = CGRectStandardize(rect);
    size.width = size.width < 0 ? -size.width : size.width;
    size.height = size.height < 0 ? -size.height : size.height;
    CGPoint center = CGPointMake(CGRectGetMidX(rect), CGRectGetMidY(rect));
    switch (mode) {
        case UIViewContentModeScaleAspectFit:
        case UIViewContentModeScaleAspectFill: {
            if (rect.size.width < 0.01 || rect.size.height < 0.01 ||
                size.width < 0.01 || size.height < 0.01) {
                rect.origin = center;
                rect.size = CGSizeZero;
            } else {
                CGFloat scale;
                if (mode == UIViewContentModeScaleAspectFit) {
                    if (size.width / size.height < rect.size.width / rect.size.height) {
                        scale = rect.size.height / size.height;
                    } else {
                        scale = rect.size.width / size.width;
                    }
                } else {
                    if (size.width / size.height < rect.size.width / rect.size.height) {
                        scale = rect.size.width / size.width;
                    } else {
                        scale = rect.size.height / size.height;
                    }
                }
                size.width *= scale;
                size.height *= scale;
                rect.size = size;
                rect.origin = CGPointMake(center.x - size.width * 0.5, center.y - size.height * 0.5);
            }
        } break;
        case UIViewContentModeCenter: {
            rect.size = size;
            rect.origin = CGPointMake(center.x - size.width * 0.5, center.y - size.height * 0.5);
        } break;
        case UIViewContentModeTop: {
            rect.origin.x = center.x - size.width * 0.5;
            rect.size = size;
        } break;
        case UIViewContentModeBottom: {
            rect.origin.x = center.x - size.width * 0.5;
            rect.origin.y += rect.size.height - size.height;
            rect.size = size;
        } break;
        case UIViewContentModeLeft: {
            rect.origin.y = center.y - size.height * 0.5;
            rect.size = size;
        } break;
        case UIViewContentModeRight: {
            rect.origin.y = center.y - size.height * 0.5;
            rect.origin.x += rect.size.width - size.width;
            rect.size = size;
        } break;
        case UIViewContentModeTopLeft: {
            rect.size = size;
        } break;
        case UIViewContentModeTopRight: {
            rect.origin.x += rect.size.width - size.width;
            rect.size = size;
        } break;
        case UIViewContentModeBottomLeft: {
            rect.origin.y += rect.size.height - size.height;
            rect.size = size;
        } break;
        case UIViewContentModeBottomRight: {
            rect.origin.x += rect.size.width - size.width;
            rect.origin.y += rect.size.height - size.height;
            rect.size = size;
        } break;
        case UIViewContentModeScaleToFill:
        case UIViewContentModeRedraw:
        default: {
            rect = rect;
        }
    }
    return rect;
}


- (BOOL)eo_hasAlpha
{
    CGImageAlphaInfo alpha = CGImageGetAlphaInfo(self.CGImage);
    return (alpha == kCGImageAlphaFirst ||
            alpha == kCGImageAlphaLast ||
            alpha == kCGImageAlphaPremultipliedFirst ||
            alpha == kCGImageAlphaPremultipliedLast);
}

- (UIImage *)eo_imageWithoutAlpha
{
    if (![self eo_hasAlpha]) {
        return self;
    }

    CGImageRef imageRef = self.CGImage;
    size_t width = CGImageGetWidth(imageRef);
    size_t height = CGImageGetHeight(imageRef);
    uint32_t bitmapInfo = 0;
    uint32_t byteOrderInfo = CGImageGetBitmapInfo(imageRef) & kCGBitmapByteOrderMask;
    if (CGImageGetAlphaInfo(imageRef) == kCGImageAlphaFirst
        || CGImageGetAlphaInfo(imageRef) == kCGImageAlphaPremultipliedFirst) {
        bitmapInfo = kCGImageAlphaNoneSkipFirst | byteOrderInfo;
    } else {
        bitmapInfo = kCGImageAlphaNoneSkipLast | byteOrderInfo;
    }
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef offscreenContext = CGBitmapContextCreate(NULL,
                                                          width,
                                                          height,
                                                          CGImageGetBitsPerComponent(imageRef),
                                                          CGImageGetBytesPerRow(imageRef),
                                                          colorSpace,
                                                          bitmapInfo);

    CGContextDrawImage(offscreenContext, CGRectMake(0, 0, width, height), imageRef);
    CGImageRef imageRefWithoutAlpha = CGBitmapContextCreateImage(offscreenContext);
    UIImage *imageWithoutAlpha = [UIImage imageWithCGImage:imageRefWithoutAlpha];

    CGContextRelease(offscreenContext);
    CGImageRelease(imageRefWithoutAlpha);
    CGColorSpaceRelease(colorSpace);
    
    return imageWithoutAlpha;
}

/** {zh}
 初始化UIImage动图

 @param data gif资源
 @param scale 缩放比例
 @return UIImage动图
 */
/** {en}
 Initialize UIImage animation

 @param data gif resources
 @param scale scale
 @return scale
 */
+ (UIImage *)eo_imageWithData:(NSData *)data scale:(CGFloat)scale maxSize:(CGFloat)maxSize{
    if (!data) {
        return nil;
    }
    CGImageSourceRef source = CGImageSourceCreateWithData((__bridge CFDataRef)data, NULL);
    size_t count = CGImageSourceGetCount(source);
    UIImage *animatedImage = nil;

    if (count <= 1) {
        CGSize imageSize = animatedImage.size;
        animatedImage = [[UIImage alloc] initWithData:data];
        // {zh} /当图片任意一边超过最大长度做等比缩放 {en} /When any side of the picture exceeds the maximum length, do equal scaling
        if(imageSize.width > maxSize){
            animatedImage = [animatedImage eo_imageWithNewSize:CGSizeMake(maxSize, imageSize.height * maxSize / imageSize.width)];
        }else if(imageSize.height > maxSize) {
            animatedImage = [animatedImage eo_imageWithNewSize:CGSizeMake(imageSize.width * maxSize / imageSize.height, maxSize)];
        }// {zh} /否则就不做处理 {en} /otherwise it will not be processed
    } else {
        NSMutableArray<UIImage *> *images = [[NSMutableArray alloc] init];
        NSTimeInterval duration = 0.0f;
        for (size_t i = 0; i < count; i++) {
            CGImageRef image = CGImageSourceCreateImageAtIndex(source, i, NULL);
            duration += [UIImage eo_frameDurationAtIndex:i source:source];
            UIImage *frameImage = [UIImage imageWithCGImage:image scale:scale orientation:UIImageOrientationUp];
            CGSize imageSize = frameImage.size;
            if(imageSize.width > maxSize){
                frameImage = [frameImage eo_imageWithNewSize:CGSizeMake(maxSize, imageSize.height * maxSize / imageSize.width)];
            }else if(imageSize.height > maxSize) {
                frameImage = [frameImage eo_imageWithNewSize:CGSizeMake(imageSize.width * maxSize / imageSize.height, maxSize)];
            }
            [images addObject:frameImage];
            CGImageRelease(image);
        }
        if (!duration) {
            duration = (1.0f / 10.0f) * count;
        }
        animatedImage = [UIImage animatedImageWithImages:images duration:duration];
    }
    CFRelease(source);
    return animatedImage;
}

/**
 The duration of the animation.
 */
+ (float)eo_frameDurationAtIndex:(NSUInteger)index source:(CGImageSourceRef)source {
    float frameDuration = 0.1f;
    CFDictionaryRef cfFrameProperties = CGImageSourceCopyPropertiesAtIndex(source, index, nil);
    NSDictionary<NSString *, NSDictionary *> *frameProperties = (__bridge NSDictionary *)cfFrameProperties;
    NSDictionary<NSString *, NSNumber *> *gifProperties = frameProperties[(NSString *)kCGImagePropertyGIFDictionary];
    NSNumber *delayTimeUnclampedProp = gifProperties[(NSString *)kCGImagePropertyGIFUnclampedDelayTime];
    if (delayTimeUnclampedProp) {
        frameDuration = [delayTimeUnclampedProp floatValue];
    } else {
        NSNumber *delayTimeProp = gifProperties[(NSString *)kCGImagePropertyGIFDelayTime];
        if (delayTimeProp) {
            frameDuration = [delayTimeProp floatValue];
        }
    }
    CFRelease(cfFrameProperties);
    return frameDuration;
}

- (NSData *)eo_imageToData {
    NSDictionary *options = @{(__bridge NSString *)kCGImageSourceShouldCache : @NO,
                              (__bridge NSString *)kCGImageSourceShouldCacheImmediately : @NO
                              };
    NSMutableData *data = [NSMutableData data];
    CGImageDestinationRef destRef = CGImageDestinationCreateWithData((__bridge CFMutableDataRef)data, kUTTypeJPEG, 1, (__bridge CFDictionaryRef)options);
    CGImageDestinationAddImage(destRef, self.CGImage, (__bridge CFDictionaryRef)options);
    CGImageDestinationFinalize(destRef);
    CFRelease(destRef);
    return data;
}

- (UIImage *)eo_fixOrientation
{
    
    // No-op if the orientation is already correct
    if (self.imageOrientation == UIImageOrientationUp) return self;
    
    // We need to calculate the proper transformation to make the image upright.
    // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (self.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width, self.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, self.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        case UIImageOrientationUp:
        case UIImageOrientationUpMirrored:
            break;
    }
    
    switch (self.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        case UIImageOrientationUp:
        case UIImageOrientationDown:
        case UIImageOrientationLeft:
        case UIImageOrientationRight:
            break;
    }
    
    // Now we draw the underlying CGImage into a new context, applying the transform
    // calculated above.
    CGContextRef ctx = CGBitmapContextCreate(NULL, self.size.width, self.size.height,
                                             CGImageGetBitsPerComponent(self.CGImage), 0,
                                             CGImageGetColorSpace(self.CGImage),
                                             CGImageGetBitmapInfo(self.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (self.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            // Grr...
            CGContextDrawImage(ctx, CGRectMake(0,0,self.size.height,self.size.width), self.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,self.size.width,self.size.height), self.CGImage);
            break;
    }
    
    // And now we just create a new UIImage from the drawing context
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
}

- (CGSize)eo_origialImageSize {
    CGSize size = self.size;
    if (self.imageOrientation == UIImageOrientationLeft ||
        self.imageOrientation == UIImageOrientationRight ||
        self.imageOrientation == UIImageOrientationLeftMirrored ||
        self.imageOrientation == UIImageOrientationRightMirrored) {
        size = CGSizeMake(size.height, size.width);
    }
    return size;
}

- (CGRect)eo_fixCropRectWithRect:(CGRect)rect {
    CGAffineTransform rectTransform;
    switch (self.imageOrientation) {
        case UIImageOrientationLeft:
            rectTransform = CGAffineTransformTranslate(CGAffineTransformMakeRotation(90 / 180.0f * M_PI), 0, -self.size.height);
            break;
        case UIImageOrientationRight:
            rectTransform = CGAffineTransformTranslate(CGAffineTransformMakeRotation(-90 / 180.0f * M_PI), -self.size.width, 0);
            break;
        case UIImageOrientationDown:
            rectTransform = CGAffineTransformTranslate(CGAffineTransformMakeRotation(-180 / 180.0f * M_PI), -self.size.width, -self.size.height);
            break;
        default:
            rectTransform = CGAffineTransformIdentity;
    };

    rectTransform = CGAffineTransformScale(rectTransform, self.scale, self.scale);
    CGRect transformedCropSquare = CGRectApplyAffineTransform(rect, rectTransform);
    return transformedCropSquare;
}

- (nullable UIImage *)eo_croppedImageWithRect:(CGRect)rect
{
    rect.origin.x *= self.scale;
    rect.origin.y *= self.scale;
    rect.size.width *= self.scale;
    rect.size.height *= self.scale;
    if (rect.size.width <= 0 || rect.size.height <= 0) return nil;
    
    CGImageRef imageRef = self.CGImage;
    if (!imageRef) {
        return nil;
    }
    
    CGImageRef croppedImageRef = CGImageCreateWithImageInRect(imageRef, rect);
    if (!croppedImageRef) {
        return nil;
    }

    UIImage *image = [[UIImage alloc] initWithCGImage:croppedImageRef scale:self.scale orientation:UIImageOrientationUp];
    CGImageRelease(croppedImageRef);
    return image;
}

- (uint32_t)eo_ARGBAtPixel:(CGPoint)point {
    UIImage *image = self;
    if (!CGRectContainsPoint(CGRectMake(0.0f, 0.0f, image.size.width, image.size.height), point)) {
        return 0;
    }

    // Create a 1x1 pixel byte array and bitmap context to draw the pixel into.
    NSInteger pointX = trunc(point.x);
    NSInteger pointY = trunc(point.y);
    CGImageRef cgImage = image.CGImage;
    NSUInteger width = image.size.width;
    NSUInteger height = image.size.height;
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    int bytesPerPixel = 4;
    int bytesPerRow = bytesPerPixel * 1;
    NSUInteger bitsPerComponent = 8;
    unsigned char pixelData[4] = { 0, 0, 0, 0 };
    CGContextRef context = CGBitmapContextCreate(pixelData, 1, 1, bitsPerComponent, bytesPerRow, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    CGColorSpaceRelease(colorSpace);
    CGContextSetBlendMode(context, kCGBlendModeCopy);

    // Draw the pixel we are interested in onto the bitmap context
    CGContextTranslateCTM(context, -pointX, pointY-(CGFloat)height);
    CGContextDrawImage(context, CGRectMake(0.0f, 0.0f, (CGFloat)width, (CGFloat)height), cgImage);
    CGContextRelease(context);

    CGFloat red   = (CGFloat)pixelData[0];// / 255.0f;
    CGFloat green = (CGFloat)pixelData[1];// / 255.0f;
    CGFloat blue  = (CGFloat)pixelData[2];// / 255.0f;
    CGFloat alpha = (CGFloat)pixelData[3];// / 255.0f;
    return alpha * pow(256, 3) + red * pow(256, 2) + green * pow(256, 1) + blue;
}

@end
