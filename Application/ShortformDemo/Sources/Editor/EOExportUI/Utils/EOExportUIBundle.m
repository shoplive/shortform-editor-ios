//
//  EOExportUIBundle.m
//  EOExportUI-EOExportUI
//
//

#import "EOExportUIBundle.h"

@implementation EOExportUIBundle

+ (NSBundle *)resourceBundle {    return [NSBundle mainBundle];
}

+ (UIImage *)resourceBundleImage:(NSString *)img {
    return [UIImage imageNamed:img];
}


@end
