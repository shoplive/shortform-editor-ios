//
//  EOExport.h
//  Pods
//
//

#ifndef EOExport_h
#define EOExport_h

#import "EOExportUIBundle.h"

#define EOExportUILocalization(key)  NSLocalizedString(key, @"")
#define EOExportUIImage(key) [EOExportUIBundle resourceBundleImage:key]
#endif /* EOExport_h */
