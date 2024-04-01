//
//  EOSDKConfigInitializer.h
//  EOEasyEditorUI
//
//    2023/11/9.
//

#import <Foundation/Foundation.h>
NS_ASSUME_NONNULL_BEGIN

@class EOVideoEditorViewControllerConfigInitializer;

@interface EOEditorConfigInitializer : NSObject

- (void)configVideoEditorViewController:(void (^ _Nonnull)(EOVideoEditorViewControllerConfigInitializer * _Nonnull))block;

@end

NS_ASSUME_NONNULL_END
