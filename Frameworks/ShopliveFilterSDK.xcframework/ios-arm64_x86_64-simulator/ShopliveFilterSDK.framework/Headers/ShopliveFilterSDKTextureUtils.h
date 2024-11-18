/*
* ShopliveFilterSDKTextureUtils.h
*
*  Created on: 2015-7-29
*      Author: Wang Yang
*/

#ifndef _ShopliveFilterSDKTEXTUREUTILS_H_
#define _ShopliveFilterSDKTEXTUREUTILS_H_

#include "ShopliveFilterSDKGLFunctions.h"

namespace ShopliveFilterSDK
{

	class TextureDrawer
	{
	protected:
		TextureDrawer() : m_vertBuffer(0) {}
		virtual bool init();
        virtual bool initWithShaderString(ShopliveFilterSDKConstString vsh, ShopliveFilterSDKConstString fsh);
	public:
		
        virtual ~TextureDrawer();

		ShopliveFilterSDK_COMMON_CREATE_FUNC(TextureDrawer, init);

		//绘制 texture 到当前的framebuffer上
		//同样不对viewport进行处理
		virtual void drawTexture(GLuint src);

		//设置绘制时的旋转(弧度)
		//旋转操作先于翻转缩放
		void setRotation(float rad);

		//设置绘制时的翻转或者缩放, 翻转和缩放操作都后于旋转执行
		//eg. 当x，y大于0时为缩放
		//    当x/y 小于0时， 该边将会翻转
		void setFlipScale(float x, float y);

		//特殊外部用法, 绑定扇形逆时针方向四顶点
		void bindVertexBuffer();

        inline ProgramObject& getProgram() { return m_program; }
        
	protected:
		ProgramObject m_program;
		//不使用ShopliveFilterSDKGlobal里面的， 避免出现context冲突
		GLuint m_vertBuffer;
		GLint m_rotLoc, m_flipScaleLoc;

		void _rotate(GLint location, float rad);

	protected:
		virtual ShopliveFilterSDKConstString getFragmentShaderString();
		virtual ShopliveFilterSDKConstString getVertexShaderString();
	};


	////////////////////////////////////////////////////////////

	//直接绘制一张texture， 提供旋转缩放翻转等操作。
	class TextureDrawerExt : public TextureDrawer
	{
	public:
		
        ~TextureDrawerExt();

		ShopliveFilterSDK_COMMON_CREATE_FUNC(TextureDrawerExt, init);

		//不处理任何viewport相关， 需提前设置
		//将texture绘制到另一张texture上
		void drawTexture2Texture(GLuint src, GLuint dst);

		// void drawTexture(GLuint src) { TextureDrawer::drawTexture(src); }

		//将普通类型的texture绑定为当前的framebuffer
		//需要提供被绑定texture的宽高， 以对viewport匹配
		void bindTextureDst(GLuint dst, int width, int height);

		//绘制 texture 到当前的framebuffer上
		//同样不对viewport进行处理
		// virtual void drawTexture(GLuint src);

		//将texture绘制到绑定的framebuffer中
		void drawTexture2Buffer(GLuint src, bool fullSize = true);

		// //设置绘制时的旋转(弧度)
		// //旋转操作先于翻转缩放
		// void setRotation(float rad);

		// //设置绘制时的翻转或者缩放, 翻转和缩放操作都后于旋转执行
		// //eg. 当x，y大于0时为缩放
		// //    当x/y 小于0时， 该边将会翻转
		// void setFlipScale(float x, float y);

		//绑定扇形逆时针方向四顶点
		// void bindVertexBuffer();

		ShopliveFilterSDKSizei getBufferTexSize() { return m_texSize; }

	protected:
		FrameBuffer m_framebuffer;		
		ShopliveFilterSDKSizei m_texSize;
	};

	class TextureDrawerWithMask : public TextureDrawer
	{
	public:

		ShopliveFilterSDK_COMMON_CREATE_FUNC(TextureDrawerWithMask, init);
        
        ~TextureDrawerWithMask();

		void setMaskRotation(float rad);
		void setMaskFlipScale(float x, float y);

		void drawTexture(GLuint src);

		void setMaskTexture(GLuint maskTexture);

	protected:
		
		bool init();

	private:
		//将打破 "getFragmentShaderString" 方法的使用。
		ShopliveFilterSDKConstString getFragmentShaderString() { return nullptr; }

		GLint m_maskRotLoc, m_maskFlipScaleLoc;
		GLuint m_maskTexture;
	};

#ifdef GL_TEXTURE_EXTERNAL_OES

	//本类中， 使用的src texture 都必须是 external_OES 类型
	class TextureDrawer4ExtOES : public TextureDrawer
	{
	public:
		ShopliveFilterSDK_COMMON_CREATE_FUNC(TextureDrawer4ExtOES, init);

