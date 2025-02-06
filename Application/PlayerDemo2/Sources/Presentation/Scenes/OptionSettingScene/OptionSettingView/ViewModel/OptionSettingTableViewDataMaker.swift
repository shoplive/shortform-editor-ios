//
//  OptionSettingTableViewDataMaker.swift
//  PlayerDemo2
//
//  Created by sangmin han on 1/29/25.
//  Copyright © 2025 com.app. All rights reserved.
//

import Foundation



final class OptionSettingTableViewDataMaker : NSObject {
    
    
    func getDataSource() -> [SDKOption] {
        return [
            getPlayerOption(),
            getMuteOption(),
            getPreviewOption(),
            getPipOption(),
            getAutoPlayOption(),
            getShareOption(),
            getProgressOption(),
            getChatFontOption(),
            getCustomOption()
        ]
    }
    
    private func getPlayerOption() -> SDKOption {
        let keepWindowStateOnPlayExecutedOption = SDKOptionItem(name: "sdkoption.setupPlayer.keepWindowStateOnPlayExecuted.title".localized(), optionDescription: "sdkoption.setupPlayer.keepWindowStateOnPlayExecuted.description".localized(), optionType: .keepWindowStateOnPlayExecuted)
        let mixAudioOption = SDKOptionItem(name: "sdkoption.setupPlayer.mixAudio.title".localized(), optionDescription: "sdkoption.setupPlayer.mixAudio.description".localized(), optionType: .mixAudio)
        let isEnabledVolumeKey = SDKOptionItem(name: "sdkoption.setupPlayer.isEnabledVolumeKey.title".localized(), optionDescription: "sdkoption.setupPlayer.isEnabledVolumeKey.description".localized(), optionType: .isEnabledVolumeKey)
        let resizeModeOption = SDKOptionItem(name: "sdkoption.setupPlayer.resizeMode.title".localized(), optionDescription: "sdkoption.setupPlayer.resizeMode.description".localized(), optionType: .resizeMode)
        let nextActionOption = SDKOptionItem(name: "sdkoption.nextActionTypeOnNavigation.title".localized(), optionDescription: "sdkoption.nextActionTypeOnNavigation.description".localized(), optionType: .nextActionOnHandleNavigation)
        let statusBarVisibilityOption = SDKOptionItem(name: "sdkoption.statusbarvisibility.title".localized(), optionDescription: "sdkoption.statusbarvisibility.description".localized(), optionType: .statusBarVisibility)
        let setupPlayerOptions = SDKOption(optionTitle: "sdkoption.section.setupPlayer.title".localized(), optionItems: [ keepWindowStateOnPlayExecutedOption, mixAudioOption, isEnabledVolumeKey, resizeModeOption, nextActionOption, statusBarVisibilityOption])
        
        return setupPlayerOptions
    }
    
    private func getMuteOption() -> SDKOption {
        let muteOption = SDKOptionItem(name: "sdkoption.sound.mute.title".localized(), optionDescription: "sdkoption.sound.mute.description".localized(), optionType: .mute)
        let muteOptions = SDKOption(optionTitle: "sdkoption.section.sound.title".localized(), optionItems: [muteOption])
        
        return muteOptions
    }
    
    
    private func getPreviewOption() -> SDKOption {
        let previewOption = SDKOptionItem(name: "sdkoption.preview.title".localized(), optionDescription: "sdkoption.preview.description".localized(), optionType: .playWhenPreviewTapped)
        let closeButtonOption = SDKOptionItem(name: "sdkoption.preview.closebutton.title".localized(), optionDescription: "sdkoption.preview.closebutton.description".localized(), optionType: .useCloseButton)
        let previewSoundOption = SDKOptionItem(name: "sdkoption.preview.enableSound.title".localized(), optionDescription: "sdkoption.preview.enableSound.description".localized(), optionType: .enablePreviewSound)
        
        
        let playerPreviewResolutionOption = SDKOptionItem(name: "sdkoption.player.preview.title".localized(), optionDescription: "sdkoption.player.preview.description".localized(), optionType: .previewResolution)
        
        let previewOptions = SDKOption(optionTitle: "sdkoption.section.preview.title".localized(), optionItems: [previewOption, closeButtonOption,previewSoundOption,playerPreviewResolutionOption])
        
        return previewOptions
    }
    
    
    private func getPipOption() -> SDKOption {
        let pipPositionOption = SDKOptionItem(name: "sdkoption.pipPosition.title".localized(), optionDescription: "sdkoption.pipPosition.description".localized(), optionType: .pipPosition)
        
        let pipPinOption = SDKOptionItem(name: "sdkoption.pinPosition.title".localized(), optionDescription: "sdkoption.pinPosition.description".localized(), optionType: .pipPinPosition)
        
        let pipMaxSizeOption = SDKOptionItem(name: "sdkOption.pipMaxSize.title".localized(), optionDescription: "sdkOption.pipMaxSize.description".localized(), optionType: .maxPipSize)
        let pipFixedHeightOption = SDKOptionItem(name: "sdkOption.pipFixedHeight.title".localized(), optionDescription: "sdkOption.pipFixedHeight.description".localized(), optionType: .fixedHeightPipSize)
        let pipFixedWidthOption = SDKOptionItem(name: "sdkOption.pipFixedWidth.title".localized(), optionDescription: "sdkOption.pipFixedWidth.description".localized(), optionType: .fixedWidthPipSize)
        
        let pipKeepWindowStyle = SDKOptionItem(name: "sdkoption.pipKeepWindowStyle.title".localized(), optionDescription: "sdkoption.pipKeepWindowStyle.description".localized(), optionType: .pipKeepWindowStyle)
        let pipAreaOption = SDKOptionItem(name: "sdkoption.pipFloatingOffset.title".localized(), optionDescription: "sdkoption.pipFloatingOffset.description".localized(), optionType: .pipFloatingOffset)
        let pipEnableSwipeOutOption = SDKOptionItem(name: "sdkoption.pipEnableSwipeOutOption.title".localized(), optionDescription: "sdkoption.pipEnableSwipeOutOption.description".localized(), optionType: .pipEnableSwipeOut)
        let pipCornerRadius = SDKOptionItem(name: "sdkoption.pipCornerRadius.title".localized(), optionDescription: "sdkoption.pipCornerRadius.description".localized(), optionType: .pipCornerRadius)
        let enablePip = SDKOptionItem(name: "sdkoption.enablepip.title".localized(), optionDescription: "sdkoption.enablepip.description".localized(), optionType: .enablePip)
        let enableOSPip = SDKOptionItem(name: "sdkoption.enableOspip.title".localized(), optionDescription: "sdkoption.enableOspip.description".localized(), optionType: .enableOSPip)
        let pipOptions = SDKOption(optionTitle: "sdkoption.section.pip.title".localized(), optionItems: [pipPositionOption,pipPinOption, pipMaxSizeOption,pipFixedHeightOption,pipFixedWidthOption, pipKeepWindowStyle, pipEnableSwipeOutOption, pipAreaOption,pipCornerRadius,enablePip,enableOSPip])
        
        
        return pipOptions
    }
    
