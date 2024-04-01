//
//  EOMediaAssetProtocol.h
//  EOBaseKit_Core
//
//

#ifndef EOMediaAssetProtocol_h
#define EOMediaAssetProtocol_h

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, EOMediaAssetType) {
    EOMediaAssetTypeUnknown   = 0,
    EOMediaAssetTypeVideo     = 1,
    EOMediaAssetTypeImage     = 2,
    EOMediaAssetTypeLivePhoto = 3,
    EOMediaAssetTypeGIf       = 4,
    EOMediaAssetTypeAudio     = 5,
};

@protocol EOMediaAssetProtocol <NSObject>

@property (nonatomic, assign) EOMediaAssetType type;

@property (nonatomic, strong, nullable) NSURL *URL;

@property (nonatomic, strong, nullable) UIImage *image;

@property (nonatomic, strong, nullable) NSData *imageData;

@property (nonatomic, assign) BOOL isGIFImage;

@property (nonatomic, assign) CMTime imageDuration;

@property (nonatomic, assign) float videoSpeed;

@property (nonatomic, strong, nullable) AVURLAsset *videoAsset;

@property (nonatomic, copy, nullable) NSString *assetName;

@end

NS_ASSUME_NONNULL_END


#endif /* EOMediaAssetProtocol_h */
