//
//  EOSDKLogProtocol.h
//  EOEasyEditor
//
//    2023/11/1.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
typedef NS_ENUM(NSInteger, EOSDKLogType) {
    EOSDKLogTypeDebug = 0,
    EOSDKLogTypeInfo  = 1,
    EOSDKLogTypeWarn  = 2,
    EOSDKLogTypeError = 3,
    EOSDKLogTypeReport = 4,
};

@protocol EOSDKLogProtocol <NSObject>
/// {zh} 打印日志 {en} print log
/// @param msg {zh} 日志内容 {en} log content
/// @param type {zh} 日志类型 {en} log type
/// @param tag {zh} 日志标签 {en} log tag
/// @param filename {zh} 文件名称 {en}  filename
/// @param funcName {zh} 函数名称 {en} function name
/// @param line {zh} 行数 {en}  line number
- (void)logMsg:(NSString *)msg
           tag:(NSString *)tag
          type:(EOSDKLogType)type
      filename:(const char *)filename
      funcName:(const char *)funcName
          line:(int)line;

@optional
/// {zh}  埋点上报 {en} event tracking report
/// @param eventName {zh} 埋点名称 {en} event tracking name
/// @param params {zh} 埋点上报数据字典 {en}  params dict
- (void)logEvent:(NSString *)eventName
          params:(nullable NSDictionary *)params;

@end

NS_ASSUME_NONNULL_END
