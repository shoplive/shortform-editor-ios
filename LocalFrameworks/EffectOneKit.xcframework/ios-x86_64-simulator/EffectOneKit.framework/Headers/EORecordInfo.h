//
//  EORecordInfo.h
//  EOEasyRecorderUI
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@protocol EOMediaAssetProtocol;
@protocol EOResourceProtocol;

typedef NS_ENUM(NSUInteger, EORecordInfoSource) {
    EORecordInfoSourceCamera = 0,
    EORecordInfoSourceAlbum = 1,
};

@interface EORecordInfo : NSObject

@property (nonatomic, copy) NSArray<id<EOMediaAssetProtocol>> *mediaAssets;

@property (nonatomic, strong, nullable) id<EOResourceProtocol> backgroundMusic;

@property (nonatomic, assign) EORecordInfoSource source;

@property (nonatomic, strong, nullable) UIImage *coverImage;

@end

NS_ASSUME_NONNULL_END
