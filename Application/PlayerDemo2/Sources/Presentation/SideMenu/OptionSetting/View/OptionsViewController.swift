//
//  OptionsViewController.swift
//  PlayerDemo2
//
//  Created by Tabber on 1/20/25.
//  Copyright © 2025 com.app. All rights reserved.
//


import UIKit
import iOSDropDown
import ShopLiveSDK
import ShopliveSDKCommon

final class OptionsViewController: SideMenuItemViewController {

    var items: [SDKOption] = []
    
    lazy private var dropdown : DropDown = {
        let dropdown = DropDown()
//        dropdown.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(dropdown)
        
        dropdown.listWillAppear {
            dropdown.isHidden = false
        }
        dropdown.listDidAppear {
            dropdown.isHidden = false
        }
        dropdown.listWillDisappear {
            dropdown.isHidden = true
        }
        dropdown.listDidDisappear {
            dropdown.isHidden = true
        }
        return dropdown
    }()

    private lazy var tableView: UITableView = {
        let view = UITableView(frame: .zero, style: .plain)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.delegate = self
        view.dataSource = self
        view.backgroundColor = .white
        view.separatorStyle = .none
        view.contentInsetAdjustmentBehavior = .never
        view.alwaysBounceVertical = false
        view.register(SwitchOptionCell.self, forCellReuseIdentifier: "SwitchOptionCell")
        view.register(ButtonOptionCell.self, forCellReuseIdentifier: "ButtonOptionCell")
        view.register(OptionSectionHeader.self, forHeaderFooterViewReuseIdentifier: "OptionSectionHeader")
        view.contentInset = .init(top: 0, left: 0, bottom: ((UIApplication.shared.windows.first?.safeAreaInsets.bottom ?? 0) + 16), right: 0)
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = SideMenuTypes.options.stringKey.localized()
        removeTapGesture()
        setupOptions()
        setupViews()
    }

    private func setupViews() {
        if #available(iOS 15, *) {
            tableView.sectionHeaderTopPadding = 1
        }
        self.view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        ])
