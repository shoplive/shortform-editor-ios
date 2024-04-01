//
//  EOResourcePickerProtocol.h
//  EOBaseKit_Core
//
//    2023/11/30.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@protocol EOMediaAssetProtocol;
typedef void (^EOResourcePickerCompletion)(NSArray<id<EOMediaAssetProtocol>> *resources,
                                            NSError * _Nullable error,
                                            BOOL cancel);

@protocol EOResourcePickerProtocol <NSObject>

@required
- (void)pickResourcesWithMaxSelectedCount:(NSUInteger)maxSelectedCount
                               completion:(EOResourcePickerCompletion)completion;
- (void)pickResourcesWithCompletion:(EOResourcePickerCompletion)completion;
- (void)pickResourcesFromRecorderWithCompletion:(EOResourcePickerCompletion)completion;
- (void)pickSingleResourceWithCompletion:(EOResourcePickerCompletion)completion;
- (void)pickSingleImageResourceWithCompletion:(EOResourcePickerCompletion)completion;
- (void)pickSingleCropImageResourceWithCompletion:(EOResourcePickerCompletion)completion;
- (void)pickSingleResourceWithLimitDuration:(NSInteger)duration completion:(EOResourcePickerCompletion)completion;

@end

NS_ASSUME_NONNULL_END
