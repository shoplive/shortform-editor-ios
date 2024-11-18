/*
 * ShopliveFilterSDKMultipleEffectsCommon.h
 *
 *  Created on: 2014-1-2
 *      Author: Wang Yang
 */

#ifndef _ShopliveFilterSDKMUTIPLEEFFECTSCOMMON_H_
#define _ShopliveFilterSDKMUTIPLEEFFECTSCOMMON_H_

#include "ShopliveFilterSDKGLFunctions.h"
#include "ShopliveFilterSDKCurveAdjust.h"

namespace ShopliveFilterSDK
{
	void ShopliveFilterSDKEnableColorScale();
	void ShopliveFilterSDKDisableColorScale();	

	//////////////////////////////////////////////////////////////////////////

	class ShopliveFilterSDKLomoFilter : public ShopliveFilterSDKImageFilterInterface
	{
	public:
		ShopliveFilterSDKLomoFilter() : m_scaleDark(-1.0f), m_scaleLight(-1.0f), m_saturate(1.0f) {}

		bool init();

		void setVignette(float start, float end);
		void setIntensity(float value);
		void setSaturation(float value);
		void setColorScale(float low, float range);

		void render2Texture(ShopliveFilterSDKImageHandlerInterface* handler, GLuint srcTexture, GLuint vertexBufferID);


	protected:
		static ShopliveFilterSDKConstString paramColorScaleName;
		static ShopliveFilterSDKConstString paramSaturationName;
		static ShopliveFilterSDKConstString paramVignetteName;
		static ShopliveFilterSDKConstString paramAspectRatio;
		static ShopliveFilterSDKConstString paramIntensityName;

	private:
		GLfloat m_scaleDark, m_scaleLight, m_saturate;
	};

	class ShopliveFilterSDKLomoLinearFilter : public ShopliveFilterSDKLomoFilter
	{
	public:
		bool init();
	};

	//////////////////////////////////////////////////////////////////////////

	class ShopliveFilterSDKLomoWithCurveFilter : public ShopliveFilterSDKMoreCurveFilter
	{
	public:
		ShopliveFilterSDKLomoWithCurveFilter() : m_scaleDark(-1.0f), m_scaleLight(-1.0f), m_saturate(1.0f) {}
		virtual bool init();

		void setVignette(float start, float end);
		void setSaturation(float value);
		void setColorScale(float low, float range);

		void render2Texture(ShopliveFilterSDKImageHandlerInterface* handler, GLuint srcTexture, GLuint vertexBufferID);

	protected:
		static ShopliveFilterSDKConstString paramColorScaleName;
		static ShopliveFilterSDKConstString paramSaturationName;
		static ShopliveFilterSDKConstString paramVignetteName;
		static ShopliveFilterSDKConstString paramAspectRatio;

	private:
		GLfloat m_scaleDark, m_scaleLight, m_saturate;
	};

	class ShopliveFilterSDKLomoWithCurveLinearFilter : public ShopliveFilterSDKLomoWithCurveFilter
	{
	public:
		bool init();
	};

	//////////////////////////////////////////////////////////////////////////

	class ShopliveFilterSDKLomoWithCurveTexFilter : public ShopliveFilterSDKLomoWithCurveFilter
	{
	public:
		virtual bool init();

		virtual void flush();

	protected:
		void initSampler();

	protected:
		GLuint m_curveTexture;
	};

	class ShopliveFilterSDKLomoWithCurveTexLinearFilter : public ShopliveFilterSDKLomoWithCurveTexFilter
	{
	public:
		bool init();
	};

	//////////////////////////////////////////////////////////////////////////

    //TODO: 重写colorscale filter， 避免CPU方法!
	class ShopliveFilterSDKColorScaleFilter : public ShopliveFilterSDKImageFilterInterface
	{
	public:
		ShopliveFilterSDKColorScaleFilter() : m_scaleDark(-1.0f), m_scaleLight(-1.0f), m_saturate(1.0f) {}
		~ShopliveFilterSDKColorScaleFilter() {}

		virtual bool init();

		void setColorScale(float low, float range);
		//Set saturation value to -1.0 ( < 0.0 ) when your shader program did nothing with this value.
		void setSaturation(float value);

		virtual void render2Texture(ShopliveFilterSDKImageHandlerInterface* handler, GLuint srcTexture, GLuint vertexBufferID);

	protected:
		static ShopliveFilterSDKConstString paramColorScaleName;
		static ShopliveFilterSDKConstString paramSaturationName;
	private:
		GLfloat m_scaleDark, m_scaleLight, m_saturate;
	};

	class ShopliveFilterSDKColorMulFilter : public ShopliveFilterSDKImageFilterInterface
	{
	public:

		enum MulMode { mulFLT, mulVEC, mulMAT };

		bool initWithMode(MulMode mode);

		void setFLT(float value);
		void setVEC(float r, float g, float b);
		void setMAT(float* mat); //The lenth of "mat" must be at least 9.
	protected:
		static ShopliveFilterSDKConstString paramMulName;
	};

}


#endif
