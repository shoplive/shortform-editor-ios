##/bin/bash

WORKING_DIR=$(pwd)
CONFIG_FILES=("config/common/build.config" )

rm -rf "SLXCFrameworks"
mkdir "SLXCFrameworks"

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
