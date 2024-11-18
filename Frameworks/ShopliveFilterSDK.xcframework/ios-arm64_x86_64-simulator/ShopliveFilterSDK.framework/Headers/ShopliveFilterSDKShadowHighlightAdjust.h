/*
 * ShopliveFilterSDKShadowHighlightAdjust.h
 *
 *  Created on: 2013-12-26
 *      Author: Wang Yang
 */

#ifndef _ShopliveFilterSDKSHADOWHIGHLIGHT_H_
#define _ShopliveFilterSDKSHADOWHIGHLIGHT_H_

#include "ShopliveFilterSDKGLFunctions.h"
#include "ShopliveFilterSDKImageHandler.h"

namespace ShopliveFilterSDK
{
	class ShopliveFilterSDKShadowHighlightFilter : public ShopliveFilterSDKImageFilterInterface
	{
	public:
		ShopliveFilterSDKShadowHighlightFilter(){}
		~ShopliveFilterSDKShadowHighlightFilter(){}

		void setShadow(float value); // range [-200, 100]
		void setHighlight(float value); // range [-100, 200]

		bool init();

	protected:
		static ShopliveFilterSDKConstString paramShadowName;
		static ShopliveFilterSDKConstString paramHighlightName;

	private:
	};

	class ShopliveFilterSDKShadowHighlightFastFilter : public ShopliveFilterSDKFastAdjustRGBFilter
	{
	public:
		ShopliveFilterSDKShadowHighlightFastFilter() : m_shadow(0.0f), m_highlight(0.0f) {}
		~ShopliveFilterSDKShadowHighlightFastFilter() {}

		void setShadowAndHighlight(float shadow, float highlight); //the same to above.

		bool init();

		float getShadow() { return m_shadow; }
		float getHighlight() { return m_highlight; }

	private:
		float m_shadow, m_highlight;
	};

}

#endif
