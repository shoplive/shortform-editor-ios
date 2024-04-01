//
//  EOResourceParam.h
//  EOBaseKit_Core
//
//    2023/12/20.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface EOCommonResourceParam : NSObject

@property(nonatomic, copy) NSString *path;
- (instancetype)initWithPath:(NSString *)path;

@end

@interface EOMusicResourceParam : EOCommonResourceParam

@property(nonatomic, copy) NSString *duration;
@property(nonatomic, copy) NSString *author;
- (instancetype)initWithPath:(NSString *)path author:(NSString *)author duration:(NSString *)duration;

@end

@interface EOBeautyResourceParam : EOCommonResourceParam

@property(nonatomic, copy) NSString *key;
@property(nonatomic, assign) NSInteger intensity;
@property(nonatomic, strong) NSArray *range;
- (instancetype)initWithPath:(NSString *)path key:(NSString *)key intensity:(NSInteger)intensity range:(NSArray *)range;

@end

@interface EOFilterResourceParam : EOCommonResourceParam

@property(nonatomic, assign) NSInteger intensity;
@property(nonatomic, strong) NSArray *range;
- (instancetype)initWithPath:(NSString *)path intensity:(NSInteger)intensity range:(NSArray *)range;

@end

@interface EOTransitionResourceParam : EOCommonResourceParam

@property(nonatomic, assign) BOOL overlap;
- (instancetype)initWithPath:(NSString *)path overlap:(BOOL)overlap;

@end

NS_ASSUME_NONNULL_END
