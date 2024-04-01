//
//  EOSDKDraftService.h
//  EOEasyEditor
//
//    2023/10/26.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class EOSDKDraftModel;
@interface EOSDKDraftService : NSObject

/// nle: NLEInterface_OC
- (instancetype)initWithNLE:(id)nle;

/// {zh} 草稿根目录路径 {en} Draft root directory path
@property (nonatomic, copy, readonly) NSString *draftRootPath;

/// {zh} 当前编辑草稿路径 {en} Current edit draft path
@property (nonatomic, copy, readonly) NSString *currentDraftPath;

/// {zh}  是否自动保存 {en} Whether to save automatically
@property (nonatomic, assign, readonly) BOOL autoSave;

/// {zh} 当前草稿数据模型 {en} Current draft data model
- (EOSDKDraftModel *) draftModel;

/// {zh}  保存草稿对象模型 {en} Save draft object model
- (void)store;

/// {zh}  恢复草稿对象模型 {en} Restore Draft Object Model
/// {zh}  @param model 草稿对象 {en} model draft object
- (void)restoreWithDraftModel:(EOSDKDraftModel *)model;

/// {zh}  获取所有草稿 {en} Get all drafts
- (NSArray <EOSDKDraftModel *>*)getAllDrafts;

/// {zh}  添加草稿 {en} add draft
- (void)addOneDarftWithModel:(EOSDKDraftModel *)draft;

/// {zh}  移除草稿 {en} remove draft
- (void)removeOneDraftModel:(EOSDKDraftModel *)draft;

/// {zh}  根据NLEModel和资源文件夹路径创建一个草稿 {en} Create a draft based on NLEModel and resource folder paths
/// @param nleModel {zh} 剪辑model {en} clip model   NLEModel_OC
/// @param resourceDir {zh} 资源文件夹 {en} resource folder
- (BOOL)createDraftModelWith:(id)nleModel
                 resourceDir:(NSString * _Nullable)resourceDir;

/// {zh}  给草稿重命名，并保存 {en} Rename the draft and save it
/// @param draft {zh} 草稿对象 {en}  draft object
/// @param newName {zh} 新名称 {en}  new name
- (void)renameDraftModel:(EOSDKDraftModel *)draft
                    name:(NSString *)newName;

/// {zh}  复制草稿draft，以及草稿对应的资源文件 {en} Copy the draft, and the resource file corresponding to the draft
/// @param model {zh} 草稿Model {en} Draft Model
- (void)copyDraft:(EOSDKDraftModel *)model;

/// migrate draft from model
/// @param model draft model
/// @param oldRootPath root path for old draft model
/// @param error error
- (void)migrateDraft:(EOSDKDraftModel *)model fromRootPath:(NSString *)oldRootPath error:(NSError **)error;

/// {zh}  拷贝资源到草稿目录 {en} Copy resources to drafts directory
/// @param resourceURL {zh} 资源绝对路径 {en} resource absolute path
/// @param resourceType {zh} 资源类型 {en}  resource type
- (NSString * _Nullable)copyResourceToDraft:(NSURL *)resourceURL
                               resourceType:(int)resourceType;

/// {zh}  根据资源相对路径转换草稿相对路径 {en} Convert draft relative paths according to resource relative paths
/// @param resourceURL {zh} 资源相对路径 {en} resource relative path
/// @param resourceType {zh} 资源类型 {en}  resource type
- (NSString * _Nullable)convertResourceToDraftPath:(NSURL *)resourceURL
                                      resourceType:(int)resourceType;

/// {zh}  根据资源相对路径转换草稿绝对路径 {en} Convert draft absolute paths according to resource relative paths
/// @param resourceURL {zh} 资源绝对路径 {en} resource relative path
/// @param resourceType {zh} 资源类型 {en}  resource type
- (NSString * _Nullable)convertResourceToRootPath:(NSURL *)resourceURL
                                      resourceType:(int)resourceType;

/// {zh}  清除所有草稿缓存 {en} Clear all draft caches
/// @param error {zh} 错误信息 {en} error message
-(BOOL)clearAllCache:(NSError**)error;

//  {zh} 开启自动保存  {en} Turn on autosave
- (void)startAutoSave;

//  {zh} 停止自动保存  {en} Stop auto save
- (void)stopAutoSave;

@end

@interface EOSDKDraftModel : NSObject

// {zh} 草稿名称 {en} Draft name
@property (nonatomic, copy) NSString *name;
// {zh} 草稿封面路径 {en} Draft Cover Path
@property (nonatomic, copy) NSString *iconFileUrl;
// {zh} 草稿最后修改时间 {en} Draft last revision time
@property (nonatomic, copy) NSString *date;
// {zh} 草稿ID {en} Draft ID
@property (nonatomic, copy) NSString *draftID;
// {zh} 草稿的时长 {en} Duration of the draft
@property (nonatomic, assign) NSTimeInterval duration;
// {zh} 草稿片段数量 {en} Number of draft snippets
@property (nonatomic, assign) NSInteger videoSegmentNum;

@property (nonatomic, assign, readonly) int modelType;

@property (nonatomic, copy) NSString *appPath;

@property (nonatomic, copy) NSString *bundlePath;

// {zh} 草稿复制，并返回复制的草稿 {en} Draft copy and return the copied draft
- (EOSDKDraftModel *)copyDraft;

// copy draft without rename
- (EOSDKDraftModel *)copyDraftWithoutRename;

/// {zh} 保存草稿 {en}save draft
- (void)storeDraft:(EOSDKDraftService *)draft;

/// {zh} 恢复草稿 {en}restore draft   NLEInterface_OC
- (void)restoreDraft:(id)nle;

/// {zh} 当前草稿资源文件夹位置 {en} Current Draft Resource Folder Location
- (NSString *)draftPath;

/// {zh} 草稿model转化成json字符串 {en} Draft model converted to json string
- (NSString *)modelToJson;

/// {zh} 草稿根据json字符串进行初始化 {en} Draft is initialized according to json string
/// @param jsonStr {zh} json字符串 {en} jsonStr json string
+ (EOSDKDraftModel *)modelWithModelJson:(NSString *)jsonStr;

@end

@interface EOSDKDataStorage : NSObject

- (instancetype)initWithDraftService:(EOSDKDraftService *)draftService;

- (NSArray <EOSDKDraftModel *>*)getAllDrafts;

- (void)addOneDarftWithModel:(EOSDKDraftModel *)draft;

- (void)removeOneDraftModel:(EOSDKDraftModel *)draft;

- (void)syncFile;

@end

NS_ASSUME_NONNULL_END
