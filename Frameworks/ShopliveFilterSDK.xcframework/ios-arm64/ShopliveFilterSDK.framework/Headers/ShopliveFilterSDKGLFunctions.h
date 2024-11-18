/*
* ShopliveFilterSDKGLFunctions.h
*
*  Created on: 2013-12-5
*      Author: Wang Yang
*        Mail: admin@wysaid.org
*/

#ifndef _ShopliveFilterSDKGLFUNCTIONS_H_
#define _ShopliveFilterSDKGLFUNCTIONS_H_

#include "ShopliveFilterSDKCommonDefine.h"

#if defined(_ShopliveFilterSDK_DISABLE_GLOBALCONTEXT_) && _ShopliveFilterSDK_DISABLE_GLOBALCONTEXT_

#define ShopliveFilterSDK_ENABLE_GLOBAL_GLCONTEXT(...)
#define ShopliveFilterSDK_DISABLE_GLOBAL_GLCONTEXT(...)

#else

#define ShopliveFilterSDK_ENABLE_GLOBAL_GLCONTEXT(...) ShopliveFilterSDKEnableGlobalGLContext()
#define ShopliveFilterSDK_DISABLE_GLOBAL_GLCONTEXT(...) ShopliveFilterSDKDisableGlobalGLContext()

#endif

namespace ShopliveFilterSDK
{
#if !(defined(_ShopliveFilterSDK_DISABLE_GLOBALCONTEXT_) && _ShopliveFilterSDK_DISABLE_GLOBALCONTEXT_)

	typedef bool (*ShopliveFilterSDKEnableGLContextFunction)(void*);

	typedef bool (*ShopliveFilterSDKDisableGLContextFunction)(void*);

	void ShopliveFilterSDKSetGLContextEnableFunction(ShopliveFilterSDKEnableGLContextFunction func, void* param);
	void ShopliveFilterSDKSetGLContextDisableFunction(ShopliveFilterSDKDisableGLContextFunction func, void* param);
	void* ShopliveFilterSDKGetGLEnableParam();
	void* ShopliveFilterSDKGetGLDisableParam();
	void ShopliveFilterSDKStopGlobalGLEnableFunction();
	void ShopliveFilterSDKRestoreGlobalGLEnableFunction();

	void ShopliveFilterSDKEnableGlobalGLContext();
	void ShopliveFilterSDKDisableGlobalGLContext();

#endif

	// ShopliveFilterSDKBufferLoadFun 的返回值将作为 ShopliveFilterSDKBufferUnloadFun 的第一个参数
	// ShopliveFilterSDKBufferLoadFun 的参数 arg 将作为 ShopliveFilterSDKBufferUnloadFun 的第二个参数
	typedef void* (*ShopliveFilterSDKBufferLoadFun)(const char* sourceName, void** bufferData, GLint* w, GLint* h, ShopliveFilterSDKBufferFormat* fmt, void* arg);
	typedef bool (*ShopliveFilterSDKBufferUnloadFun)(void* arg1, void* arg2);

	//加载纹理回调， 注， 为了保持接口简洁性， 回调返回的纹理单元将由调用者负责释放
	//返回的纹理不应该为 glDeleteTextures 无法处理的特殊纹理类型.
	typedef GLuint (*ShopliveFilterSDKTextureLoadFun)(const char* sourceName, GLint* w, GLint* h, void* arg);

	//You can set a common function for loading textures
	void ShopliveFilterSDKSetCommonLoadFunction(ShopliveFilterSDKBufferLoadFun fun, void* arg);
	void ShopliveFilterSDKSetCommonUnloadFunction(ShopliveFilterSDKBufferUnloadFun fun, void* arg);

	void* ShopliveFilterSDKLoadResourceCommon(const char* sourceName, void** bufferData, GLint* w, GLint* h, GLenum* format, GLenum* type);
	ShopliveFilterSDKBufferLoadFun ShopliveFilterSDKGetCommonLoadFunc();
	void* ShopliveFilterSDKGetCommonLoadArg();
	bool ShopliveFilterSDKUnloadResourceCommon(void* bufferArg);
	ShopliveFilterSDKBufferUnloadFun ShopliveFilterSDKGetCommonUnloadFunc();
	void* ShopliveFilterSDKGetCommonUnloadArg();

	char* ShopliveFilterSDKGetScaledBufferInSize(const void* buffer, int& w, int& h, int channel, int maxSizeX, int maxSizeY);
	char* ShopliveFilterSDKGetScaledBufferOutofSize(const void* buffer, int& w, int& h, int channel, int minSizeX, int minSizeY);
	inline GLint ShopliveFilterSDKGetMaxTextureSize()
	{
		GLint n;
		glGetIntegerv(GL_MAX_TEXTURE_SIZE, &n);
		return n-1;
	}
    
	class SharedTexture
	{
	public:
        SharedTexture(int w = 0, int h = 0) : m_textureID(0), m_refCount(nullptr), width(w), height(h) {}
        SharedTexture(GLuint textureID, int w, int h);
        
        SharedTexture(const SharedTexture& other) : m_textureID(0), m_refCount(nullptr)
		{
			*this = other;
		}

        ~SharedTexture();

