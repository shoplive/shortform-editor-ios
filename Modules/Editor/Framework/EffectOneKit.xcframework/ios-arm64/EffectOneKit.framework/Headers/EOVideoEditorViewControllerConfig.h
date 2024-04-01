//
//  EOVideoEditorViewControllerConfig.h
//  EOEasyEditorUI
//
//    2023/11/6.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class EOEditorSideBarConfig;
@class EOVideoEditorViewControllerConfigInitializer;

@interface EOVideoEditorViewControllerConfig : NSObject

@property (nonatomic, strong, readonly) EOEditorSideBarConfig *sideBarConfig;

@property (nonatomic, copy, readonly) NSString *musicPanelKey;
@property (nonatomic, copy, readonly) NSString *textPanelKey;
@property (nonatomic, copy, readonly) NSString *infoStickerPanelKey;
@property (nonatomic, copy, readonly) NSString *filterPanelKey;
@property (nonatomic, copy, readonly) NSString *videoEffectPanelKey;
@property (nonatomic, copy, readonly) NSString *effectStickerPanelKey;
@property (nonatomic, copy, readonly) NSString *voicePanelKey;
@property (nonatomic, copy, readonly) NSString *soundPanelKey;
@property (nonatomic, copy, readonly) NSString *transitionPanelKey;
@property (nonatomic, copy, readonly) NSString *trackMusicPanelKey;

- (instancetype)initWith:(EOVideoEditorViewControllerConfigInitializer *)initializer;

@end

NS_ASSUME_NONNULL_END
