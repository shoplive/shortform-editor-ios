/*
* ShopliveFilterSDKSlideshow.h
*
*  Created on: 2014-9-9
*      Author: Wang Yang
*        Mail: admin@wysaid.org
*/

#if !defined(_ShopliveFilterSDKSLIDESHOW_H_) && !defined(_ShopliveFilterSDK_ONLY_FILTERS_)
#define _ShopliveFilterSDKSLIDESHOW_H_

#include "ShopliveFilterSDKAction.h"
#include "ShopliveFilterSDKAnimation.h"
#include "ShopliveFilterSDKSprite2d.h"
#include "ShopliveFilterSDKScene.h"

namespace ShopliveFilterSDK
{
	typedef AnimationInterfaceAbstract<TimeActionInterfaceAbstract> TimeLineElem;
	typedef TimeLineInterface<TimeLineElem> TimeLine;

	//////////////////////////////////////////////////////////////////////////

	template<class AnimationType, class SpriteType>
	class AnimationLogicSpriteInterface : public AnimationType, public virtual SpriteType
	{
	public:
//		AnimationLogicSpriteInterface() : AnimationType(), SpriteType() {}
		AnimationLogicSpriteInterface(float start, float end) : AnimationType(start, end), SpriteType() {}
		virtual ~AnimationLogicSpriteInterface() {}

		typedef SpriteType SpriteInterfaceType;
		typedef AnimationType AnimationInterfaceType;

		virtual void render()
		{
			for(typename std::vector<TimeLineElem*>::iterator iter = this->m_children2Run.begin(); iter != this->m_children2Run.end(); ++iter)
			{
				(*iter)->_renderWithFather(this);
			}
		}

	protected:

		virtual float _getZ() const 
		{
			return this->getZ();
		}
	};

	typedef AnimationWithChildrenInterface<TimeActionInterfaceAbstract> AnimAncestor;
	typedef AnimationLogicSpriteInterface<AnimAncestor, SpriteInterface2d> AnimLogicSprite2d;
//	typedef AnimationLogicSpriteInterface<AnimAncestor, Sprite2dWith3dSpaceHelper> AnimLogicSprite2dWith3dSpace;
	
}

#include "ShopliveFilterSDKSlideshowSprite2d.h"
//#include "ShopliveFilterSDKSlideshowSprite2dWith3dSpace.h"


#endif
