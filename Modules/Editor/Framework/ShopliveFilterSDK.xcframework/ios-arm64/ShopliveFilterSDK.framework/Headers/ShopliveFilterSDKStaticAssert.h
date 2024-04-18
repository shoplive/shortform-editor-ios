/*
@Author: wysaid
@Blog: blog.wysaid.org
@Date: 2013-10-31
*/

#ifndef _ShopliveFilterSDK_STATICASSERT_H_
#define _ShopliveFilterSDK_STATICASSERT_H_

#ifndef _ShopliveFilterSDK_STATIC_ASSERT_

#define ShopliveFilterSDKStaticAssert(value) static_assert(value, "Invalid Parameters!")

#else

#if defined(DEBUG) || defined(_DEBUG)

template<bool K>
struct _ShopliveFilterSDKStaticAssert ;

template<>
struct _ShopliveFilterSDKStaticAssert<true> { int dummy; };

template<int n>
struct __ShopliveFilterSDKStaticAssert {};

#define ShopliveFilterSDKStaticAssert(value) do \
{\
	typedef __ShopliveFilterSDKStaticAssert<\
	sizeof(_ShopliveFilterSDKStaticAssert<(bool)(value)>)\
	> ___ShopliveFilterSDKStaticAssert;\
} while (0)

#else

#define ShopliveFilterSDKStaticAssert(...) 

#endif

#endif

#endif //_ShopliveFilterSDK_STATICASSERT_H_
