/*
* ShopliveFilterSDKMultipleEffects.h
*
*  Created on: 2013-12-13
*      Author: Wang Yang
*/

#ifndef _ShopliveFilterSDKDATAPARSINGENGINE_H_
#define _ShopliveFilterSDKDATAPARSINGENGINE_H_

#include "ShopliveFilterSDKMultipleEffects.h"

namespace ShopliveFilterSDK
{
	class ShopliveFilterSDKDataParsingEngine
	{
	public:
		static ShopliveFilterSDKImageFilterInterface* adjustParser(const char* pstr, ShopliveFilterSDKMutipleEffectFilter* fatherFilter = nullptr);
		static ShopliveFilterSDKImageFilterInterface* curveParser(const char* pstr, ShopliveFilterSDKMutipleEffectFilter* fatherFilter = nullptr);
		static ShopliveFilterSDKImageFilterInterface* lomoWithCurveParser(const char* pstr, ShopliveFilterSDKMutipleEffectFilter* fatherFilter = nullptr);
		static ShopliveFilterSDKImageFilterInterface* lomoParser(const char* pstr, ShopliveFilterSDKMutipleEffectFilter* fatherFilter = nullptr);
		static ShopliveFilterSDKImageFilterInterface* blendParser(const char* pstr, ShopliveFilterSDKMutipleEffectFilter* fatherFilter = nullptr);
		static ShopliveFilterSDKImageFilterInterface* vignetteBlendParser(const char* pstr, ShopliveFilterSDKMutipleEffectFilter* fatherFilter = nullptr);
		static ShopliveFilterSDKImageFilterInterface* colorScaleParser(const char* pstr, ShopliveFilterSDKMutipleEffectFilter* fatherFilter = nullptr);
		static ShopliveFilterSDKImageFilterInterface* pixblendParser(const char* pstr, ShopliveFilterSDKMutipleEffectFilter* fatherFilter = nullptr);
		static ShopliveFilterSDKImageFilterInterface* krblendParser(const char* pstr, ShopliveFilterSDKMutipleEffectFilter* fatherFilter = nullptr);
		static ShopliveFilterSDKImageFilterInterface* vignetteParser(const char* pstr, ShopliveFilterSDKMutipleEffectFilter* fatherFilter = nullptr);
		static ShopliveFilterSDKImageFilterInterface* selfblendParser(const char* pstr, ShopliveFilterSDKMutipleEffectFilter* fatherFilter = nullptr);
		static ShopliveFilterSDKImageFilterInterface* colorMulParser(const char* pstr, ShopliveFilterSDKMutipleEffectFilter* fatherFilter = nullptr);
		static ShopliveFilterSDKImageFilterInterface* selectiveColorParser(const char* pstr, ShopliveFilterSDKMutipleEffectFilter* fatherFilter = nullptr);
		static ShopliveFilterSDKImageFilterInterface* blendTileParser(const char* pstr, ShopliveFilterSDKMutipleEffectFilter* fatherFilter = nullptr);
		static ShopliveFilterSDKImageFilterInterface* advancedStyleParser(const char* pstr, ShopliveFilterSDKMutipleEffectFilter* fatherFilter = nullptr);
		static ShopliveFilterSDKImageFilterInterface* beautifyParser(const char* pstr, ShopliveFilterSDKMutipleEffectFilter* fatherFilter = nullptr);
		static ShopliveFilterSDKImageFilterInterface* blurParser(const char* pstr, ShopliveFilterSDKMutipleEffectFilter* fatherFilter = nullptr);
		static ShopliveFilterSDKImageFilterInterface* dynamicParser(const char* pstr, ShopliveFilterSDKMutipleEffectFilter* fatherFilter = nullptr);

	};

}
#endif /* _ShopliveFilterSDKDATAPARSINGENGINE_H_ */
