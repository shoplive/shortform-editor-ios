/*﻿
* ShopliveFilterSDKImageFilter.h
*
*  Created on: 2013-12-13
*      Author: Wang Yang
*/

#ifndef _ShopliveFilterSDKIMAGEFILTER_H_
#define _ShopliveFilterSDKIMAGEFILTER_H_

#include "ShopliveFilterSDKGLFunctions.h"
#include "ShopliveFilterSDKShaderFunctions.h"

#ifndef ShopliveFilterSDK_CURVE_PRECISION
#define ShopliveFilterSDK_CURVE_PRECISION 256
#endif

namespace ShopliveFilterSDK
{

	extern ShopliveFilterSDKConstString g_vshDefault;
	extern ShopliveFilterSDKConstString g_vshDefaultWithoutTexCoord;
	extern ShopliveFilterSDKConstString g_vshDrawToScreen;
	extern ShopliveFilterSDKConstString g_vshDrawToScreenRot90;
	extern ShopliveFilterSDKConstString g_fshDefault;
	extern ShopliveFilterSDKConstString g_fshFastAdjust;
	extern ShopliveFilterSDKConstString g_fshFastAdjustRGB;
	extern ShopliveFilterSDKConstString g_fshCurveMapNoIntensity;

	extern ShopliveFilterSDKConstString g_paramFastAdjustArrayName;
	extern ShopliveFilterSDKConstString g_paramFastAdjustRGBArrayName;
	extern ShopliveFilterSDKConstString g_paramCurveMapTextureName;


	class ShopliveFilterSDKImageHandlerInterface;

	class ShopliveFilterSDKImageFilterInterface;

	class ShopliveFilterSDKImageFilterInterfaceAbstract
	{
	public:
        ShopliveFilterSDKImageFilterInterfaceAbstract();
        virtual ~ShopliveFilterSDKImageFilterInterfaceAbstract();
		virtual void render2Texture(ShopliveFilterSDKImageHandlerInterface* handler, GLuint srcTexture, GLuint vertexBufferID) = 0;

		virtual void setIntensity(float value) {}

		//mutiple effects专有， 若返回为 true， handler在添加filter时会进行拆解。
		virtual bool isWrapper() { return false; }
		virtual std::vector<ShopliveFilterSDKImageFilterInterface*> getFilters(bool bMove = true) { return std::vector<ShopliveFilterSDKImageFilterInterface*>(); }
		
	};

	class ShopliveFilterSDKImageFilterInterface : public ShopliveFilterSDKImageFilterInterfaceAbstract
	{
	public:
		ShopliveFilterSDKImageFilterInterface();
		virtual ~ShopliveFilterSDKImageFilterInterface();

		virtual void render2Texture(ShopliveFilterSDKImageHandlerInterface* handler, GLuint srcTexture, GLuint vertexBufferID);

		//////////////////////////////////////////////////////////////////////////
		bool initShadersFromString(const char* vsh, const char* fsh);
		//bool initShadersFromFile(const char* vshFileName, const char* fshFileName);

		void setAdditionalUniformParameter(UniformParameters* param);
		UniformParameters* getUniformParam() { return m_uniformParam; }

		virtual bool init() { return false; }

		ProgramObject& getProgram() { return m_program; }

		static ShopliveFilterSDKConstString paramInputImageName;
		static ShopliveFilterSDKConstString paramPositionIndexName;

	//protected:
		//////////////////////////////////////////////////////////////////////////
		//virtual bool initVertexShaderFromString(const char* vsh);
		//	virtual bool initVertexShaderFromFile(const char* vshFileName);

		//virtual bool initFragmentShaderFromString(const char* fsh);	
		//	virtual bool initFragmentShaderFromFile(const char* fshFileName);

		//virtual bool finishLoadShaders(); //如果单独调用上方函数初始化，请在结束后调用本函数。	

	protected:
		ProgramObject m_program;

		//See the description of "UniformParameters" to know "How to use it".
		UniformParameters* m_uniformParam;
	};

	class ShopliveFilterSDKFastAdjustFilter : public ShopliveFilterSDKImageFilterInterface
	{
	public:

		typedef struct CurveData
		{
			float data[3];

			float& operator[](int index)
			{
				return data[index];
			}

			const float& operator[](int index) const
			{
				return data[index];
			}
		}CurveData;

		bool init();

	protected:
		static ShopliveFilterSDKConstString paramArray;
		void assignCurveArrays();
		void initCurveArrays();

	protected:
		std::vector<CurveData> m_curve;
	};

	class ShopliveFilterSDKFastAdjustRGBFilter : public ShopliveFilterSDKImageFilterInterface
	{
	public:

		bool init();

	protected:
		static ShopliveFilterSDKConstString paramArrayRGB;
		void assignCurveArray();
		void initCurveArray();

	protected:
		std::vector<float> m_curveRGB;
	};

}

#endif
