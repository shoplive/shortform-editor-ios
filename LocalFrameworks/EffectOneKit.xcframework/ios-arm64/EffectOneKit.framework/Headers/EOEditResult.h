//
//  EOEditResult.h
//  EOEasyEditorUI
//
//    2024/1/5.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface EOEditResult : NSObject

@property (nonatomic, copy) NSString *filePath;
@property (nonatomic, strong) UIImage *coverImage;

@end

NS_ASSUME_NONNULL_END
