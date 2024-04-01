//
//  EOPopSelectView.m
//  EOEasyEditorUI
//
//

#import "EOPopSelectView.h"
#import "EOPopSelectItem.h"

@interface EOPopSelectView () <
UICollectionViewDataSource,
UICollectionViewDelegateFlowLayout,
UIGestureRecognizerDelegate
>

@property (nonatomic, strong) UICollectionView *collectView;
@property (nonatomic, copy) NSArray <NSString *>*dataSourceArr;
@property (nonatomic, copy) void(^completBlock)(NSInteger selectIndex);
@property (nonatomic, copy) void(^selectBlock)(NSInteger selectIndex);

@end

@implementation EOPopSelectView

- (instancetype)initWithFrame:(CGRect)frame
                   dataSource:(NSArray<NSString *> *)dataSourceArr
           defaultSelectIndex:(NSInteger)index
                  SelectBlock:(void (^)(NSInteger))selectBlock
{
    self = [super initWithFrame:frame];
    if (self) {
        _selectBlock = selectBlock;
        _dataSourceArr = dataSourceArr;
        [self buildBaseLayout];
        [self setupCollectViewSelectIndex:index];
    }
    return self;
}

- (void)buildBaseLayout
{
    [self addSubview:self.collectView];
    [self.collectView reloadData];
}

- (void)setupCollectViewSelectIndex:(NSInteger)index
{
    [self.collectView setAllowsSelection:YES];
    [self.collectView selectItemAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] animated:YES scrollPosition:UICollectionViewScrollPositionNone];
}

#pragma mark - setter & getter

- (UICollectionView *)collectView
{
    if (!_collectView) {
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    
        _collectView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 60) collectionViewLayout:flowLayout];
        _collectView.showsHorizontalScrollIndicator = NO;
        _collectView.showsVerticalScrollIndicator = NO;
        _collectView.delegate = self;
        _collectView.dataSource = self;
        _collectView.layer.cornerRadius = 6;
        _collectView.clipsToBounds = YES;
        _collectView.backgroundColor = [UIColor clearColor];
        
        if (@available(iOS 11.0, *)) {
            _collectView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        } else {
        }
        [_collectView registerClass:[EOPopSelectItem class] forCellWithReuseIdentifier:EOPopSelectItem.description];
    }
    return _collectView;
}

- (void)setDataSourceArr:(NSArray *)dataSourceArr
{
    _dataSourceArr = dataSourceArr;
    [self.collectView reloadData];
}

#pragma mark -- UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.dataSourceArr.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    EOPopSelectItem *cell = [collectionView dequeueReusableCellWithReuseIdentifier:EOPopSelectItem.description forIndexPath:indexPath];
    NSString *title = self.dataSourceArr[indexPath.row];
    if (title.length > 0) {
        cell.titleLable.text = title;
    }
    return cell;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return self.dataSourceArr.count > 0 ? 1 : 0;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

#pragma mark -- UICollectionViewDelegate

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake((self.frame.size.width-36)/4, 36);
}


- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(0, 0, 0, 0);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 12;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 12;
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    return CGSizeZero;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section
{
    return CGSizeMake(0, 0);
}

#pragma mark -- UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if(self.selectBlock){
        self.selectBlock(indexPath.row);
    }
}

@end