//        tableView.snp.makeConstraints {
//            $0.edges.equalToSuperview()
//        }
    }

    private func setupOptions() {
        
        let keepWindowStateOnPlayExecutedOption = SDKOptionItem(name: "sdkoption.setupPlayer.keepWindowStateOnPlayExecuted.title".localized(), optionDescription: "sdkoption.setupPlayer.keepWindowStateOnPlayExecuted.description".localized(), optionType: .keepWindowStateOnPlayExecuted)
        let mixAudioOption = SDKOptionItem(name: "sdkoption.setupPlayer.mixAudio.title".localized(), optionDescription: "sdkoption.setupPlayer.mixAudio.description".localized(), optionType: .mixAudio)
        let isEnabledVolumeKey = SDKOptionItem(name: "sdkoption.setupPlayer.isEnabledVolumeKey.title".localized(), optionDescription: "sdkoption.setupPlayer.isEnabledVolumeKey.description".localized(), optionType: .isEnabledVolumeKey)
        let resizeModeOption = SDKOptionItem(name: "sdkoption.setupPlayer.resizeMode.title".localized(), optionDescription: "sdkoption.setupPlayer.resizeMode.description".localized(), optionType: .resizeMode)
        let nextActionOption = SDKOptionItem(name: "sdkoption.nextActionTypeOnNavigation.title".localized(), optionDescription: "sdkoption.nextActionTypeOnNavigation.description".localized(), optionType: .nextActionOnHandleNavigation)
        let statusBarVisibilityOption = SDKOptionItem(name: "sdkoption.statusbarvisibility.title".localized(), optionDescription: "sdkoption.statusbarvisibility.description".localized(), optionType: .statusBarVisibility)
        let setupPlayerOptions = SDKOption(optionTitle: "sdkoption.section.setupPlayer.title".localized(), optionItems: [ keepWindowStateOnPlayExecutedOption, mixAudioOption, isEnabledVolumeKey, resizeModeOption, nextActionOption, statusBarVisibilityOption])
        
        items.append(setupPlayerOptions)
        
        let muteOption = SDKOptionItem(name: "sdkoption.sound.mute.title".localized(), optionDescription: "sdkoption.sound.mute.description".localized(), optionType: .mute)
        let muteOptions = SDKOption(optionTitle: "sdkoption.section.sound.title".localized(), optionItems: [muteOption])
        
        items.append(muteOptions)
        
        let previewOption = SDKOptionItem(name: "sdkoption.preview.title".localized(), optionDescription: "sdkoption.preview.description".localized(), optionType: .playWhenPreviewTapped)
        let closeButtonOption = SDKOptionItem(name: "sdkoption.preview.closebutton.title".localized(), optionDescription: "sdkoption.preview.closebutton.description".localized(), optionType: .useCloseButton)
        let previewSoundOption = SDKOptionItem(name: "sdkoption.preview.enableSound.title".localized(), optionDescription: "sdkoption.preview.enableSound.description".localized(), optionType: .enablePreviewSound)
        
        
        let playerPreviewResolutionOption = SDKOptionItem(name: "sdkoption.player.preview.title".localized(), optionDescription: "sdkoption.player.preview.description".localized(), optionType: .previewResolution)
        
        let previewOptions = SDKOption(optionTitle: "sdkoption.section.preview.title".localized(), optionItems: [previewOption, closeButtonOption,previewSoundOption,playerPreviewResolutionOption])
        
        items.append(previewOptions)
        
        
        let pipPositionOption = SDKOptionItem(name: "sdkoption.pipPosition.title".localized(), optionDescription: "sdkoption.pipPosition.description".localized(), optionType: .pipPosition)
        
        let pipPinOption = SDKOptionItem(name: "sdkoption.pinPosition.title".localized(), optionDescription: "sdkoption.pinPosition.description".localized(), optionType: .pipPinPosition)
        
        
        
        let pipScaleOption = SDKOptionItem(name: "sdkoption.pipScale.title".localized(), optionDescription: "sdkoption.pipScale.description".localized(), optionType: .pipScale)
        let pipMaxSizeOption = SDKOptionItem(name: "sdkOption.pipMaxSize.title".localized(), optionDescription: "sdkOption.pipMaxSize.description".localized(), optionType: .maxPipSize)
        let pipFixedHeightOption = SDKOptionItem(name: "sdkOption.pipFixedHeight.title".localized(), optionDescription: "sdkOption.pipFixedHeight.description".localized(), optionType: .fixedHeightPipSize)
        let pipFixedWidthOption = SDKOptionItem(name: "sdkOption.pipFixedWidth.title".localized(), optionDescription: "sdkOption.pipFixedWidth.description".localized(), optionType: .fixedWidthPipSize)
        
        let pipKeepWindowStyle = SDKOptionItem(name: "sdkoption.pipKeepWindowStyle.title".localized(), optionDescription: "sdkoption.pipKeepWindowStyle.description".localized(), optionType: .pipKeepWindowStyle)
        let pipAreaOption = SDKOptionItem(name: "sdkoption.pipFloatingOffset.title".localized(), optionDescription: "sdkoption.pipFloatingOffset.description".localized(), optionType: .pipFloatingOffset)
        let pipEnableSwipeOutOption = SDKOptionItem(name: "sdkoption.pipEnableSwipeOutOption.title".localized(), optionDescription: "sdkoption.pipEnableSwipeOutOption.description".localized(), optionType: .pipEnableSwipeOut)
        let pipCornerRadius = SDKOptionItem(name: "sdkoption.pipCornerRadius.title".localized(), optionDescription: "sdkoption.pipCornerRadius.description".localized(), optionType: .pipCornerRadius)
        let enablePip = SDKOptionItem(name: "sdkoption.enablepip.title".localized(), optionDescription: "sdkoption.enablepip.description".localized(), optionType: .enablePip)
        let enableOSPip = SDKOptionItem(name: "sdkoption.enableOspip.title".localized(), optionDescription: "sdkoption.enableOspip.description".localized(), optionType: .enableOSPip)
        let pipOptions = SDKOption(optionTitle: "sdkoption.section.pip.title".localized(), optionItems: [pipPositionOption,pipPinOption, pipScaleOption, pipMaxSizeOption,pipFixedHeightOption,pipFixedWidthOption, pipKeepWindowStyle, pipEnableSwipeOutOption, pipAreaOption,pipCornerRadius,enablePip,enableOSPip])
        

        items.append(pipOptions)

        let headphoneOption1 = SDKOptionItem(name: "sdkoption.headphoneOption1.title".localized(), optionDescription: "sdkoption.headphoneOption1.description".localized(), optionType: .headphoneOption1)
        
        let headphoneOption2 = SDKOptionItem(name: "sdkoption.headphoneOption2.title".localized(), optionDescription: "sdkoption.headphoneOption2.description".localized(), optionType: .headphoneOption2)
        let callOption = SDKOptionItem(name: "sdkoption.callOption.title".localized(), optionDescription: "sdkoption.callOption.description".localized(), optionType: .callOption)

        let autoPlayOptions = SDKOption(optionTitle: "sdkoption.section.autoPlay.title".localized(), optionItems: [headphoneOption1, headphoneOption2, callOption])

        items.append(autoPlayOptions)

        let customShareOption = SDKOptionItem(name: "sdkoption.customShare.title".localized(), optionDescription: "sdkoption.customShare.description".localized(), optionType: .customShare)

        let shareSchemeOption = SDKOptionItem(name: "sdkoption.shareScheme.title".localized(), optionDescription: "sdkoption.shareScheme.description".localized(), optionType: .shareScheme)

        let shareOptions = SDKOption(optionTitle: "sdkoption.section.share.title".localized(), optionItems: [customShareOption, shareSchemeOption])

        items.append(shareOptions)

        let progressColorOption = SDKOptionItem(name: "sdkoption.progressColor.title".localized(), optionDescription: "sdkoption.progressColor.description".localized(), optionType: .progressColor)

        let customProgressOption = SDKOptionItem(name: "sdkoption.customProgress.title".localized(), optionDescription: "sdkoption.customProgress.description".localized(), optionType: .customProgress)

        let progressOptions = SDKOption(optionTitle: "sdkoption.section.progress.title".localized(), optionItems: [progressColorOption, customProgressOption])

        items.append(progressOptions)

        let chatInputFontOption = SDKOptionItem(name: "sdkoption.chatInputCustomFont.title".localized(), optionDescription: "sdkoption.chatInputCustomFont.description".localized(), optionType: .chatInputCustomFont)

        let chatSendButtonFontOption = SDKOptionItem(name: "sdkoption.chatSendButtonCustomFont.title".localized(), optionDescription: "sdkoption.chatSendButtonCustomFont.description".localized(), optionType: .chatSendButtonCustomFont)

        let chatFontOptions = SDKOption(optionTitle: "sdkoption.section.chatFont.title".localized(), optionItems: [chatInputFontOption, chatSendButtonFontOption])

        items.append(chatFontOptions)

        let addParameterOPtion = SDKOptionItem(name: "sdkoption.addParameter.title".localized(), optionDescription: "", optionType: .addParameter)
        let customOptions = SDKOption(optionTitle: "sdkoption.section.customOption.title".localized(), optionItems: [addParameterOPtion])
        
        items.append(customOptions)
    }

}

