/*
 * ShopliveFilterSDKMultipleEffects.h
 *
 *  Created on: 2013-12-13
 *      Author: Wang Yang
 *        Blog: http://wysaid.org
*/

#ifndef _ShopliveFilterSDKMUTIPLEEFFECTS_H_
#define _ShopliveFilterSDKMUTIPLEEFFECTS_H_

#include "ShopliveFilterSDKGLFunctions.h"

namespace ShopliveFilterSDK
{
	//It's just a help class for ShopliveFilterSDKMutipleEffectFilter.
	class ShopliveFilterSDKMutipleMixFilter : protected ShopliveFilterSDKImageFilterInterface
	{
	public:
		ShopliveFilterSDKMutipleMixFilter() {}

		void setIntensity(float value);

		bool init();

		void render2Texture(ShopliveFilterSDKImageHandlerInterface* handler, GLuint srcTexture, GLuint vertexBufferID);

		bool needToMix();

		bool noIntensity();

	protected:
		static ShopliveFilterSDKConstString paramIntensityName;
		static ShopliveFilterSDKConstString paramOriginImageName;
		
	private:
		float m_intensity;
	};


	//This class is inherited from top filter interface and would do more processing steps
	// than "ShopliveFilterSDKImageFilter" does.
	class ShopliveFilterSDKMutipleEffectFilter : public ShopliveFilterSDKImageFilterInterfaceAbstract
	{
	public:	
		ShopliveFilterSDKMutipleEffectFilter();
		~ShopliveFilterSDKMutipleEffectFilter();

		void setBufferLoadFunction(ShopliveFilterSDKBufferLoadFun fLoad, void* loadParam, ShopliveFilterSDKBufferUnloadFun fUnload, void* unloadParam);
		void setTextureLoadFunction(ShopliveFilterSDKTextureLoadFun texLoader, void* arg);

		// bool initWithEffectID(int index);
		bool initWithEffectString(const char* pstr);
		bool initCustomize(); //特殊用法， 自由组合

		void setIntensity(float value); //设置混合程度
		bool isEmpty() { return m_vecFilters.empty(); }
		void clearFilters();

		bool isWrapper() { return m_isWrapper; }
		std::vector<ShopliveFilterSDKImageFilterInterface*> getFilters(bool bMove = true);

        std::vector<ShopliveFilterSDKImageFilterInterface*>& vecFilters()
        {
            return m_vecFilters;
        }
        
		//////////////////////////////////////////////////////////////////////////

		void render2Texture(ShopliveFilterSDKImageHandlerInterface* handler, GLuint srcTexture, GLuint vertexBufferID);

		void addFilter(ShopliveFilterSDKImageFilterInterface* proc) { if(proc != nullptr) m_vecFilters.push_back(proc); }	

		GLuint loadResources(const char* textureName, int* w = nullptr, int* h = nullptr);

		ShopliveFilterSDKBufferLoadFun getLoadFunc() { return m_loadFunc; };
		ShopliveFilterSDKBufferUnloadFun getUnloadFunc() { return m_unloadFunc; }
		ShopliveFilterSDKTextureLoadFun getTexLoadFunc() { return m_texLoadFunc; }
		void* getLoadParam() { return m_loadParam; }
		void* getUnloadParam() { return m_unloadParam; }
		void* getTexLoadParam() { return m_texLoadParam; }
	protected:
		ShopliveFilterSDKBufferLoadFun m_loadFunc;
		ShopliveFilterSDKBufferUnloadFun m_unloadFunc;
		ShopliveFilterSDKTextureLoadFun m_texLoadFunc;
		void* m_loadParam;
		void* m_unloadParam;
		void* m_texLoadParam;
		std::vector<ShopliveFilterSDKImageFilterInterface*> m_vecFilters;
		ShopliveFilterSDKMutipleMixFilter m_mixFilter;
		
		ShopliveFilterSDKSizei m_currentSize;
		GLuint m_texCache;
		bool m_isWrapper;
	};
}


#endif /* _ShopliveFilterSDKMUTIPLEEFFECTS_H_ */
