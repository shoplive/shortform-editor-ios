//
//  EOExportModel.h
//  EOEasyEditor
//
//    2024/1/17.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface EOExportModel : NSObject

@property (nonatomic, copy) NSString *draftId;
@property (nonatomic, copy) NSString *nleJson;
@property (nonatomic) CGSize originRatioSize;
@property (nonatomic) NSTimeInterval totalVideoDuration;
@property (nonatomic, copy) void (^willExport)(void);
@property (nonatomic, copy) void (^didExport)(void);

@property (nonatomic, copy) void (^onDismiss)(UIImage * _Nullable coverImage, int64_t videoFrameTime, int type);

@end

NS_ASSUME_NONNULL_END
