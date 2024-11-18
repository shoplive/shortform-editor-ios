/*
* ShopliveFilterSDKWhiteBalanceAdjust.h
*
*  Created on: 2013-12-26
*      Author: Wang Yang
*/

#ifndef _ShopliveFilterSDKWHITEBALANCE_H_
#define _ShopliveFilterSDKWHITEBALANCE_H_

#include "ShopliveFilterSDKGLFunctions.h"
#include "ShopliveFilterSDKImageFilter.h"
#include "ShopliveFilterSDKImageHandler.h"

namespace ShopliveFilterSDK
{
	class ShopliveFilterSDKWhiteBalanceFilter : public ShopliveFilterSDKImageFilterInterface
	{
	public:
		ShopliveFilterSDKWhiteBalanceFilter(){}
		~ShopliveFilterSDKWhiteBalanceFilter(){}

		void setTemperature(float value); //range: -1~1, 0 for origin
		void setTint(float value);// range 0~5, 1 for origin

		bool init();

	protected:
		static ShopliveFilterSDKConstString paramTemperatureName;
		static ShopliveFilterSDKConstString paramTintName;
	};

	class ShopliveFilterSDKWhiteBalanceFastFilter : public ShopliveFilterSDKImageFilterInterface
	{
	public:
		ShopliveFilterSDKWhiteBalanceFastFilter() : m_temp(0.0f), m_tint(1.0f) {}
		~ShopliveFilterSDKWhiteBalanceFastFilter() {}

		void setTempAndTint(float temp, float tint);

		bool init();

		float getTemp() { return m_temp; }
		float getTint() { return m_tint; }

	protected:
		static ShopliveFilterSDKConstString paramBalanceName;

	private:
		float m_temp, m_tint;
	};

}

#endif
