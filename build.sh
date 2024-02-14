##/bin/bash
#
#WORKING_DIR=$(pwd)
#DIST_DIR=$(pwd)
#DIST_SDK_DIR="Frameworks/"
#SDK_FILENAME="ShopLiveSDK.xcframework"
#POD_FILENAME="ShopLive.podspec"
##
#rm -rf "${WORKING_DIR}/build/"
#mkdir build
##
#xcodebuild archive -scheme ShopLiveSDK -archivePath "${WORKING_DIR}/build/ios.xcarchive" -sdk iphoneos SKIP_INSTALL=NO BUILD_LIBRARY_FOR_DISTRIBUTION=YES
#xcodebuild archive -scheme ShopLiveSDK -archivePath "${WORKING_DIR}/build/ios_sim.xcarchive" -sdk iphonesimulator SKIP_INSTALL=NO BUILD_LIBRARY_FOR_DISTRIBUTION=YES
##
## XCFramework 생성
#xcodebuild -create-xcframework \
#-framework "${WORKING_DIR}/build/ios.xcarchive/Products/Library/Frameworks/ShopLiveSDK.framework" \
#-framework "${WORKING_DIR}/build/ios_sim.xcarchive/Products/Library/Frameworks/ShopLiveSDK.framework" \
#-output "${WORKING_DIR}/build/ShopLiveSDK.xcframework"
##
#rm -rf "${DIST_DIR}${DIST_SDK_DIR}"
#mkdir "${DIST_DIR}${DIST_SDK_DIR}"
#cp -rf "${WORKING_DIR}/build/${SDK_FILENAME}" "${DIST_DIR}${DIST_SDK_DIR}${SDK_FILENAME}"

WORKING_DIR=$(pwd)
CONFIG_FILES=("config/common/build.config" "config/player/build.config" "config/shortform/build.config")


rm -rf "Frameworks"
mkdir "Frameworks"

for config in ${CONFIG_FILES[@]}; do
  # load config properties
  . $config
  
  rm -rf "${WORKING_DIR}/${DIST_DIR}${DIST_SDK_DIR}"
  mkdir "${WORKING_DIR}/${DIST_DIR}${DIST_SDK_DIR}"
  
  rm -rf "${WORKING_DIR}/${DIST_DIR}/build"
  mkdir "${WORKING_DIR}/${DIST_DIR}/build"
  
#  # build archive
  echo "--------------------"
  echo "${WORKING_DIR}/${BUILD_DIR}"
  echo "--------------------"
  cd "${WORKING_DIR}/${BUILD_DIR}"
  xcodebuild archive -scheme $BUILD_SCHEME -archivePath "${WORKING_DIR}/${DIST_DIR}/build/$DEVICE_ARCHIVE_FILENAME.xcarchive" -sdk iphoneos SKIP_INSTALL=NO BUILD_LIBRARY_FOR_DISTRIBUTION=YES
  xcodebuild archive -scheme $BUILD_SCHEME -archivePath "${WORKING_DIR}/${DIST_DIR}/build/$SIMULATOR_ARCHIVE_FILENAME.xcarchive" -sdk iphonesimulator SKIP_INSTALL=NO BUILD_LIBRARY_FOR_DISTRIBUTION=YES

  cd ${WORKING_DIR}
  
  # build xcframework
  echo "${WORKING_DIR}/${DIST_DIR}/build/$DEVICE_ARCHIVE_FILENAME.xcarchive/Products/Library/Frameworks/$BUILD_SCHEME.framework"
  
  echo "${WORKING_DIR}/${DIST_DIR}/build/$SIMULATOR_ARCHIVE_FILENAME.xcarchive/Products/Library/Frameworks/$BUILD_SCHEME.framework"
  
  xcodebuild -create-xcframework \
  -framework "${WORKING_DIR}/${DIST_DIR}/build/$DEVICE_ARCHIVE_FILENAME.xcarchive/Products/Library/Frameworks/$BUILD_SCHEME.framework" \
  -framework "${WORKING_DIR}/${DIST_DIR}/build/$SIMULATOR_ARCHIVE_FILENAME.xcarchive/Products/Library/Frameworks/$BUILD_SCHEME.framework" \
  -output "${WORKING_DIR}/${DIST_DIR}/build/$SDK_FILENAME"

  cp -rf "${WORKING_DIR}/${DIST_DIR}/build/${SDK_FILENAME}" "${WORKING_DIR}${DIST_SDK_DIR}/${SDK_FILENAME}"
done
