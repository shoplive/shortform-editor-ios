/*
 * ShopliveFilterSDKCommonDefine.h
 *
 *  Created on: 2013-12-6
 *      Author: Wang Yang
 *        Mail: admin@wysaid.org
 */

#ifndef _ShopliveFilterSDKCOMMONDEFINE_H_
#define _ShopliveFilterSDKCOMMONDEFINE_H_

#include "ShopliveFilterSDKGlobal.h"

#ifndef ShopliveFilterSDKCheckGLError
#ifdef ShopliveFilterSDK_LOG_ERROR
#define ShopliveFilterSDKCheckGLError(name) _ShopliveFilterSDKCheckGLError(name, __FILE__, __LINE__);
#else
#define ShopliveFilterSDKCheckGLError(name)
#endif
#endif

#ifndef _ShopliveFilterSDK_GET_MACRO_STRING_HELP
#define _ShopliveFilterSDK_GET_MACRO_STRING_HELP(x) #x
#endif
#ifndef ShopliveFilterSDK_GET_MACRO_STRING
#define ShopliveFilterSDK_GET_MACRO_STRING(x) _ShopliveFilterSDK_GET_MACRO_STRING_HELP(x)
#endif
#define ShopliveFilterSDK_FLOATCOMP0(x)	(x < 0.001f && x > -0.001f)

#define ShopliveFilterSDK_UNIFORM_MAX_LEN 32

#define ShopliveFilterSDK_DELETE(p) do { delete p; p = NULL; } while(0)
#define ShopliveFilterSDK_DELETE_ARR(p) do { delete[] p; p = NULL; } while(0)

/*
 为节省texture资源，对OpenGL 所有texture的使用约束如下:
 0号和1号纹理在各种初始化中可能会被多次用到，如果需要绑定固定的纹理，
 请在使用纹理时，从 TEXTURE_START 开始。
 不排除这种需要会增加，所以，
 请使用下面的宏进行加法运算, 以代替手写的 GL_TEXTURE*
 
 */

#define ShopliveFilterSDK_TEXTURE_INPUT_IMAGE_INDEX 0
#define ShopliveFilterSDK_TEXTURE_INPUT_IMAGE GL_TEXTURE0

#define ShopliveFilterSDK_TEXTURE_OUTPUT_IMAGE_INDEX 1
#define ShopliveFilterSDK_TEXTURE_OUTPUT_IMAGE GL_TEXTURE1

#define ShopliveFilterSDK_TEXTURE_START_INDEX 2
#define ShopliveFilterSDK_TEXTURE_START GL_TEXTURE2

//Mark if the texture is premultiplied with the alpha channel.
#ifndef ShopliveFilterSDK_TEXTURE_PREMULTIPLIED
#define ShopliveFilterSDK_TEXTURE_PREMULTIPLIED 0
#endif

#ifdef _ShopliveFilterSDK_SHADER_VERSION_

#define ShopliveFilterSDK_GLES_ATTACH_STRING_L "#version " ShopliveFilterSDK_GET_MACRO_STRING(_ShopliveFilterSDK_SHADER_VERSION_) "\n#ifdef GL_ES\nprecision lowp float;\n#endif\n"
#define ShopliveFilterSDK_GLES_ATTACH_STRING_M "#version " ShopliveFilterSDK_GET_MACRO_STRING(_ShopliveFilterSDK_SHADER_VERSION_) "\n#ifdef GL_ES\nprecision mediump float;\n#endif\n"
#define ShopliveFilterSDK_GLES_ATTACH_STRING_H "#version " ShopliveFilterSDK_GET_MACRO_STRING(_ShopliveFilterSDK_SHADER_VERSION_) "\n#ifdef GL_ES\nprecision highp float;\n#endif\n"

#else

#define ShopliveFilterSDK_GLES_ATTACH_STRING_L "#ifdef GL_ES\nprecision lowp float;\n#endif\n"
#define ShopliveFilterSDK_GLES_ATTACH_STRING_M "#ifdef GL_ES\nprecision mediump float;\n#endif\n"
#define ShopliveFilterSDK_GLES_ATTACH_STRING_H "#ifdef GL_ES\nprecision highp float;\n#endif\n"
#endif

