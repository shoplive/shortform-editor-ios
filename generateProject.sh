#!/usr/bin/env zsh
set -euo pipefail

export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"

# 선택 메뉴
OPTIONS=("PlayerDemo" "PlayerDemo2" "ShortformDemo" "ShopLiveDemo-eBay" "OnlyDomesticModule")

echo "생성할 프로젝트를 선택해주세요:"
for idx in "${!OPTIONS[@]}"; do
  num=$((idx+1))
  echo "  $num) ${OPTIONS[idx]}"
done

echo -n "선택 (1-${#OPTIONS[@]}): "
read choice

# 유효성 검사
if ! [[ "$choice" =~ ^[1-9][0-9]*$ ]] || (( choice < 1 || choice > ${#OPTIONS[@]} )); then
  echo "❌ 잘못된 선택입니다."
  exit 1
fi

# 이전 결과 정리 및 의존성 설치
echo "🧹 tuist clean 실행 중..."
tuist clean

echo "📦 tuist install 실행 중..."
tuist install

# 선택에 따른 generate
case "$choice" in
  1)
    echo "🚀 tuist generate PlayerDemo 실행 중..."
    tuist generate PlayerDemo
    ;;
  2)
    echo "🚀 tuist generate PlayerDemo2 실행 중..."
    tuist generate PlayerDemo2
    ;;
  3)
    echo "🚀 tuist generate ShortformDemo 실행 중..."
    tuist generate ShortformDemo
    ;;
  4)
    echo "🚀 tuist generate ShopLiveDemo 실행 중..."
    tuist generate PlayerDemo ShopLiveDemo
    ;;
  5)
    echo "🚀 tuist generate OnlyDomesticModule 실행 중..."
    tuist generate OnlyDomesticModule
    ;;
esac

echo "✅ 완료!"