		void drawTexture(GLuint src);

		void setTransform(float* mat16);

	protected:
		ShopliveFilterSDKConstString getFragmentShaderString();
		ShopliveFilterSDKConstString getVertexShaderString();

		bool init();

	private:
		GLint m_transformLoc;
	};

#endif
    
    class TextureDrawerYUV : public TextureDrawer
    {
    public:
        ShopliveFilterSDK_COMMON_CREATE_FUNC(TextureDrawerYUV, init);
        
        //assume the lumaTexture is bind to GL_TEXTURE0
        //and the chromaTexture is bind to GL_TEXTURE1
        void drawTextures();
        void drawTextures(GLuint lumaTex, GLuint chromaTex);
        
    protected:
        void drawTexture(GLuint) {}
        
        ShopliveFilterSDKConstString getFragmentShaderString();
		ShopliveFilterSDKConstString getVertexShaderString();
        
    private:
        bool init();
    };
    
    ////////////////////////////////////////////////////////////

    enum ShopliveFilterSDKTextureDrawerOutputFormat {
        ShopliveFilterSDKTextureDrawerOutputFormat_Default, //RGBA
        ShopliveFilterSDKTextureDrawerOutputFormat_BGRA, //BGRA
    };
    
    class TextureDrawerRGB2YUV420P : public TextureDrawer
    {
    public:
        
        ShopliveFilterSDK_COMMON_CREATE_FUNC_WITH_PARAM(TextureDrawerRGB2YUV420P, initWithOutputFormat, ShopliveFilterSDKTextureDrawerOutputFormat, = ShopliveFilterSDKTextureDrawerOutputFormat_Default);
        
    	void setOutputSize(int width, int height);
        
    protected:
        bool initWithOutputFormat(ShopliveFilterSDKTextureDrawerOutputFormat format);
        
        ShopliveFilterSDKConstString getFragmentShaderString();
        ShopliveFilterSDKConstString getVertexShaderString();
    };
    
    class TextureDrawerRGB2NV21 : public TextureDrawerRGB2YUV420P
    {
    public:
        
        ShopliveFilterSDK_COMMON_CREATE_FUNC_WITH_PARAM(TextureDrawerRGB2NV21, initWithOutputFormat, ShopliveFilterSDKTextureDrawerOutputFormat, = ShopliveFilterSDKTextureDrawerOutputFormat_Default);
        
    protected:
        ShopliveFilterSDKConstString getFragmentShaderString();
    };
    
    class TextureDrawerRGB2NV12 : public TextureDrawerRGB2YUV420P
    {
    public:
        
        ShopliveFilterSDK_COMMON_CREATE_FUNC_WITH_PARAM(TextureDrawerRGB2NV12, initWithOutputFormat, ShopliveFilterSDKTextureDrawerOutputFormat, = ShopliveFilterSDKTextureDrawerOutputFormat_Default);
        
    protected:
        ShopliveFilterSDKConstString getFragmentShaderString();
    };
    
    ////////////////////////////////////////////////////////////

    class ShopliveFilterSDKLerpBlurUtil
    {
    protected:
        ShopliveFilterSDKLerpBlurUtil();
    public:
        
        ~ShopliveFilterSDKLerpBlurUtil();
        
        enum { MAX_LERP_BLUR_INTENSITY = 8 };
        
        struct TextureCache
        {
            GLuint texID;
            ShopliveFilterSDKSizei size;
        };
        
        void setBlurLevel(int value);
        
        void calcWithTexture(GLuint texture, int width, int height, GLuint target = 0, int targetWidth = 0, int targetHeight = 0);
        
        inline GLuint getResult() { return m_texCache->texID; }
        
        void drawTexture(GLuint texID);
        
        ///////////////////////////
        
        static inline ShopliveFilterSDKLerpBlurUtil* create()
        {
            ShopliveFilterSDKLerpBlurUtil* lerp = new ShopliveFilterSDKLerpBlurUtil();
            if(!lerp->init())
            {
                delete lerp;
                lerp = nullptr;
            }
            return lerp;
        }
        
        inline FrameBuffer& frameBuffer() { return m_framebuffer; }
        inline TextureCache* texCache() { return m_texCache; }
        
    protected:
        bool init();
        void _genMipmaps(int width, int height);
        void _clearMipmaps();
        int _calcLevel(int len, int level);
        
    protected:
        TextureCache m_texCache[MAX_LERP_BLUR_INTENSITY];
        GLuint m_vertBuffer;
        
        int m_cacheTargetWidth, m_cacheTargetHeight;
        int m_intensity;
        bool m_isBaseChanged;
        
        ProgramObject m_program;
        FrameBuffer m_framebuffer;
    };

}


//#undef ShopliveFilterSDK_TEXTURE_DRAWER_STATIC_FUNC

#endif