//Do not add any precision conf within SHADER_STRING_PRECISION_* macro!
#if defined(_MSC_VER) && _MSC_VER < 1600
//If the m$ compiler is under 10.0, there mustn't be any ',' outside the "()" in the shader string !!
//For exmaple: vec2(0.0, 0.0) --> YES.
//             float a, b;  --> No!!!, you must do like this: float a; float b;
#define ShopliveFilterSDK_SHADER_STRING_PRECISION_L(string) ShopliveFilterSDK_GLES_ATTACH_STRING_L  #string
#define ShopliveFilterSDK_SHADER_STRING_PRECISION_M(string) ShopliveFilterSDK_GLES_ATTACH_STRING_M  #string
#define ShopliveFilterSDK_SHADER_STRING_PRECISION_H(string) ShopliveFilterSDK_GLES_ATTACH_STRING_H  #string
#ifndef ShopliveFilterSDK_SHADER_STRING
#define ShopliveFilterSDK_SHADER_STRING(string) #string
#endif
#else
#define ShopliveFilterSDK_SHADER_STRING_PRECISION_L(...) ShopliveFilterSDK_GLES_ATTACH_STRING_L  #__VA_ARGS__
#define ShopliveFilterSDK_SHADER_STRING_PRECISION_M(...) ShopliveFilterSDK_GLES_ATTACH_STRING_M  #__VA_ARGS__
#define ShopliveFilterSDK_SHADER_STRING_PRECISION_H(...) ShopliveFilterSDK_GLES_ATTACH_STRING_H  #__VA_ARGS__
#ifndef ShopliveFilterSDK_SHADER_STRING
#define ShopliveFilterSDK_SHADER_STRING(...) #__VA_ARGS__
#endif
#endif

