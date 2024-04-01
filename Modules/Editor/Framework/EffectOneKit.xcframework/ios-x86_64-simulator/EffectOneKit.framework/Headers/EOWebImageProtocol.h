//
//  EOWebImageProtocol.h
//  EOEasyRecorderUI
//
//

#ifndef EOWebImageProtocol_h
#define EOWebImageProtocol_h

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol EOWebImageProtocol <NSObject>

- (void)imageView:(UIImageView *)imageView setImageWithURL:(NSURL *_Nullable)imageURL;

- (void)imageView:(UIImageView *_Nullable)imageView
  setImageWithURL:(NSURL *_Nullable)imageUrl
      placeholder:(UIImage *_Nullable)placeholder;

- (void)imageView:(UIImageView *_Nullable)imageView
  setImageWithURL:(NSURL *_Nullable)imageUrl
      placeholder:(UIImage *_Nullable)placeholder
        completed:(void(^)(UIImage *_Nullable))completed;


- (void)button:(UIButton *)button setImageWithURL:(nullable NSURL *)url forState:(UIControlState)state;
- (void)button:(UIButton *)button setImageWithURL:(nullable NSURL *)url forState:(UIControlState)state placeholderImage:(nullable UIImage *)placeholder;

- (nullable UIImage *)imageWithGIFData:(nullable NSData *)data;
@end

NS_ASSUME_NONNULL_END

#endif /* EOWebImageProtocol_h */
