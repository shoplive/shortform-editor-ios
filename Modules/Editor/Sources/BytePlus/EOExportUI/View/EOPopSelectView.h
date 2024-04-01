//
//  EOPopSelectView.h
//  EOEasyEditorUI
//
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface EOPopSelectView : UIView

- (instancetype)initWithFrame:(CGRect)frame
                   dataSource:(NSArray<NSString *> *)dataSourceArr
           defaultSelectIndex:(NSInteger)index
                  SelectBlock:(void(^)(NSInteger selectIndex))completBlock;

- (void)setupCollectViewSelectIndex:(NSInteger)index;
@end

NS_ASSUME_NONNULL_END