#define ShopliveFilterSDK_COMMON_CREATE_FUNC(cls, funcName) \
static inline cls* create() \
{\
cls* instance = new cls(); \
if(!instance->funcName()) \
{ \
delete instance; \
instance = nullptr; \
ShopliveFilterSDK_LOG_ERROR("create %s failed!", #cls); \
} \
return instance; \
}

#define ShopliveFilterSDK_COMMON_CREATE_FUNC_WITH_PARAM(cls, funcName, paramName, ...) \
static inline cls* create(paramName param __VA_ARGS__) \
{\
cls* instance = new cls(); \
if(!instance->funcName(param)) \
{ \
delete instance; \
instance = nullptr; \
ShopliveFilterSDK_LOG_ERROR("create %s failed!", #cls); \
} \
return instance; \
}

#define ShopliveFilterSDK_COMMON_CREATE_FUNC_WITH_PARAM2(cls, funcName, paramName) \
static inline cls* create(paramName param) \
{\
cls* instance = new cls(param); \
if(!instance->funcName()) \
{ \
delete instance; \
instance = nullptr; \
ShopliveFilterSDK_LOG_ERROR("create %s failed!", #cls); \
} \
return instance; \
}


#define ShopliveFilterSDK_ARRAY_LEN(x) (sizeof(x) / sizeof(*x))

#ifdef __cplusplus

template <class T, int Len>
static inline int ShopliveFilterSDKArrLen(const T (&v)[Len])
{
    return Len;
}

template <typename T>
static inline void ShopliveFilterSDKResetValue(T& t)
{
    t = T();
}

template <typename T, typename ...ARGS>
static inline void ShopliveFilterSDKResetValue(T& t, ARGS&... args)
{
    t = T();
    ShopliveFilterSDKResetValue(args...);
}

#define ShopliveFilterSDK_DELETE_GL_OBJS(func, ...) \
do\
{\
    GLuint objs[] = {__VA_ARGS__}; \
    func(ShopliveFilterSDKArrLen(objs), objs); \
    ShopliveFilterSDKResetValue(__VA_ARGS__); \
}while(0)

template<class T>
class ShopliveFilterSDKBlockLimit
{
    ShopliveFilterSDKBlockLimit& operator=(const ShopliveFilterSDKBlockLimit& other) { return *this; }
public:
    explicit ShopliveFilterSDKBlockLimit(T f) : func(f) {}
    ~ShopliveFilterSDKBlockLimit() { func(); }
    
private:
    T func;
};

template<class T>
inline ShopliveFilterSDKBlockLimit<const T&> ShopliveFilterSDK_BLOCK_LIMIT_HELPER3(const T& f)
{
    return ShopliveFilterSDKBlockLimit<const T&>(f);
}

#define ShopliveFilterSDK_BLOCK_LIMIT_HELPER2(ARG, ANYSIGN, LAMBDA_REF) \
const auto& LAMBDA_REF = ARG; \
const auto& ANYSIGN = ShopliveFilterSDK_BLOCK_LIMIT_HELPER3(LAMBDA_REF); \
(void)ANYSIGN;  // Avoid warning for unused variable.

#define ShopliveFilterSDK_BLOCK_LIMIT_HELPER1(ARG, VAR, LINE) ShopliveFilterSDK_BLOCK_LIMIT_HELPER2(ARG, VAR ## LINE, VAR ## LINE ## LAMBDA_REF)
#define ShopliveFilterSDK_BLOCK_LIMIT_HELPER0(ARG, VAR, LINE) ShopliveFilterSDK_BLOCK_LIMIT_HELPER1(ARG, VAR, LINE)
#define ShopliveFilterSDKMakeBlockLimit(...) ShopliveFilterSDK_BLOCK_LIMIT_HELPER0(__VA_ARGS__, ShopliveFilterSDK_blockVar, __LINE__)

namespace ShopliveFilterSDK
{
#ifndef ShopliveFilterSDK_MIN
    
    template<typename Type>
    inline Type ShopliveFilterSDK_MIN(Type a, Type b)
    {
        return a < b ? a : b;
    }
    
#endif
    
#ifndef ShopliveFilterSDK_MAX
    
    template<typename Type>
    inline Type ShopliveFilterSDK_MAX(Type a, Type b)
    {
        return a > b ? a : b;
    }
    
#endif
    
#ifndef ShopliveFilterSDK_MID
    
    template<typename Type>
    inline Type ShopliveFilterSDK_MID(Type n, Type vMin, Type vMax)
    {
        if(n < vMin)
            n = vMin;
        else if(n > vMax)
            n = vMax;
        return n;
    }
    
#endif
    
#ifndef ShopliveFilterSDK_MIX
    
    template<typename OpType, typename MixType>
    inline auto ShopliveFilterSDK_MIX(OpType a, OpType b, MixType value) -> decltype(a - a * value + b * value)
    {
        return a - a * value + b * value;
    }
    
#endif
}


extern "C" {
#endif
    
    typedef const char* const ShopliveFilterSDKConstString;
    
    typedef enum ShopliveFilterSDKBufferFormat
    {
        ShopliveFilterSDK_FORMAT_RGB_INT8,
        ShopliveFilterSDK_FORMAT_RGB_INT16,
        ShopliveFilterSDK_FORMAT_RGB_FLOAT32,
        ShopliveFilterSDK_FORMAT_RGBA_INT8,
        ShopliveFilterSDK_FORMAT_RGBA_INT16,
        ShopliveFilterSDK_FORMAT_RGBA_FLOAT32,
#ifdef GL_BGR
        ShopliveFilterSDK_FORMAT_BGR_INT8,
        ShopliveFilterSDK_FORMAT_BGR_INT16,
        ShopliveFilterSDK_FORMAT_BGR_FLOAT32,
#endif
#ifdef GL_BGRA
        ShopliveFilterSDK_FORMAT_BGRA_INT8,
        ShopliveFilterSDK_FORMAT_BGRA_INT16,
        ShopliveFilterSDK_FORMAT_BGRA_FLOAT32,
#endif
#ifdef GL_LUMINANCE
        ShopliveFilterSDK_FORMAT_LUMINANCE, // 8 bit
#endif
#ifdef GL_LUMINANCE_ALPHA
        ShopliveFilterSDK_FORMAT_LUMINANCE_ALPHA, //8+8 bit
#endif
        
    }ShopliveFilterSDKBufferFormat;
    
    typedef enum ShopliveFilterSDKTextureBlendMode
    {
        ShopliveFilterSDK_BLEND_MIX,            // 0 正常
        ShopliveFilterSDK_BLEND_DISSOLVE,       // 1 溶解
        
        ShopliveFilterSDK_BLEND_DARKEN,         // 2 变暗
        ShopliveFilterSDK_BLEND_MULTIPLY,       // 3 正片叠底
        ShopliveFilterSDK_BLEND_COLORBURN,      // 4 颜色加深
        ShopliveFilterSDK_BLEND_LINEARBURN,     // 5 线性加深
        ShopliveFilterSDK_BLEND_DARKER_COLOR,   // 6 深色
        
        ShopliveFilterSDK_BLEND_LIGHTEN,        // 7 变亮
        ShopliveFilterSDK_BLEND_SCREEN,         // 8 滤色
        ShopliveFilterSDK_BLEND_COLORDODGE,     // 9 颜色减淡
        ShopliveFilterSDK_BLEND_LINEARDODGE,    // 10 线性减淡
        ShopliveFilterSDK_BLEND_LIGHTERCOLOR,  // 11 浅色
        
        ShopliveFilterSDK_BLEND_OVERLAY,        // 12 叠加
        ShopliveFilterSDK_BLEND_SOFTLIGHT,      // 13 柔光
        ShopliveFilterSDK_BLEND_HARDLIGHT,      // 14 强光
        ShopliveFilterSDK_BLEND_VIVIDLIGHT,     // 15 亮光
        ShopliveFilterSDK_BLEND_LINEARLIGHT,    // 16 线性光
        ShopliveFilterSDK_BLEND_PINLIGHT,       // 17 点光
        ShopliveFilterSDK_BLEND_HARDMIX,        // 18 实色混合
        
        ShopliveFilterSDK_BLEND_DIFFERENCE,     // 19 差值
        ShopliveFilterSDK_BLEND_EXCLUDE,        // 20 排除
        ShopliveFilterSDK_BLEND_SUBTRACT,       // 21 减去
        ShopliveFilterSDK_BLEND_DIVIDE,         // 22 划分
        
        ShopliveFilterSDK_BLEND_HUE,            // 23 色相
        ShopliveFilterSDK_BLEND_SATURATION,     // 24 饱和度
        ShopliveFilterSDK_BLEND_COLOR,          // 25 颜色
        ShopliveFilterSDK_BLEND_LUMINOSITY,     // 26 明度
        
        /////////////    More blend mode below (You can't see them in Adobe Photoshop)    //////////////
        
        ShopliveFilterSDK_BLEND_ADD,			  // 27
        ShopliveFilterSDK_BLEND_ADDREV,         // 28
        ShopliveFilterSDK_BLEND_COLORBW,		  // 29
        
        /////////////    More blend mode above     //////////////
        
        ShopliveFilterSDK_BLEND_TYPE_MAX_NUM //Its value defines the max num of blend.
    }ShopliveFilterSDKTextureBlendMode;
    
    typedef enum ShopliveFilterSDKGlobalBlendMode
    {
        ShopliveFilterSDKGLOBAL_BLEND_NONE,
        ShopliveFilterSDKGLOBAL_BLEND_ALPHA,
        ShopliveFilterSDKGLOBAL_BLEND_ALPHA_SEPERATE,
        ShopliveFilterSDKGLOBAL_BLEND_ADD,
        ShopliveFilterSDKGLOBAL_BLEND_ADD_SEPARATE,
        ShopliveFilterSDKGLOBAL_BLEND_ADD_SEPARATE_EXT, //带EXT的忽略alpha是否预乘
        ShopliveFilterSDKGLOBAL_BLEND_MULTIPLY,
        ShopliveFilterSDKGLOBAL_BLEND_MULTIPLY_SEPERATE,
        ShopliveFilterSDKGLOBAL_BLEND_SCREEN,
        ShopliveFilterSDKGLOBAL_BLEND_SCREEN_EXT,
    }ShopliveFilterSDKGlobalBlendMode;
    
    const char* ShopliveFilterSDKGetVersion(void);
    void ShopliveFilterSDKPrintGLString(const char*, GLenum);
    bool _ShopliveFilterSDKCheckGLError(const char* name, const char* file, int line); //请直接使用 ShopliveFilterSDKCheckGLError
    
    ////////////////////////////////////

    void ShopliveFilterSDKSetGlobalBlendMode(const ShopliveFilterSDKGlobalBlendMode mode);
    void ShopliveFilterSDKGetDataAndChannelByFormat(ShopliveFilterSDKBufferFormat fmt, GLenum* dataFmt, GLenum* channelFmt, GLint* channel);
    
#ifdef __cplusplus
    const char* ShopliveFilterSDKGetBlendModeName(const ShopliveFilterSDKTextureBlendMode mode, bool withChinese = false);
    GLuint ShopliveFilterSDKGenTextureWithBuffer(const void* bufferData, GLint w, GLint h, GLenum channelFmt, GLenum dataFmt, GLint channels = 4, GLint bindID = 0, GLenum texFilter = GL_LINEAR, GLenum texWrap = GL_CLAMP_TO_EDGE);
#else
    const char* ShopliveFilterSDKGetBlendModeName(const ShopliveFilterSDKTextureBlendMode mode, bool withChinese);
    GLuint ShopliveFilterSDKGenTextureWithBuffer(const void* bufferData, GLint w, GLint h, GLenum channelFmt, GLenum dataFmt, GLint channels, GLint bindID , GLenum texFilter, GLenum texWrap);
#endif
    
#ifdef __cplusplus
}
#endif

#endif /* _ShopliveFilterSDKCOMMONDEFINE_H_ */
