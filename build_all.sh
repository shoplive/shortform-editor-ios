##/bin/bash

WORKING_DIR=$(pwd)

# ============================================
# tuist clean / install / generate
# ============================================
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "⚙️  Tuist 프로젝트 초기화"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

echo "🧹 tuist clean 실행 중..."
tuist clean
if [ $? -ne 0 ]; then
  echo "❌ tuist clean 실패"
  exit 1
fi

echo "📦 tuist install 실행 중..."
tuist install
if [ $? -ne 0 ]; then
  echo "❌ tuist install 실패"
  exit 1
fi

echo "🔧 tuist generate 실행 중..."
tuist generate
if [ $? -ne 0 ]; then
  echo "❌ tuist generate 실패"
  exit 1
fi

echo "✅ Tuist 초기화 완료!"
echo ""

# ============================================
# 버전 업데이트 함수
# ============================================
update_version_files() {
    local VERSION=$1
    
    echo "🔄 버전 파일 업데이트 중..."
    
    # XCConfigs/version.xcconfig 업데이트
    XCCONFIG_FILE="XCConfigs/version.xcconfig"
    if [ -f "$XCCONFIG_FILE" ]; then
        echo "  📝 $XCCONFIG_FILE 업데이트 중..."
        # macOS와 Linux 호환성을 위해 sed 명령어 분리
        if [[ "$OSTYPE" == "darwin"* ]]; then
            # macOS
            sed -i '' "s/^SL_APP_MARKETING_VERSION = .*/SL_APP_MARKETING_VERSION = $VERSION/" "$XCCONFIG_FILE"
            sed -i '' "s/^SL_STUDIO_APP_MARKETING_VERSION = .*/SL_STUDIO_APP_MARKETING_VERSION = $VERSION/" "$XCCONFIG_FILE"
        else
            # Linux
            sed -i "s/^SL_APP_MARKETING_VERSION = .*/SL_APP_MARKETING_VERSION = $VERSION/" "$XCCONFIG_FILE"
            sed -i "s/^SL_STUDIO_APP_MARKETING_VERSION = .*/SL_STUDIO_APP_MARKETING_VERSION = $VERSION/" "$XCCONFIG_FILE"
        fi
        echo "  ✅ $XCCONFIG_FILE 업데이트 완료"
    else
        echo "  ⚠️  경고: $XCCONFIG_FILE를 찾을 수 없습니다."
        exit 1
    fi
    
    # Modules/Common/Sources/ShopliveSDKCommon.swift 업데이트
    SWIFT_FILE="Modules/Common/Sources/ShopliveSDKCommon.swift"
    if [ -f "$SWIFT_FILE" ]; then
        echo "  📝 $SWIFT_FILE 업데이트 중..."
        # 패턴 매칭을 사용하여 버전 문자열 찾아 업데이트 (return "버전" 형식)
        if [[ "$OSTYPE" == "darwin"* ]]; then
            # macOS - 확장 정규식 사용
            sed -i '' -E 's/return "[0-9]+\.[0-9]+\.[0-9]+(\.[0-9]+)?"/return "'"$VERSION"'"/g' "$SWIFT_FILE"
        else
            # Linux - 확장 정규식 사용
            sed -i -E 's/return "[0-9]+\.[0-9]+\.[0-9]+(\.[0-9]+)?"/return "'"$VERSION"'"/g' "$SWIFT_FILE"
        fi
        echo "  ✅ $SWIFT_FILE 업데이트 완료"
    else
        echo "  ⚠️  경고: $SWIFT_FILE를 찾을 수 없습니다."
        exit 1
    fi
    
    echo "✅ 모든 버전 파일 업데이트 완료!"
    echo ""
}

