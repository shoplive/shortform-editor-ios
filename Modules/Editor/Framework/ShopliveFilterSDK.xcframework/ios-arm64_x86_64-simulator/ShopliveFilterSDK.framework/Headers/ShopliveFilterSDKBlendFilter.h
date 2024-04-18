/*
 * ShopliveFilterSDKBlendFilter.h
 *
 *  Created on: 2015-2-13
 *      Author: Wang Yang
 */

#ifndef _ShopliveFilterSDKBLENDFILTER_H_
#define _ShopliveFilterSDKBLENDFILTER_H_

#include "ShopliveFilterSDKGLFunctions.h"

namespace ShopliveFilterSDK
{
	//"ShopliveFilterSDKBlendInterface" should not be used as instances.
	class ShopliveFilterSDKBlendInterface : public ShopliveFilterSDKImageFilterInterface
	{
	public:
		virtual ~ShopliveFilterSDKBlendInterface() {}
		virtual bool initWithMode(ShopliveFilterSDKTextureBlendMode mode) = 0;
		virtual bool initWithMode(const char* modeName) = 0;
		virtual void setIntensity(float value);

		static ShopliveFilterSDKTextureBlendMode getBlendModeByName(const char* modeName);
		static const char* getShaderFuncByBlendMode(const char* modeName);
		static const char* getShaderFuncByBlendMode(ShopliveFilterSDKTextureBlendMode mode);
		static const char* getBlendWrapper();
		static const char* getBlendKrWrapper();
		static const char* getBlendPixWrapper();
		static const char* getBlendSelfWrapper();

		static bool initWithModeName(const char* modeName, ShopliveFilterSDKBlendInterface* blendIns);		
		static ShopliveFilterSDKConstString paramIntensityName;
	};

	class ShopliveFilterSDKBlendFilter : public ShopliveFilterSDKBlendInterface
	{
	public:
		ShopliveFilterSDKBlendFilter() : m_blendTexture(0) {}
		~ShopliveFilterSDKBlendFilter() { glDeleteTextures(1, &m_blendTexture); }

		virtual bool initWithMode(ShopliveFilterSDKTextureBlendMode mode);
		virtual bool initWithMode(const char* modeName);

		void setSamplerID(GLuint texID, bool shouldDelete = true);

	protected:
		static ShopliveFilterSDKConstString paramBlendTextureName;
		void initSampler();

	protected:
		GLuint m_blendTexture; //The texture would be deleted by this filter;
	};

	class ShopliveFilterSDKBlendWithResourceFilter : public ShopliveFilterSDKBlendFilter
	{
	public:
		ShopliveFilterSDKBlendWithResourceFilter() {}
		~ShopliveFilterSDKBlendWithResourceFilter() { }

		virtual void setTexSize(int w, int h);
		ShopliveFilterSDKSizei& getTexSize() { return m_blendTextureSize; }

	protected:		

		ShopliveFilterSDKSizei m_blendTextureSize;
	};

	class ShopliveFilterSDKBlendKeepRatioFilter : public ShopliveFilterSDKBlendWithResourceFilter
	{
	public:
		bool initWithMode(ShopliveFilterSDKTextureBlendMode mode);
		bool initWithMode(const char* modeName);

		void setTexSize(int w, int h);

		void flushTexSize();
	protected:
		static ShopliveFilterSDKConstString paramAspectRatioName;
	};

	class ShopliveFilterSDKBlendTileFilter : public ShopliveFilterSDKBlendWithResourceFilter
	{
	public:
		bool initWithMode(ShopliveFilterSDKTextureBlendMode mode);
		bool initWithMode(const char* modeName);
		void render2Texture(ShopliveFilterSDKImageHandlerInterface* handler, GLuint srcTexture, GLuint vertexBufferID);
	protected:
		static ShopliveFilterSDKConstString paramScalingRatioName;
	};

	class ShopliveFilterSDKPixblendFilter : public ShopliveFilterSDKBlendInterface
	{
	public:
		ShopliveFilterSDKPixblendFilter() {}
		~ShopliveFilterSDKPixblendFilter() {}

		virtual bool initWithMode(ShopliveFilterSDKTextureBlendMode mode);
		virtual bool initWithMode(const char* modeName);

		void setBlendColor(float r, float g, float b, float a = 1.0f);

	protected:
		static ShopliveFilterSDKConstString paramBlendColorName;
	};

	class ShopliveFilterSDKBlendWithSelfFilter : public ShopliveFilterSDKBlendInterface
	{
	public:
		ShopliveFilterSDKBlendWithSelfFilter() {}
		~ShopliveFilterSDKBlendWithSelfFilter() {}

		bool initWithMode(ShopliveFilterSDKTextureBlendMode mode);
		bool initWithMode(const char* modeName);

	};

	class ShopliveFilterSDKBlendVignetteFilter : public ShopliveFilterSDKPixblendFilter
	{
	public:
		virtual bool initWithMode(ShopliveFilterSDKTextureBlendMode mode);

		void setVignetteCenter(float x, float y);  //Range: [0, 1], and 0.5 for the center.
		void setVignette(float start, float range); //Range: [0, 1]

	protected:
		static ShopliveFilterSDKConstString paramVignetteCenterName;
		static ShopliveFilterSDKConstString paramVignetteName;
	};

	class ShopliveFilterSDKBlendVignetteNoAlphaFilter : public ShopliveFilterSDKBlendVignetteFilter
	{
		virtual bool initWithMode(ShopliveFilterSDKTextureBlendMode mode);
	};

	class ShopliveFilterSDKBlendVignette2Filter : public ShopliveFilterSDKBlendVignetteFilter
	{
	public:
		virtual bool initWithMode(ShopliveFilterSDKTextureBlendMode mode);
	};

	class ShopliveFilterSDKBlendVignette2NoAlphaFilter : public ShopliveFilterSDKBlendVignetteFilter
	{
	public:
		virtual bool initWithMode(ShopliveFilterSDKTextureBlendMode mode);
	};
}


#endif
