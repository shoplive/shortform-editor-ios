//
//  EOVideoEditorViewControllerConfigInitializer.h
//  EOEasyEditorUI
//
//    2023/11/9.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class EOEditorSideBarConfig;

@interface EOVideoEditorViewControllerConfigInitializer : NSObject

/// Right side bar config.
@property (nonatomic, strong) EOEditorSideBarConfig *sideBarConfig;

@property (nonatomic, copy) NSString *musicPanelKey;
@property (nonatomic, copy) NSString *textPanelKey;
@property (nonatomic, copy) NSString *infoStickerPanelKey;
@property (nonatomic, copy) NSString *filterPanelKey;
@property (nonatomic, copy) NSString *videoEffectPanelKey;
@property (nonatomic, copy) NSString *effectStickerPanelKey;
@property (nonatomic, copy) NSString *voicePanelKey;
@property (nonatomic, copy) NSString *soundPanelKey;
@property (nonatomic, copy) NSString *transitionPanelKey;
@property (nonatomic, copy) NSString *trackMusicPanelKey;

@end

#pragma mark - EOEditorSideBarConfig

typedef NSString * const EOEditorBarItemKey NS_STRING_ENUM;

FOUNDATION_EXPORT EOEditorBarItemKey EOEditorBarItemKeyClip;
FOUNDATION_EXPORT EOEditorBarItemKey EOEditorBarItemKeyText;
FOUNDATION_EXPORT EOEditorBarItemKey EOEditorBarItemKeySticker;
FOUNDATION_EXPORT EOEditorBarItemKey EOEditorBarItemKeyFilter;
FOUNDATION_EXPORT EOEditorBarItemKey EOEditorBarItemKeyEffect;
FOUNDATION_EXPORT EOEditorBarItemKey EOEditorBarItemKeyVoice;
FOUNDATION_EXPORT EOEditorBarItemKey EOEditorBarItemKeyFaceSticker;

@interface EOEditorSideBarConfig : NSObject

/// Array of keys that presenting right side bar items.
/// Could change the order. Custom new items not supported yet.
/// default order: [ 
///     EOEditorBarItemKeyClip,
///     EOEditorBarItemKeyText,
///     EOEditorBarItemKeySticker,
///     EOEditorBarItemKeyFilter,
///     EOEditorBarItemKeyEffect,
///     EOEditorBarItemKeyFaceSticker,
///     EOEditorBarItemKeyVoice
/// ]
@property (nonatomic, strong) NSMutableArray<EOEditorBarItemKey> *itemKeys;

/// The number of side bar items that would not be folded,
/// count from the first object of `itemKeys`
/// default is `5`
@property (nonatomic, assign) NSUInteger unfoldCount;

@end


NS_ASSUME_NONNULL_END