# ============================================
# 버전 검증 함수
# ============================================
validate_version_consistency() {
    local EXPECTED_VERSION=$1
    
    if [ -z "$EXPECTED_VERSION" ]; then
        echo "❌ 검증할 버전이 제공되지 않았습니다."
        exit 1
    fi
    
    echo "🔍 버전 일치성 검사 시작..."
    
    # Swift 파일 경로
    SWIFT_FILE="Modules/Common/Sources/ShopliveSDKCommon.swift"
    
    # Swift 파일 존재 확인
    if [ ! -f "$SWIFT_FILE" ]; then
        echo "❌ Swift 파일을 찾을 수 없습니다: $SWIFT_FILE"
        exit 1
    fi
    
    # Swift 파일에서 첫 번째 버전 추출 (검증용)
    SWIFT_VERSION=$(grep -m1 'return "' "$SWIFT_FILE" | sed 's/.*return "\([^"]*\)".*/\1/')
    
    if [ -z "$SWIFT_VERSION" ]; then
        echo "❌ Swift 파일에서 버전을 찾을 수 없습니다."
        echo "💡 ShopliveSDKCommon.swift 파일의 버전 형식을 확인해주세요."
        exit 1
    fi
    
    echo "📋 예상 버전: $EXPECTED_VERSION"
    echo "📋 Swift 파일 버전: $SWIFT_VERSION"
    
    # 버전 비교
    if [ "$EXPECTED_VERSION" != "$SWIFT_VERSION" ]; then
        echo ""
        echo "❌ 버전 불일치 발견!"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo "📋 예상 버전: $EXPECTED_VERSION"
        echo "📄 Swift 파일: $SWIFT_VERSION"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo ""
        echo "💡 Swift 파일의 버전이 예상한 버전과 일치하지 않습니다."
        echo "   버전 업데이트가 제대로 되지 않았을 수 있습니다."
        echo ""
        exit 1
    fi
    
    echo "✅ 버전 일치성 검사 통과!"
    echo "🎯 빌드할 버전: $EXPECTED_VERSION"
    echo ""
}

# ============================================
# 배포 버전 선택
# ============================================
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📝 배포 버전 선택"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# 최신 태그 자동 조회 (ebay 제외, 숫자로 시작)
CURRENT_TAG=$(git tag -l | grep -v '^ebay' | grep -E '^[0-9]+\.[0-9]+\.[0-9]+$' | sort -V | tail -n 1)

if [ -z "$CURRENT_TAG" ]; then
  echo "❌ 기존 태그를 찾을 수 없습니다."
  exit 1
fi

echo "🏷️  현재 최신 버전: $CURRENT_TAG"
echo ""

# 버전 파싱
IFS='.' read -r V1 V2 V3 V4 <<< "$CURRENT_TAG"

# 옵션 1: 일반 배포 (V3 +1, V4 제거)
OPTION_RELEASE="${V1}.${V2}.$((V3 + 1))"

# 옵션 2: 핫픽스 (V4 추가 또는 +1)
if [ -n "$V4" ]; then
  OPTION_HOTFIX="${V1}.${V2}.${V3}.$((V4 + 1))"
else
  OPTION_HOTFIX="${V1}.${V2}.${V3}.1"
fi

echo "배포 유형을 선택해주세요:"
echo "  1) 일반 배포  → $OPTION_RELEASE"
echo "  2) 핫픽스     → $OPTION_HOTFIX"
echo "  3) 직접 입력"
echo ""
read -r VERSION_CHOICE
VERSION_CHOICE=$(echo "$VERSION_CHOICE" | xargs)

case "$VERSION_CHOICE" in
  1)
    DEPLOY_VERSION="$OPTION_RELEASE"
    ;;
  2)
    DEPLOY_VERSION="$OPTION_HOTFIX"
    ;;
  3)
    echo "배포할 버전을 입력해주세요. (예: 1.8.0 또는 1.8.0.1)"
    read -r DEPLOY_VERSION
    DEPLOY_VERSION=$(echo "$DEPLOY_VERSION" | xargs)
    if [ -z "$DEPLOY_VERSION" ]; then
      echo "❌ 버전이 입력되지 않았습니다."
      exit 1
    fi
    ;;
  *)
    echo "❌ 잘못된 선택입니다. (1, 2, 3 중 하나를 입력해주세요.)"
    exit 1
    ;;
esac

echo ""
echo "📋 선택된 배포 버전: $DEPLOY_VERSION"