    private func getAutoPlayOption() -> SDKOption {
        
        let headphoneOption1 = SDKOptionItem(name: "sdkoption.headphoneOption1.title".localized(), optionDescription: "sdkoption.headphoneOption1.description".localized(), optionType: .headphoneOption1)
        
        let headphoneOption2 = SDKOptionItem(name: "sdkoption.headphoneOption2.title".localized(), optionDescription: "sdkoption.headphoneOption2.description".localized(), optionType: .headphoneOption2)
        let callOption = SDKOptionItem(name: "sdkoption.callOption.title".localized(), optionDescription: "sdkoption.callOption.description".localized(), optionType: .callOption)

        let autoPlayOptions = SDKOption(optionTitle: "sdkoption.section.autoPlay.title".localized(), optionItems: [headphoneOption1, headphoneOption2, callOption])
        
        return autoPlayOptions
    }
    
    private func getShareOption() -> SDKOption {
        let customShareOption = SDKOptionItem(name: "sdkoption.customShare.title".localized(), optionDescription: "sdkoption.customShare.description".localized(), optionType: .customShare)

        let shareSchemeOption = SDKOptionItem(name: "sdkoption.shareScheme.title".localized(), optionDescription: "sdkoption.shareScheme.description".localized(), optionType: .shareScheme)

        let shareOptions = SDKOption(optionTitle: "sdkoption.section.share.title".localized(), optionItems: [customShareOption, shareSchemeOption])
        
        return shareOptions
    }
    
    private func getProgressOption() -> SDKOption {
        let progressColorOption = SDKOptionItem(name: "sdkoption.progressColor.title".localized(), optionDescription: "sdkoption.progressColor.description".localized(), optionType: .progressColor)

        let customProgressOption = SDKOptionItem(name: "sdkoption.customProgress.title".localized(), optionDescription: "sdkoption.customProgress.description".localized(), optionType: .customProgress)

        let progressOptions = SDKOption(optionTitle: "sdkoption.section.progress.title".localized(), optionItems: [progressColorOption, customProgressOption])
        
        return progressOptions
    }
    
    private func getChatFontOption() -> SDKOption {
        let chatInputFontOption = SDKOptionItem(name: "sdkoption.chatInputCustomFont.title".localized(), optionDescription: "sdkoption.chatInputCustomFont.description".localized(), optionType: .chatInputCustomFont)

        let chatSendButtonFontOption = SDKOptionItem(name: "sdkoption.chatSendButtonCustomFont.title".localized(), optionDescription: "sdkoption.chatSendButtonCustomFont.description".localized(), optionType: .chatSendButtonCustomFont)

        let chatFontOptions = SDKOption(optionTitle: "sdkoption.section.chatFont.title".localized(), optionItems: [chatInputFontOption, chatSendButtonFontOption])
        
        return chatFontOptions
    }
    
    
    private func getCustomOption() -> SDKOption {
        let addParameterOPtion = SDKOptionItem(name: "sdkoption.addParameter.title".localized(), optionDescription: "", optionType: .addParameter)
        let customOptions = SDKOption(optionTitle: "sdkoption.section.customOption.title".localized(), optionItems: [addParameterOPtion])
        
        return customOptions
    }
    
    
    
    
    
    
    
    
    
    
    
}
