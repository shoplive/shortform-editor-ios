//
//  EOPopSelectItem.m
//  EOEasyEditorUI
//
//

#import "EOPopSelectItem.h"
#import "EOExportUIHelper.h"

@implementation EOPopSelectItem

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self buildLayout];
    }
    return self;
}

- (void)buildLayout
{
    [self addSubview:self.titleLable];
    
    self.titleLable.center = CGPointMake(self.titleLable.center.x, self.frame.size.height * 0.5);
}

- (UILabel *)titleLable
{
    if (!_titleLable) {
        _titleLable = [[UILabel alloc] initWithFrame:CGRectMake(0, (self.frame.size.height-36)/2, self.frame.size.width, 36)];
        _titleLable.textColor = [EOExportUIHelper eo_colorWithHex:@"FFFFFF"];
        _titleLable.font = [EOExportUIHelper eo_export_pingFangRegular:13];
        _titleLable.textAlignment = NSTextAlignmentCenter;
        _titleLable.backgroundColor = [EOExportUIHelper eo_colorWithHex:@"FFFFFF" alpha:0.06];
        _titleLable.layer.cornerRadius = 6.0;
        _titleLable.layer.masksToBounds = YES;
    }
    
    return _titleLable;
}

-(void)setSelected:(BOOL)selected
{
    [super setSelected:selected];
    if (selected) {
        _titleLable.backgroundColor = [EOExportUIHelper eo_colorWithHex:@"FFFFFF" alpha:0.16];
        self.titleLable.layer.borderWidth=1.5f;
        self.titleLable.layer.cornerRadius=6.0f;
        self.titleLable.layer.borderColor = [[EOExportUIHelper eo_colorWithHex:@"0ECDEB"] CGColor];
        _titleLable.textColor = [EOExportUIHelper eo_colorWithHex:@"0ECDEB"];
    } else {
        _titleLable.backgroundColor = [EOExportUIHelper eo_colorWithHex:@"FFFFFF" alpha:0.06];
        self.titleLable.layer.borderWidth=0;
        _titleLable.layer.cornerRadius = 6.0;
        self.titleLable.layer.borderColor = [[UIColor clearColor] CGColor];
        _titleLable.textColor = [EOExportUIHelper eo_colorWithHex:@"FFFFFF"];

    }
}

@end