		inline SharedTexture& operator =(const SharedTexture& other)
		{
			ShopliveFilterSDKAssert(this != &other && (other.m_refCount == nullptr || other.m_textureID != 0));

			if(m_refCount != nullptr && --*m_refCount <= 0)
			{
				clear();
			}

			m_textureID = other.m_textureID;
			m_refCount = other.m_refCount;
			if (m_refCount != nullptr)
			{
				++*m_refCount;
				ShopliveFilterSDK_LOG_INFO("ShopliveFilterSDKSharedTexture assgin: textureID %d, refCount: %d\n", m_textureID, *m_refCount);
			}
				
			width = other.width;
			height = other.height;
			return *this;
		}

		inline GLuint texID() const { return m_textureID; }

		inline void bindToIndex(GLint index) const
		{
			glActiveTexture(GL_TEXTURE0 + index);
			glBindTexture(GL_TEXTURE_2D, m_textureID);
		}

        void forceRelease(bool bDelTexture);
        
        //特殊用法， 与 forceRelease 配对使用
        inline void forceAssignTextureID(GLuint texID)
        {
            m_textureID = texID;
        }

	public:
		int width;  //public, for easy accessing.
		int height;

	protected:
        void clear();

	private:
		GLuint m_textureID;
		mutable int* m_refCount;
	};

	class FrameBuffer
	{
	public:
		FrameBuffer() { glGenFramebuffers(1, &m_framebuffer); }
		~FrameBuffer() { glDeleteFramebuffers(1, &m_framebuffer); }

		inline void bind() const { glBindFramebuffer(GL_FRAMEBUFFER, m_framebuffer); }

		inline void bindTexture2D(const SharedTexture& texture, GLenum attachment = GL_COLOR_ATTACHMENT0) const
		{
			bindTexture2D(texture.texID(), texture.width, texture.height, attachment);
		}

		inline void bindTexture2D(const SharedTexture& texture, GLsizei x, GLsizei y, GLsizei w, GLsizei h, GLenum attachment = GL_COLOR_ATTACHMENT0) const
		{
			bindTexture2D(texture.texID(), x, y, w, h, attachment);
		}

		inline void bindTexture2D(GLuint texID, GLsizei w, GLsizei h, GLenum attachment = GL_COLOR_ATTACHMENT0) const
		{
			bindTexture2D(texID, 0, 0, w, h, attachment);
		}

		inline void bindTexture2D(GLuint texID, GLenum attachment = GL_COLOR_ATTACHMENT0) const
		{
			bind();
			glFramebufferTexture2D(GL_FRAMEBUFFER, attachment, GL_TEXTURE_2D, texID, 0);
            ShopliveFilterSDK_LOG_CODE
            (
             GLenum code = glCheckFramebufferStatus(GL_FRAMEBUFFER);
             if(code != GL_FRAMEBUFFER_COMPLETE)
             {
                 ShopliveFilterSDK_LOG_ERROR("ShopliveFilterSDK::FrameBuffer::bindTexture2D - Frame buffer is not valid: %x\n", code);
             }
             )
        }

		inline void bindTexture2D(GLuint texID, GLsizei x, GLsizei y, GLsizei w, GLsizei h, GLenum attachment = GL_COLOR_ATTACHMENT0) const
		{
			bindTexture2D(texID, attachment);
			glViewport(x, y, w, h);
		}

		inline GLuint getID() { return m_framebuffer; }

	private:
		GLuint m_framebuffer;
	};

	struct ShopliveFilterSDKSizei
    {
        ShopliveFilterSDKSizei(): width(0), height(0) {}
        ShopliveFilterSDKSizei(int w, int h) : width(w), height(h) {}
        void set(int w, int h)
        {
            width = w;
            height = h;
        }
        bool operator ==(const ShopliveFilterSDKSizei &other) const
        {
            return width == other.width && height == other.height;
        }
        bool operator !=(const ShopliveFilterSDKSizei &other) const
        {
            return width != other.width || height != other.height;
        }
        GLint width;
        GLint height;
    };
    
    struct ShopliveFilterSDKSizef
    {
        ShopliveFilterSDKSizef() : width(0.0f), height(0.0f) {}
        ShopliveFilterSDKSizef(float w, float h) : width(w), height(h) {}
        void set(float w, float h)
        {
            width = w;
            height = h;
        }
        GLfloat width;
        GLfloat height;
    };
    
    struct ShopliveFilterSDKLuminance
    {
        enum { CalcPrecision = 16 };
        enum { Weight = (1<<CalcPrecision) };
        enum { RWeight = int(0.299*Weight), GWeight = int(0.587*Weight), BWeight = int(0.114*Weight) };
        
        static inline int RGB888(int r, int g, int b)
        {			
            return (r * RWeight + g * GWeight + b * BWeight) >> CalcPrecision;
        }
        
        //color 从低位到高位的顺序为r-g-b, 传参时需要注意大小端问题
        static inline int RGB565(unsigned short color)
        {
            const int r = (color & 31) << 3;
            const int g = ((color >> 5) & 63) << 2;
            const int b = ((color >> 11) & 31) << 3;
            
            return RGB888(r, g, b);
        }
    };

}

//////////////////////////////////////////////////////////////////////////
#include <vector>
#include <ctime>
#include <memory>
#include "ShopliveFilterSDKShaderFunctions.h"
#include "ShopliveFilterSDKImageHandler.h"
#include "ShopliveFilterSDKImageFilter.h"

#endif /* _ShopliveFilterSDKGLFUNCTIONS_H_ */