extension OptionsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let item = items[safe: indexPath.section]?.optionItems[safe: indexPath.row]  else {
            return UITableViewCell()
        }

        switch item.optionType.settingType {
        case .switchControl:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "SwitchOptionCell", for: indexPath) as? SwitchOptionCell else {
                return UITableViewCell()
            }
            cell.configure(item: item)
            return cell
        case .showAlert, .dropdown, .routeTo:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "ButtonOptionCell", for: indexPath) as? ButtonOptionCell else {
                return UITableViewCell()
            }
            cell.configure(item: item)
            return cell
        }

    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items[section].optionItems.count
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return items.count
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "OptionSectionHeader") as? OptionSectionHeader, let item = items[safe: section] else { return nil }
        header.configure(headerTitle: item.optionTitle, section: section)
        return header
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        guard let item = items[safe: indexPath.section]?.optionItems[safe: indexPath.row] else { return }

        switch item.optionType.settingType {
        case .showAlert:
            switch item.optionType {
            case .shareScheme:
                let schemeAlert = TextItemInputAlertController(header: "sdkoption.section.share.title".localized(), data: DemoConfiguration.shared.shareScheme, placeHolder: "scheme 또는 url") { scheme in
                    DemoConfiguration.shared.shareScheme = scheme
                    self.tableView.reloadData()
                }
                schemeAlert.modalPresentationStyle = .overCurrentContext
                self.navigationController?.present(schemeAlert, animated: false, completion: nil)
                break
            case .progressColor:
                let schemeAlert = TextItemInputAlertController(header: "로딩 프로그레스 색상", data: DemoConfiguration.shared.progressColor, placeHolder: "ex) #FF0000") { color in
                    DemoConfiguration.shared.progressColor = color
                    self.tableView.reloadData()
                }
                schemeAlert.modalPresentationStyle = .overCurrentContext
                self.navigationController?.present(schemeAlert, animated: false, completion: nil)
                break
            case .pipScale:
                let pipData = DemoConfiguration.shared.pipScale == nil ? "" : String(format: "%.1f",  DemoConfiguration.shared.pipScale!)
                let pipScaleAlert = TextItemInputAlertController(header: "sdkoption.pipScale.title".localized(), data: pipData, placeHolder: "ex) 0.4") { scale in
                    DemoConfiguration.shared.pipScale = scale.cgfloatValue
                    self.tableView.reloadData()
                }
                pipScaleAlert.modalPresentationStyle = .overCurrentContext
                self.navigationController?.present(pipScaleAlert, animated: false, completion: nil)
                break
            case .maxPipSize:
                let fixedPipWidth = DemoConfiguration.shared.maxPipSize == nil ? "" : String(format: "%.0f",  DemoConfiguration.shared.maxPipSize!)
                let fixedPipWidthAlert = TextItemInputAlertController(header: "sdkOption.pipMaxSize.title".localized(), data: fixedPipWidth, placeHolder: "ex) 200") { fixedWidth in
                    DemoConfiguration.shared.maxPipSize = fixedWidth.cgfloatValue
                    DemoConfiguration.shared.fixedWidthPipSize = nil
                    DemoConfiguration.shared.fixedHeightPipSize = nil
                    self.tableView.reloadData()
                }
                fixedPipWidthAlert.modalPresentationStyle = .overCurrentContext
                self.navigationController?.present(fixedPipWidthAlert, animated: false, completion: nil)
                break
            case .fixedHeightPipSize:
                let size = DemoConfiguration.shared.fixedHeightPipSize == nil ? "" : String(format: "%.0f",  DemoConfiguration.shared.fixedHeightPipSize!)
                let alert = TextItemInputAlertController(header: "sdkOption.pipFixedHeight.title".localized(), data: size, placeHolder: "ex) 200") { size in
                    DemoConfiguration.shared.fixedHeightPipSize = size.cgfloatValue
                    DemoConfiguration.shared.maxPipSize = nil
                    DemoConfiguration.shared.fixedWidthPipSize = nil
                    self.tableView.reloadData()
                }
                alert.modalPresentationStyle = .overCurrentContext
                self.navigationController?.present(alert, animated: false, completion: nil)
                break
            case .fixedWidthPipSize:
                let size = DemoConfiguration.shared.fixedWidthPipSize == nil ? "" : String(format: "%.0f",  DemoConfiguration.shared.fixedWidthPipSize!)
                let alert = TextItemInputAlertController(header: "sdkOption.pipFixedWidth.title".localized(), data: size, placeHolder: "ex) 200") { size in
                    DemoConfiguration.shared.fixedWidthPipSize = size.cgfloatValue
                    DemoConfiguration.shared.fixedHeightPipSize = nil
                    DemoConfiguration.shared.maxPipSize = nil
                    self.tableView.reloadData()
                }
                alert.modalPresentationStyle = .overCurrentContext
                self.navigationController?.present(alert, animated: false, completion: nil)
                break
            case .pipCornerRadius:
                let size = DemoConfiguration.shared.pipCornerRadius == nil ? "" : String(format: "%.0f",  DemoConfiguration.shared.pipCornerRadius!)
                let alert = TextItemInputAlertController(header: "sdkOption.pipCornerRadius.title".localized(), data: size, placeHolder: "ex) 10") { size in
                    DemoConfiguration.shared.pipCornerRadius = size.cgfloatValue
                    self.tableView.reloadData()
                }
                alert.modalPresentationStyle = .overCurrentContext
                self.navigationController?.present(alert, animated: false, completion: nil)
            default:
                break
            }
            break
        case .dropdown:
            guard let indexPath = tableView.indexPathForSelectedRow else { return }
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "ButtonOptionCell", for: indexPath) as? ButtonOptionCell else { return }

            let cellRect = view.convert(tableView.rectForRow(at: indexPath), from: tableView)
            let anchorView = UIView(frame: CGRect(x: 0, y: 0, width: 1, height: 1))
            view.backgroundColor = .clear
            self.view.addSubview(anchorView)

            anchorView.frame = CGRect(origin: .init(x: 20, y: cellRect.origin.y + cell.frame.height), size: anchorView.frame.size)
            dropdown.frame = CGRect(origin: .init(x: 20, y: cellRect.origin.y + cell.frame.height), size: CGSize(width: 200, height: 20))
            
            switch item.optionType {
            case .nextActionOnHandleNavigation:
                dropdown.optionArray = ["sdkoption.nextActionTypeOnNavigation.item1".localized(), "sdkoption.nextActionTypeOnNavigation.item2".localized(), "sdkoption.nextActionTypeOnNavigation.item3".localized()]
                dropdown.didSelect { [weak self] selectedText, index, id in
                    DemoConfiguration.shared.nextActionTypeOnHandleNavigation = ActionType(rawValue: index) ?? .PIP
                    anchorView.removeFromSuperview()
                    self?.tableView.reloadData()
                }
                break
            case .pipPosition:
                dropdown.optionArray = ["topLeft", "topRight", "bottomLeft","bottomRight"]
                dropdown.didSelect { [weak self] selectedText, index, id in
                    switch selectedText {
                    case "topLeft":
                        DemoConfiguration.shared.pipPosition = .topLeft
                    case "topRight":
                        DemoConfiguration.shared.pipPosition = .topRight
                    case "bottomLeft":
                        DemoConfiguration.shared.pipPosition = .bottomLeft
                    case "bottomRight":
                        DemoConfiguration.shared.pipPosition = .bottomRight
                    default:
                        DemoConfiguration.shared.pipPosition = .bottomRight
                    }
                    
                    anchorView.removeFromSuperview()
                    self?.tableView.reloadData()
                }
                break
            default:
                    break
            }

            dropdown.showList()
            break
        case .routeTo:
            switch item.optionType {
            case .pipFloatingOffset:
                let pipAreaSetting = PipAreaSettingViewController()
                self.navigationController?.pushViewController(pipAreaSetting, animated: true)
                break
            case .addParameter:
                let customParam = SettingCustomParameterViewController()
                self.navigationController?.pushViewController(customParam, animated: true)
                break
            case .pipPinPosition:
                let vc = PipPinSettingsViewController()
                self.navigationController?.pushViewController(vc, animated: true)
            default:
                break
            }
            break
        default:
            break
        }


    }
}
