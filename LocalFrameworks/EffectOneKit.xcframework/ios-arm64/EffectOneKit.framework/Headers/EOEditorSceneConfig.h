//
//  EOEditorSceneConfig.h
//  EOEasyEditorUI
//
//    2023/12/1.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, EOEditorPreviewContentMode) {
    EOEditorPreviewContentModeAspectFit = 0,
    EOEditorPreviewContentModeAspectFill = 1,
};

@class EOSDKDraftModel;
@protocol EOMediaAssetProtocol;
@protocol EOResourceProtocol;

@interface EOEditorSceneConfig : NSObject

/// Restore from draft
@property (nonatomic, strong) EOSDKDraftModel *draftModel;

/// Resources from Recorder or Album
@property (nonatomic, copy) NSArray<id<EOMediaAssetProtocol>> *resources;

/// Selected BGM Resource from Recorder
@property (nonatomic, strong, nullable) id<EOResourceProtocol> backgroundMusic;

/// First resource thumbnail from Recorder
@property (nonatomic, strong, nullable) UIImage *coverImage;

/// Default is `EOEditorPreviewContentModeAspectFit`
@property (nonatomic, assign) EOEditorPreviewContentMode previewContentMode;

/// Reserved field, can be ignored
@property (nonatomic, copy) NSString *fromType;

@end

NS_ASSUME_NONNULL_END
