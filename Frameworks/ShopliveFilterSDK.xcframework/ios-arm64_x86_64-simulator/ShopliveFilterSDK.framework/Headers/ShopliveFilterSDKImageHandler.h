/*
* ShopliveFilterSDKImageHandler.h
*
*  Created on: 2013-12-13
*      Author: Wang Yang
*      Mail: admin@wysaid.org
*/

#ifndef _ShopliveFilterSDKIMAGEHANDLER_H_
#define _ShopliveFilterSDKIMAGEHANDLER_H_

#include "ShopliveFilterSDKGLFunctions.h"
#include "ShopliveFilterSDKImageFilter.h"
#include "ShopliveFilterSDKGlobal.h"

namespace ShopliveFilterSDK
{
	class ShopliveFilterSDKImageFilterInterfaceAbstract;
	class ShopliveFilterSDKImageFilterInterface;
	class TextureDrawer;

	class ShopliveFilterSDKImageHandlerInterface
	{
	public:
		ShopliveFilterSDKImageHandlerInterface();
		virtual ~ShopliveFilterSDKImageHandlerInterface();
		
		//调用本函数获取handler本次处理最终结果（handler在调用后将失效，需重新init)
		virtual GLuint getResultTextureAndClearHandler();
		virtual size_t getOutputBufferLen(size_t channel = 4); //if 0 is returned , it means the handler is not successfully initialized.
		virtual size_t getOutputBufferBytesPerRow(size_t channel = 4);
		inline const GLfloat* getPosVertices() const
		{	
			return ShopliveFilterSDKGlobalConfig::sVertexDataCommon;
		};

		virtual void processingFilters() = 0;
		virtual void setAsTarget() = 0;
		virtual void swapBufferFBO() = 0; //This should only be called by the image processing classes. Do check that carefully.

		//The return value would be a new texture if 0 is passed in.
		virtual GLuint copyLastResultTexture(GLuint dstTex = 0) { return 0; }
		virtual GLuint copyResultTexture(GLuint dstTex = 0) { return 0; }

		//You should not modify the textures given below outside the handler.(Read-Only)
		//But once if you need to do that, remember to change their values.
		GLuint& getSourceTextureID() { return m_srcTexture; }
		GLuint& getTargetTextureID() { return m_bufferTextures[0]; }
		GLuint& getBufferTextureID() { return m_bufferTextures[1]; }
		const ShopliveFilterSDKSizei& getOutputFBOSize() const { return m_dstImageSize; }
		GLuint& getFrameBufferID() { return m_dstFrameBuffer; }
		void getOutputFBOSize(int &w, int &h) { w = m_dstImageSize.width; h = m_dstImageSize.height; }

        void copyTextureData(void* data, int w, int h, GLuint texID, GLenum dataFmt, GLenum channelFmt);

	protected:
		virtual bool initImageFBO(const void* data, int w, int h, GLenum channelFmt, GLenum dataFmt, int channel);
		virtual void clearImageFBO();

	protected:
		GLuint m_srcTexture;
		ShopliveFilterSDKSizei m_dstImageSize;
		GLuint m_bufferTextures[2];
		GLuint m_dstFrameBuffer;
		GLuint m_vertexArrayBuffer;
	};


	class ShopliveFilterSDKImageHandler : public ShopliveFilterSDKImageHandlerInterface
	{
	private:
		explicit ShopliveFilterSDKImageHandler(const ShopliveFilterSDKImageHandler&) {}
	public:
		ShopliveFilterSDKImageHandler();
		virtual ~ShopliveFilterSDKImageHandler();

		bool initWithRawBufferData(const void* data, GLint w, GLint h, ShopliveFilterSDKBufferFormat format, bool bEnableReversion = true);
		bool updateData(const void* data, int w, int h, ShopliveFilterSDKBufferFormat format);

		bool initWithTexture(GLuint textureID, GLint w, GLint h, ShopliveFilterSDKBufferFormat format, bool bEnableReversion = false);
        bool updateTexture(GLuint textureID, int w, int h);

		bool getOutputBufferData(void* data, ShopliveFilterSDKBufferFormat format);
		size_t getOutputBufferLen(size_t channel);
		size_t getOutputBufferBytesPerRow(size_t channel);

		void setAsTarget();
		void addImageFilter(ShopliveFilterSDKImageFilterInterfaceAbstract* proc);
		void popImageFilter();
		void clearImageFilters(bool bDelMem = true);
		inline size_t getFilterNum() { return m_vecFilters.size(); }
		inline ShopliveFilterSDKImageFilterInterfaceAbstract* getFilterByIndex(GLuint index)
		{ return index >= m_vecFilters.size() ? nullptr : m_vecFilters[index]; }
		int getFilterIndexByAddr(const void* addr);
		bool insertFilterAtIndex(ShopliveFilterSDKImageFilterInterfaceAbstract* proc, GLuint index);
		bool deleteFilterByAddr(const void* addr, bool bDelMem = true);
		bool deleteFilterByIndex(GLuint index, bool bDelMem = true);
		bool replaceFilterAtIndex(ShopliveFilterSDKImageFilterInterfaceAbstract* proc, GLuint index, bool bDelMem = true);
		bool swapFilterByIndex(GLuint left, GLuint right);
		void peekFilters(std::vector<ShopliveFilterSDKImageFilterInterfaceAbstract*>* vTrans);
		std::vector<ShopliveFilterSDKImageFilterInterfaceAbstract*>& peekFilters() { return m_vecFilters; }

		void processingFilters();

		//使用当前存储的filter里面某个特定的进行滤镜
		//The last filter of all would be used if the index is -1
		bool processingWithFilter(GLint index);

		//使用未加入的滤镜进行单独处理。
		bool processingWithFilter(ShopliveFilterSDKImageFilterInterfaceAbstract* proc);

		virtual void disableReversion();
		bool reversionEnabled() { return m_bRevertEnabled; }
		bool keepCurrentResult();
		virtual bool revertToKeptResult(bool bRevert2Target = false);
		virtual void swapBufferFBO(); //This should only be called by the image processing classes. Do check that carefully.
		virtual GLuint copyLastResultTexture(GLuint dstTex = 0);
		virtual GLuint copyResultTexture(GLuint dstTex = 0);

#ifdef _ShopliveFilterSDK_USE_ES_API_3_0_

		const void* mapOutputBuffer(ShopliveFilterSDKBufferFormat fmt);
		void unmapOutputBuffer();

#endif

		//辅助方法
		bool copyTexture(GLuint dst, GLuint src); //使用handler内部图像尺寸
		bool copyTexture(GLuint dst, GLuint src, int x, int y, int w, int h);
		bool copyTexture(GLuint dst, GLuint src, int xOffset, int yOffset, int x, int y, int w, int h);

		void drawResult();
		TextureDrawer* getResultDrawer();
		void setResultDrawer(TextureDrawer* drawer);

        virtual void useImageFBO();

	protected:

		bool m_bRevertEnabled;
		std::vector<ShopliveFilterSDKImageFilterInterfaceAbstract*> m_vecFilters;

		TextureDrawer *m_drawer, *m_resultDrawer;

#ifdef _ShopliveFilterSDK_USE_ES_API_3_0_
		GLuint m_pixelPackBuffer;
		GLsizei m_pixelPackBufferSize;

		void clearPixelBuffer();
		bool initPixelBuffer();
		bool initImageFBO(const void* data, int w, int h, GLenum channelFmt, GLenum dataFmt, int channel);
#endif
	};
}
#endif
