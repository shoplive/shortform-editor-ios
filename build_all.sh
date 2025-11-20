##/bin/bash

WORKING_DIR=$(pwd)

# ============================================
# 버전 검증 함수
# ============================================
validate_version_consistency() {
    echo "🔍 버전 일치성 검사 시작..."
    
    # Swift 파일 경로
    SWIFT_FILE="Modules/Common/Sources/ShopliveSDKCommon.swift"
    
    # Swift 파일 존재 확인
    if [ ! -f "$SWIFT_FILE" ]; then
        echo "❌ Swift 파일을 찾을 수 없습니다: $SWIFT_FILE"
        exit 1
    fi
    
    # Swift 파일에서 버전 추출
    SWIFT_VERSION=$(grep -m1 'return "' "$SWIFT_FILE" | sed 's/.*return "\([^"]*\)".*/\1/')
    
    if [ -z "$SWIFT_VERSION" ]; then
        echo "❌ Swift 파일에서 버전을 찾을 수 없습니다."
        echo "💡 ShopliveSDKCommon.swift 파일의 버전 형식을 확인해주세요."
        exit 1
    fi
    
    echo "📋 Swift 파일 버전: $SWIFT_VERSION"
    
    # 해당 버전의 Git 태그가 존재하는지 확인
    if git show-ref --tags --quiet --verify "refs/tags/$SWIFT_VERSION"; then
        echo "✅ Git 태그 확인됨: $SWIFT_VERSION"
    else
        echo ""
        echo "❌ 해당 버전의 Git 태그를 찾을 수 없습니다!"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo "📄 Swift 파일 버전: $SWIFT_VERSION"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo ""
        echo "💡 해결 방법:"
        echo "1. 태그 생성:"
        echo "   git tag $SWIFT_VERSION"
        echo ""
        echo "2. 또는 Swift 파일 버전 수정:"
        echo "   (현재 존재하는 태그로 수정)"
        echo ""
        exit 1
    fi
    
    echo "✅ 버전 일치성 검사 통과!"
    echo "🎯 빌드할 버전: $SWIFT_VERSION"
    echo ""
}

# 버전 검증 실행
validate_version_consistency

CONFIG_FILES=("config/player/build.config" "config/common/build.config"  "config/shortform/build.config" "config/editor/build.config" )

rm -rf "SLXCFrameworks"
mkdir "SLXCFrameworks"

# Distribution 폴더 정리
echo "🧹 Distribution 폴더 정리 중..."
rm -rf "Distribution"
mkdir -p "Distribution"

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

# ============================================
# 최신 코드 업데이트 (ios-sdk, shortform-ios, common-ios, shortform-editor-ios)
# ============================================
echo "🔄 로컬 저장소 main 확인 및 업데이트 중..."

DEPENDENCY_DIRS=("ios-sdk" "shortform-ios" "common-ios" "shortform-editor-ios")

for dir in "${DEPENDENCY_DIRS[@]}"; do
  TARGET_PATH="${WORKING_DIR}/../${dir}"
  
  if [ -d "$TARGET_PATH" ]; then
    echo "--------------------------------------------"
    echo "📂 Checking $dir..."
    
    cd "$TARGET_PATH" || exit 1
    
    # main 브랜치 체크아웃
    CURRENT_BRANCH=$(git symbolic-ref --short HEAD)
    if [ "$CURRENT_BRANCH" != "main" ]; then
      echo "  🔀 'main' 브랜치로 전환 중... (현재: $CURRENT_BRANCH)"
      git checkout main
      if [ $? -ne 0 ]; then
        echo "  ❌ 오류: 'main' 브랜치 체크아웃 실패. ($dir)"
        exit 1
      fi
    fi
    
    # git pull 실행 (변경 사항이 있을 때만)
    echo "  📡 원격 저장소 확인 중..."
    git fetch origin main
    
    LOCAL_HASH=$(git rev-parse HEAD)
    REMOTE_HASH=$(git rev-parse origin/main)
    
    if [ "$LOCAL_HASH" != "$REMOTE_HASH" ]; then
      echo "  ⬇️  새로운 변경 사항이 있습니다. 업데이트를 진행합니다..."
      git pull origin main
      if [ $? -ne 0 ]; then
        echo "  ❌ 오류: git pull 실패 (충돌 가능성). 작업을 중단합니다. ($dir)"
        exit 1
      fi
    else
      echo "  ✨ 이미 최신 상태입니다."
    fi
    
    cd "$WORKING_DIR"
  else
    echo "⚠️  경고: $dir 폴더를 찾을 수 없습니다. (${TARGET_PATH})"
  fi
done

echo "✅ 모든 저장소 main 최신화 완료!"
echo ""