# 버전 형식 검증 (3개 또는 4개 숫자: 1.2.3 또는 1.2.3.4 형식)
if ! [[ "$DEPLOY_VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+(\.[0-9]+)?$ ]]; then
  echo "❌ 잘못된 버전 형식입니다. (예: 1.8.0 또는 1.8.0.1)"
  exit 1
fi

echo ""
echo "📋 입력된 배포 버전: $DEPLOY_VERSION"
echo ""

# 버전 파일 업데이트
update_version_files "$DEPLOY_VERSION"

# 업데이트된 버전으로 TAG_VERSION 설정
TAG_VERSION="$DEPLOY_VERSION"
LATEST_TAG="$DEPLOY_VERSION"

# 버전 검증 (파라미터로 전달받은 버전과 파일에 업데이트된 버전이 일치하는지 확인)
validate_version_consistency "$DEPLOY_VERSION"

# Git 커밋 (변경사항이 있을 때만)
echo "📝 Git 커밋 중..."
if [ -n "$(git status --porcelain)" ]; then
  echo "  📋 변경사항 발견, 커밋 진행..."
  git add .
  if [ $? -ne 0 ]; then
    echo "  ❌ git add 실패"
    exit 1
  fi
  
  COMMIT_MESSAGE="version $DEPLOY_VERSION"
  git commit -m "$COMMIT_MESSAGE"
  if [ $? -eq 0 ]; then
    echo "  ✅ 커밋 완료: $COMMIT_MESSAGE"
  else
    echo "  ❌ 커밋 실패"
    exit 1
  fi
else
  echo "  ℹ️  변경사항이 없어 커밋을 건너뜁니다."
fi

# Git 태그 생성
echo ""
echo "🏷️  Git 태그 생성 중..."
if git rev-parse "$LATEST_TAG" >/dev/null 2>&1; then
  echo "  ⚠️  태그가 이미 존재합니다: $LATEST_TAG"
  echo "  💡 기존 태그를 사용합니다."
else
  echo "  📝 새 태그 생성: $LATEST_TAG"
  git tag "$LATEST_TAG"
  if [ $? -eq 0 ]; then
    echo "  ✅ 태그 생성 완료: $LATEST_TAG"
  else
    echo "  ❌ 태그 생성 실패"
    exit 1
  fi
fi

echo ""
echo "✅ 버전 업데이트, 커밋 및 태그 생성 완료!"
echo "🎯 빌드할 버전: $TAG_VERSION"
echo "🏷️  태그: $LATEST_TAG"
echo ""

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

# 현재 버전 설정 (TAG_VERSION 사용)
CURRENT_VERSION="$TAG_VERSION"

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
      # 형식: spec.version = "1.8.0" 또는 spec.version = '1.8.0'
      # macOS와 Linux 모두 호환되는 sed 명령어 사용
      if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS - 큰따옴표와 작은따옴표 모두 처리
        # 큰따옴표 처리
        sed -i '' "s/^\([[:space:]]*spec\.version[[:space:]]*=[[:space:]]*\"\)[^\"]*\(\"\)/\1${CURRENT_VERSION}\2/" "$podspec_file"
        # 작은따옴표 처리
        sed -i '' "s/^\([[:space:]]*spec\.version[[:space:]]*=[[:space:]]*'\)[^']*\('\)/\1${CURRENT_VERSION}\2/" "$podspec_file"
      else
        # Linux
        # 큰따옴표 처리
        sed -i "s/^\([[:space:]]*spec\.version[[:space:]]*=[[:space:]]*\"\)[^\"]*\(\"\)/\1${CURRENT_VERSION}\2/" "$podspec_file"
        # 작은따옴표 처리
        sed -i "s/^\([[:space:]]*spec\.version[[:space:]]*=[[:space:]]*'\)[^']*\('\)/\1${CURRENT_VERSION}\2/" "$podspec_file"
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
# xcframework 복사
# ============================================
echo "📦 xcframework 파일 복사 중..."

# xcframework 매핑: (소스 파일명, 대상 디렉토리, frameworks 폴더명)
declare -a XCFRAMEWORK_MAPPINGS=(
  "ShopliveSDKCommon.xcframework:common-ios:frameworks"
  "ShopLiveSDK.xcframework:ios-sdk:frameworks"
  "ShopLiveShortformSDK.xcframework:shortform-ios:frameworks"
  "ShopLiveShortformEditorSDK.xcframework:shortform-editor-ios:Frameworks"
)

for mapping in "${XCFRAMEWORK_MAPPINGS[@]}"; do
  IFS=':' read -r framework_name target_dir frameworks_dir <<< "$mapping"
  
  SOURCE_PATH="${WORKING_DIR}/SLXCFrameworks/${framework_name}"
  TARGET_BASE_PATH="${WORKING_DIR}/../${target_dir}"
  TARGET_FRAMEWORKS_DIR="${TARGET_BASE_PATH}/${frameworks_dir}"
  TARGET_PATH="${TARGET_FRAMEWORKS_DIR}/${framework_name}"
  
  if [ ! -d "$SOURCE_PATH" ]; then
    echo "  ⚠️  경고: $framework_name를 찾을 수 없습니다. (${SOURCE_PATH})"
    continue
  fi
  
  if [ ! -d "$TARGET_BASE_PATH" ]; then
    echo "  ⚠️  경고: 대상 디렉토리를 찾을 수 없습니다. (${TARGET_BASE_PATH})"
    continue
  fi
  
  # frameworks 폴더가 없으면 생성
  if [ ! -d "$TARGET_FRAMEWORKS_DIR" ]; then
    echo "  📁 frameworks 폴더 생성: ${TARGET_FRAMEWORKS_DIR}"
    mkdir -p "$TARGET_FRAMEWORKS_DIR"
  fi
  
  # 기존 xcframework가 있으면 삭제
  if [ -d "$TARGET_PATH" ]; then
    echo "  🗑️  기존 $framework_name 삭제 중..."
    rm -rf "$TARGET_PATH"
  fi
  
  # xcframework 복사
  echo "  📋 복사 중: $framework_name → ${target_dir}/${frameworks_dir}/"
  cp -rf "$SOURCE_PATH" "$TARGET_PATH"
  
  if [ $? -eq 0 ]; then
    echo "    ✅ 복사 완료: $framework_name"
  else
    echo "    ❌ 복사 실패: $framework_name"
    exit 1
  fi
done

echo ""
echo "✅ xcframework 파일 복사 완료!"
echo ""

# ============================================
# 각 레포지토리에서 커밋, 태그, pod 업로드
# ============================================
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📤 각 레포지토리 커밋, 태그 및 pod 업로드"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# 레포지토리별 작업 정의: (디렉토리명, podspec 파일명, pod 업로드 여부)
declare -a REPO_TASKS=(
  "common-ios:ShopliveSDKCommon.podspec:true"
  "ios-sdk:ShopLive.podspec:true"
  "shortform-ios:ShopliveShortformSDK.podspec:true"
  "shortform-editor-ios:ShopLiveShortformEditorSDK.podspec:false"
)

FAILED_REPOS=()

for task in "${REPO_TASKS[@]}"; do
  IFS=':' read -r repo_dir podspec_name should_push_pod <<< "$task"
  
  REPO_PATH="${WORKING_DIR}/../${repo_dir}"
  
  if [ ! -d "$REPO_PATH" ]; then
    echo "⚠️  경고: $repo_dir 폴더를 찾을 수 없습니다. (${REPO_PATH})"
    continue
  fi
  
  echo "--------------------------------------------"
  echo "📂 Processing $repo_dir..."
  echo "--------------------------------------------"
  
  cd "$REPO_PATH" || {
    echo "  ❌ 오류: 디렉토리 이동 실패. ($repo_dir)"
    FAILED_REPOS+=("$repo_dir")
    continue
  }
  
  # 현재 브랜치 확인 및 main으로 전환
  CURRENT_BRANCH=$(git symbolic-ref --short HEAD 2>/dev/null || echo "")
  if [ -z "$CURRENT_BRANCH" ] || [ "$CURRENT_BRANCH" != "main" ]; then
    echo "  🔀 'main' 브랜치로 전환 중... (현재: ${CURRENT_BRANCH:-unknown})"
    if ! git checkout main 2>&1 && ! git checkout -b main 2>&1; then
      echo "  ❌ 오류: 'main' 브랜치 체크아웃 실패. ($repo_dir)"
      cd "$WORKING_DIR"
      FAILED_REPOS+=("$repo_dir")
      continue
    fi
  fi
  
  # 변경사항 확인
  if [ -z "$(git status --porcelain)" ]; then
    echo "  ℹ️  변경사항이 없어 커밋을 건너뜁니다."
  else
    # Git 커밋
    echo "  📝 Git 커밋 중..."
    git add .
    git commit -m "framework changed"
    
    if [ $? -ne 0 ]; then
      echo "  ❌ 커밋 실패"
      cd "$WORKING_DIR"
      FAILED_REPOS+=("$repo_dir")
      continue
    fi
    echo "  ✅ 커밋 완료"
    
    # Git 태그 생성
    echo "  🏷️  Git 태그 생성 중..."
    if git rev-parse "$TAG_VERSION" >/dev/null 2>&1; then
      echo "    ⚠️  태그가 이미 존재합니다: $TAG_VERSION"
    else
      git tag "$TAG_VERSION"
      if [ $? -eq 0 ]; then
        echo "    ✅ 태그 생성 완료: $TAG_VERSION"
      else
        echo "    ❌ 태그 생성 실패"
        cd "$WORKING_DIR"
        FAILED_REPOS+=("$repo_dir")
        continue
      fi
    fi
    
    # Git 푸시
    echo "  📤 Git 푸시 중..."
    REMOTE_NAME=$(git remote | grep -x "origin" || git remote | head -n1)
    if [ -n "$REMOTE_NAME" ]; then
      git push "$REMOTE_NAME" main
      if [ $? -eq 0 ]; then
        echo "    ✅ 커밋 푸시 완료"
      else
        echo "    ❌ 커밋 푸시 실패"
        cd "$WORKING_DIR"
        FAILED_REPOS+=("$repo_dir")
        continue
      fi
      
      git push "$REMOTE_NAME" "$TAG_VERSION"
      if [ $? -eq 0 ]; then
        echo "    ✅ 태그 푸시 완료: $TAG_VERSION"
      else
        echo "    ❌ 태그 푸시 실패"
        cd "$WORKING_DIR"
        FAILED_REPOS+=("$repo_dir")
        continue
      fi
    else
      echo "    ⚠️  원격 저장소를 찾을 수 없습니다."
    fi
  fi
  
  # Pod 업로드 (pod 업로드가 필요한 경우만)
  if [ "$should_push_pod" = "true" ]; then
    PODSPEC_PATH="${REPO_PATH}/${podspec_name}"
    
    if [ ! -f "$PODSPEC_PATH" ]; then
      echo "  ⚠️  경고: podspec 파일을 찾을 수 없습니다. (${podspec_name})"
      cd "$WORKING_DIR"
      FAILED_REPOS+=("$repo_dir")
      continue
    fi
    
    echo "  📦 Pod 업로드 중: $podspec_name"
    pod trunk push "$PODSPEC_PATH"
    
    if [ $? -eq 0 ]; then
      echo "    ✅ Pod 업로드 완료: $podspec_name"
      
      # Pod 업로드 확인
      echo "    🔍 Pod 업로드 확인 중..."
      # podspec 파일명에서 확장자 제거하여 pod 이름만 추출
      POD_NAME="${podspec_name%.podspec}"
      echo "    📋 확인할 Pod 이름: $POD_NAME"
      pod trunk info "$POD_NAME" | tail -n 20
      
      if [ $? -eq 0 ]; then
        echo "    ✅ Pod 정보 확인 완료"
      else
        echo "    ⚠️  Pod 정보 확인 실패"
      fi
    else
      echo "    ❌ Pod 업로드 실패: $podspec_name"
      cd "$WORKING_DIR"
      FAILED_REPOS+=("$repo_dir")
      continue
    fi
  else
    echo "  ℹ️  Pod 업로드를 건너뜁니다. ($repo_dir)"
  fi
  
  cd "$WORKING_DIR"
  echo ""
done

if [ ${#FAILED_REPOS[@]} -gt 0 ]; then
  echo "❌ 다음 레포지토리에서 실패했습니다: ${FAILED_REPOS[*]}"
  exit 1
fi

echo "✅ 모든 레포지토리 SPM, Pod 작업 완료!"
echo ""

# ============================================
# Git 커밋 및 태그 푸시
# ============================================
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📤 Git 커밋 및 태그 푸시"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# 원격 저장소 정보 가져오기
REMOTE_NAME=$(git remote | grep -x "origin" || git remote | head -n1)
if [ -z "$REMOTE_NAME" ]; then
  echo "⚠️  원격 저장소를 찾을 수 없습니다. 푸시를 건너뜁니다."
else
  # 원격에 현재 커밋이 이미 있는지 확인
  REMOTE_COMMIT_EXISTS=false
  CURRENT_COMMIT_HASH=$(git rev-parse HEAD)
  
  # 원격 브랜치 정보 가져오기
  if ! git fetch "$REMOTE_NAME" --quiet 2>&1; then
    echo "  ⚠️  원격 저장소 정보 가져오기 실패"
  fi
  REMOTE_BRANCH=$(git rev-parse --abbrev-ref --symbolic-full-name @{u} 2>/dev/null)
  
  if [ -n "$REMOTE_BRANCH" ]; then
    # 원격 브랜치에 현재 커밋이 있는지 확인
    if git branch -r --contains "$CURRENT_COMMIT_HASH" | grep -q "$REMOTE_BRANCH"; then
      REMOTE_COMMIT_EXISTS=true
    fi
  fi
  
  # 원격에 같은 태그가 있는지 확인
  REMOTE_TAG_EXISTS=false
  if git ls-remote --tags "$REMOTE_NAME" "$LATEST_TAG" | grep -q "$LATEST_TAG"; then
    REMOTE_TAG_EXISTS=true
  fi
  
  # 푸시 여부 결정
  if [ "$REMOTE_COMMIT_EXISTS" = true ] || [ "$REMOTE_TAG_EXISTS" = true ]; then
    echo "⚠️  이미 원격에 같은 버전의 커밋 또는 태그가 존재합니다."
    if [ "$REMOTE_COMMIT_EXISTS" = true ]; then
      echo "  📋 현재 커밋이 원격에 이미 존재합니다."
    fi
    if [ "$REMOTE_TAG_EXISTS" = true ]; then
      echo "  🏷️  태그 '$LATEST_TAG'가 원격에 이미 존재합니다."
    fi
    echo "  💡 푸시를 건너뜁니다."
  else
    echo "📤 커밋 및 태그 푸시 중..."
    
    # 커밋 푸시
    echo "  📝 커밋 푸시 중..."
    git push "$REMOTE_NAME" HEAD
    if [ $? -eq 0 ]; then
      echo "  ✅ 커밋 푸시 완료"
    else
      echo "  ❌ 커밋 푸시 실패"
      exit 1
    fi
    
    # 태그 푸시
    echo "  🏷️  태그 푸시 중..."
    git push "$REMOTE_NAME" "$LATEST_TAG"
    if [ $? -eq 0 ]; then
      echo "  ✅ 태그 푸시 완료: $LATEST_TAG"
    else
      echo "  ❌ 태그 푸시 실패"
      exit 1
    fi
    
    echo ""
    echo "✅ 모든 푸시가 완료되었습니다!"
  fi
fi

echo ""

# ============================================
# dSYM 파일 추출
# ============================================
echo "📦 dSYM 파일 추출 중..."

DSYM_DIR="Distribution/${TAG_VERSION}_dSYM"
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
echo "🏷️  빌드 버전: ${TAG_VERSION:-$DEPLOY_VERSION}"
echo ""

