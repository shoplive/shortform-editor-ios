// 링크 전용 타깃.
//
// binaryTarget 은 다른 패키지의 product 에 의존을 걸 수 없다. 에디터 바이너리가 런타임에 링크하는
// ShopliveSDKCommon(common-ios)과 ffmpegkit · libav*(ffmpeg-kit-spm)을 함께 해석·링크되게 하려고
// 이 소스 타깃을 product 에 같이 싣는다. (종전에는 고객이 ffmpeg-kit-spm 을 직접 넣어야 했다.)
import ShopliveSDKCommon