# ============================================
# podspec 파일 버전 업데이트
# ============================================
echo "📝 podspec 파일 버전 업데이트 중..."

# 현재 버전 설정 (SWIFT_VERSION 사용)
CURRENT_VERSION="$SWIFT_VERSION"

if [ -z "$CURRENT_VERSION" ]; then
  echo "❌ 오류: 버전 정보를 찾을 수 없습니다."
  exit 1
fi

echo "🎯 업데이트할 버전: $CURRENT_VERSION"

for dir in "${DEPENDENCY_DIRS[@]}"; do
  TARGET_PATH="${WORKING_DIR}/../${dir}"
  
  if [ -d "$TARGET_PATH" ]; then
    echo "--------------------------------------------"
    echo "📂 Updating podspec in $dir..."
    
    # 해당 디렉토리에서 .podspec 파일 찾기
    PODSPEC_FILES=$(find "$TARGET_PATH" -maxdepth 1 -name "*.podspec" -type f)
    
    if [ -z "$PODSPEC_FILES" ]; then
      echo "  ⚠️  경고: podspec 파일을 찾을 수 없습니다. ($dir)"
      continue
    fi
    
    for podspec_file in $PODSPEC_FILES; do
      PODSPEC_NAME=$(basename "$podspec_file")
      echo "  📋 업데이트 중: $PODSPEC_NAME"
      
      # spec.version 라인 찾아서 수정
      # 형식: spec.version      = "1.8.0" 또는 spec.version = "1.8.0"
      # macOS와 Linux 모두 호환되는 sed 명령어 사용
      if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS - spec.version 다음 공백 여러 개, =, 공백, 따옴표 안의 값 교체
        sed -i '' "s/\(spec\.version[[:space:]]*=[[:space:]]*\"\)[^\"]*\(\"\)/\1${CURRENT_VERSION}\2/" "$podspec_file"
      else
        # Linux
        sed -i "s/\(spec\.version[[:space:]]*=[[:space:]]*\"\)[^\"]*\(\"\)/\1${CURRENT_VERSION}\2/" "$podspec_file"
      fi
      
      if [ $? -eq 0 ]; then
        # 업데이트 확인을 위해 변경된 라인 출력
        UPDATED_LINE=$(grep "spec.version" "$podspec_file")
        echo "    ✅ 업데이트 완료: $PODSPEC_NAME"
        echo "       $UPDATED_LINE"
      else
        echo "    ❌ 오류: $PODSPEC_NAME 업데이트 실패"
      fi
    done
  else
    echo "⚠️  경고: $dir 폴더를 찾을 수 없습니다. (${TARGET_PATH})"
  fi
done

echo ""
echo "✅ podspec 파일 버전 업데이트 완료!"
echo ""


# ============================================
# dSYM 파일 추출
# ============================================
echo "📦 dSYM 파일 추출 중..."

DSYM_DIR="Distribution/shoplive-ios-dysm"
mkdir -p "${DSYM_DIR}"

# dSYM 추출 정보: (빌드 폴더, 아카이브 파일명, dSYM 파일명)
declare -a DSYM_EXTRACTS=(
  "CommonBuild:common-ios:ShopliveSDKCommon.framework.dSYM"
  "PlayerBuild:player-ios:ShopLiveSDK.framework.dSYM"
  "EditorBuild:shortform-editor-ios:ShopLiveShortformEditorSDK.framework.dSYM"
  "ShortformBuild:shortform-ios:ShopLiveShortformSDK.framework.dSYM"
)

for extract_info in "${DSYM_EXTRACTS[@]}"; do
  IFS=':' read -r build_dir archive_name dsym_name <<< "$extract_info"
  
  ARCHIVE_PATH="${WORKING_DIR}/${build_dir}/build/${archive_name}.xcarchive"
  DSYM_SOURCE_PATH="${ARCHIVE_PATH}/dSYMs/${dsym_name}"
  DSYM_TARGET_PATH="${DSYM_DIR}/${dsym_name}"
  
  if [ -d "$DSYM_SOURCE_PATH" ]; then
    echo "  📋 추출 중: $dsym_name"
    cp -rf "$DSYM_SOURCE_PATH" "${DSYM_TARGET_PATH}"
  else
    echo "  ⚠️  경고: $dsym_name를 찾을 수 없습니다. (${DSYM_SOURCE_PATH})"
  fi
done

echo ""
echo "✅ dSYM 파일 추출 완료!"
echo "📁 대상 폴더: ${DSYM_DIR}"
echo ""

echo ""
echo "🎉 모든 빌드가 성공적으로 완료되었습니다!"
echo "📦 생성된 프레임워크: Distribution/"
echo "🏷️  빌드 버전: $TAG_VERSION"
echo ""

