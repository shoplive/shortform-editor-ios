//
//  ShopLiveDemoLogViewController.swift
//  ShopLiveDemo
//
//  Created by ShopLive on 2021/08/18.
//

import UIKit

final class ShopLiveViewLogger {
    let v = ShopLiveViewLoggerController()

    var panGestureInitialCenter: CGPoint = .zero
    @objc private func windowPanGestureHandler(_ recognizer: UIPanGestureRecognizer) {
        guard let liveWindow = recognizer.view else { return }

        let translation = recognizer.translation(in: liveWindow)

        switch recognizer.state {
        case .began:
            panGestureInitialCenter = liveWindow.center
        case .changed:
            let centerX = panGestureInitialCenter.x + translation.x
            let centerY = panGestureInitialCenter.y + translation.y
            liveWindow.center = CGPoint(x: centerX, y: centerY)
        case .ended:
            break
        default:
            break
        }
    }

    private lazy var logWindow: UIWindow = {
        let window = UIWindow()
        window.backgroundColor = .black
        window.alpha = 0.6
        window.windowLevel = .statusBar + 1 //UIWindow.Level(rawValue: CGFloat.greatestFiniteMagnitude)
        window.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width * 0.96, height: UIScreen.main.bounds.size.height / 2)
        window.center = CGPoint(x: UIScreen.main.bounds.size.width * 0.5, y: UIScreen.main.bounds.size.height * 0.5)
        window.setNeedsLayout()
        window.layoutIfNeeded()

        v.view.isUserInteractionEnabled = true
        window.isUserInteractionEnabled = true
        if #available(iOS 13.0, *) {
            window.windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
        } else {
            // Fallback on earlier versions
        }

        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(windowPanGestureHandler))
        window.addGestureRecognizer(panGesture)

        window.rootViewController = v
        window.isHidden = true
        window.makeKeyAndVisible()
        return window
    }()

    static var shared: ShopLiveViewLogger = {
        return ShopLiveViewLogger()
    }()

    func setVisible(show: Bool) {
        logWindow.isHidden = !show
        #if DEMO
            ShopLiveDevConfiguration.shared.useAppLog = show
        #endif
    }

    func isVisible() -> Bool {
        return !logWindow.isHidden
    }

    func addLog(log: ShopLiveViewLog) {
        v.addLog(log: log)
    }

    func clearLog() {
        v.clearLog()
    }
}

final class ShopLiveViewLog {
    enum LogType {
        case callback // 콜백
        case interface // 웹로그
        case applog // 앱로그
        case normal
        case inbound
    }
    var logType: LogType = .normal
    var log: String = ""
    var filtered: Bool = false

    init(logType: LogType, log: String) {
        self.logType = logType
        self.log = log
    }
}

final class ShopLiveViewLoggerController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    class ViewModel: NSObject {
        private var logs: [ShopLiveViewLog] = []
        var filteredLogs: [ShopLiveViewLog] = []

        var viewLogs: [ShopLiveViewLog] {
            return filters.count > 0 ? filteredLogs : logs
        }

        var autoScroll: Bool = false

        private var filters: [ShopLiveViewLog.LogType] = []
        @objc dynamic var needReload: Bool = false

        func updateFilter(filter: ShopLiveViewLog.LogType, isOn: Bool) {
            if filters.contains(where: { $0 == filter }) {
                isOn ? () : filters.removeAll(where: { $0 == filter })
            } else {
                isOn ? filters.append(filter) : ()
            }

            if filters.count > 0 {
                filterLogs()
            }

            needReload = true
        }

        func addLog(log: ShopLiveViewLog) {
            if filters.count > 0 {
                if filters.contains(where: { $0 == log.logType }) {
                    filteredLogs.append(log)
                }
            }
            logs.append(log)

            needReload = true
//            filterLogs()
        }

        func clearLog() {
            filteredLogs.removeAll()
            logs.removeAll()
            needReload = true
        }

        private func filterLogs() {
            filteredLogs = _filterLogs()
        }

        private func _filterLogs()-> [ShopLiveViewLog] {
            let filterLogs = logs
            return filterLogs.map { log in
                log.filtered = filters.contains(where: { $0 == log.logType })
                return log
            }.filter({ $0.filtered == true })
        }

        func logToString() -> String {
            var logdata = ""

            if filters.count > 0 {
                filteredLogs.forEach { log in
                    logdata += log.log
                    logdata += "\n"
                }
            } else {
                logs.forEach { log in
                    logdata += log.log
                    logdata += "\n"
                }
            }

            return logdata
        }
    }

    var viewModel = ViewModel()
    @objc private dynamic var isOn: Bool = true

    private var videoWindowPanGestureRecognizer: UIPanGestureRecognizer?

    private lazy var onOffButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.alpha = 0.7
        button.backgroundColor = .lightGray
        button.titleLabel?.font = .boldSystemFont(ofSize: 18)
        button.addTarget(self, action: #selector(didTapOnOffButton(_:)), for: .touchUpInside)
        return button
    }()

    private lazy var onOffCallBack: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.alpha = 0.8
        button.setBackgroundColor(.lightGray, for: .normal)
        button.setBackgroundColor(.darkGray, for: .selected)
        button.titleLabel?.font = .boldSystemFont(ofSize: 16)
        button.addTarget(self, action: #selector(didTapOnOffButton(_:)), for: .touchUpInside)
        button.setTitle("콜백", for: .normal)
        button.setTitle("콜백", for: .selected)
        button.setTitleColor(.red, for: .selected)
        return button
    }()

    private lazy var onOffSendInterface: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.alpha = 0.8
        button.setBackgroundColor(.lightGray, for: .normal)
        button.setBackgroundColor(.darkGray, for: .selected)
        button.titleLabel?.font = .boldSystemFont(ofSize: 16)
        button.addTarget(self, action: #selector(didTapOnOffButton(_:)), for: .touchUpInside)
        button.setTitle("웹로그", for: .normal)
        button.setTitle("웹로그", for: .selected)
        button.setTitleColor(.red, for: .selected)
        return button
    }()

    private lazy var onOffAppLog: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.alpha = 0.8
        button.setBackgroundColor(.lightGray, for: .normal)
        button.setBackgroundColor(.darkGray, for: .selected)
        button.titleLabel?.font = .boldSystemFont(ofSize: 16)
        button.addTarget(self, action: #selector(didTapOnOffButton(_:)), for: .touchUpInside)
        button.setTitle("앱로그", for: .normal)
        button.setTitle("앱로그", for: .selected)
        button.setTitleColor(.red, for: .selected)
        return button
    }()

    private lazy var onOffHidden: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.alpha = 0.8
        button.setBackgroundColor(.lightGray, for: .normal)
        button.setBackgroundColor(.lightGray, for: .selected)
        button.titleLabel?.font = .boldSystemFont(ofSize: 16)
        button.addTarget(self, action: #selector(didTapOnOffButton(_:)), for: .touchUpInside)
        button.setTitle("숨김", for: .normal)
        button.setTitleColor(.red, for: .selected)
        return button
    }()

    private lazy var onOffScroll: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.alpha = 0.8
        button.setBackgroundColor(.lightGray, for: .normal)
        button.setBackgroundColor(.darkGray, for: .selected)
        button.titleLabel?.font = .boldSystemFont(ofSize: 16)
        button.addTarget(self, action: #selector(didTapOnOffButton(_:)), for: .touchUpInside)
        button.setTitle("스크롤", for: .normal)
        button.setTitleColor(.black, for: .selected)
        return button
    }()

    private lazy var exportButton: UIButton = {
            let button = UIButton()
            button.translatesAutoresizingMaskIntoConstraints = false
            button.alpha = 0.8
            button.setBackgroundColor(.lightGray, for: .normal)
            button.setBackgroundColor(.darkGray, for: .selected)
            button.titleLabel?.font = .boldSystemFont(ofSize: 16)
            button.addTarget(self, action: #selector(shareLogs), for: .touchUpInside)
            button.setTitle("공유", for: .normal)
            button.setTitleColor(.black, for: .selected)
            return button
        }()

    private lazy var clearButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.alpha = 0.8
        button.setBackgroundColor(.lightGray, for: .normal)
        button.setBackgroundColor(.darkGray, for: .selected)
        button.titleLabel?.font = .boldSystemFont(ofSize: 16)
        button.addTarget(self, action: #selector(clearLogs), for: .touchUpInside)
        button.setTitle("클린", for: .normal)
        button.setTitleColor(.black, for: .selected)
        return button
    }()

    private lazy var tableView: UITableView = {
        let v = UITableView(frame: .zero, style: .plain)
        v.translatesAutoresizingMaskIntoConstraints = false
        v.allowsSelection = false
        v.allowsMultipleSelection = false
        v.separatorStyle = .none
        v.dataSource = self
        v.delegate = self
        v.backgroundColor = .black
        v.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        v.register(ShopLiveViewLoggerCell.self, forCellReuseIdentifier: "LogCell")
        return v
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        setupViews()
        addObserver()
    }

    deinit {
        removeObserver()
    }

    private func setupViews() {

        self.view.addSubviews(onOffButton, onOffCallBack, onOffSendInterface, onOffAppLog, onOffHidden, onOffScroll, exportButton, clearButton)

        let onOffWidth: NSLayoutConstraint = .init(item: onOffButton, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 40)
        let onOffHeight: NSLayoutConstraint = .init(item: onOffButton, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 40)
        let onOff1Width: NSLayoutConstraint = .init(item: onOffCallBack, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 40)
        let onOff1Height: NSLayoutConstraint = .init(item: onOffCallBack, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 40)
        let onOff2Width: NSLayoutConstraint = .init(item: onOffSendInterface, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 50)
        let onOff2Height: NSLayoutConstraint = .init(item: onOffSendInterface, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 40)
        let onOff3Width: NSLayoutConstraint = .init(item: onOffAppLog, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 50)
        let onOff3Height: NSLayoutConstraint = .init(item: onOffAppLog, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 40)
        let onOff4Width: NSLayoutConstraint = .init(item: onOffHidden, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 40)
        let onOff4Height: NSLayoutConstraint = .init(item: onOffHidden, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 40)
        let onOff5Width: NSLayoutConstraint = .init(item: onOffScroll, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 60)
        let onOff5Height: NSLayoutConstraint = .init(item: onOffScroll, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 40)
        let onOff6Width: NSLayoutConstraint = .init(item: exportButton, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 40)
        let onOff6Height: NSLayoutConstraint = .init(item: exportButton, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 40)
        let onOff7Width: NSLayoutConstraint = .init(item: clearButton, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 40)
        let onOff7Height: NSLayoutConstraint = .init(item: clearButton, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 40)

        let onOffLeading: NSLayoutConstraint = .init(item: onOffButton, attribute: .leading, relatedBy: .equal, toItem: self.view, attribute: .leading, multiplier: 1.0, constant: 0)
        let onOff1Leading: NSLayoutConstraint = .init(item: onOffCallBack, attribute: .leading, relatedBy: .equal, toItem: onOffButton, attribute: .trailing, multiplier: 1.0, constant: 0)
        let onOff2Leading: NSLayoutConstraint = .init(item: onOffSendInterface, attribute: .leading, relatedBy: .equal, toItem: onOffCallBack, attribute: .trailing, multiplier: 1.0, constant: 0)
        let onOff3Leading: NSLayoutConstraint = .init(item: onOffAppLog, attribute: .leading, relatedBy: .equal, toItem: onOffSendInterface, attribute: .trailing, multiplier: 1.0, constant: 0)
        let onOff4Leading: NSLayoutConstraint = .init(item: onOffHidden, attribute: .leading, relatedBy: .equal, toItem: onOffAppLog, attribute: .trailing, multiplier: 1.0, constant: 0)
        let onOff5Leading: NSLayoutConstraint = .init(item: onOffScroll, attribute: .leading, relatedBy: .equal, toItem: onOffHidden, attribute: .trailing, multiplier: 1.0, constant: 0)
        let onOff6Leading: NSLayoutConstraint = .init(item: exportButton, attribute: .leading, relatedBy: .equal, toItem: onOffScroll, attribute: .trailing, multiplier: 1.0, constant: 0)
        let onOff7Leading: NSLayoutConstraint = .init(item: clearButton, attribute: .leading, relatedBy: .equal, toItem: exportButton, attribute: .trailing, multiplier: 1.0, constant: 0)

        let onOffTop: NSLayoutConstraint = .init(item: onOffButton, attribute: .top, relatedBy: .equal, toItem: self.view, attribute: .top, multiplier: 1.0, constant: 0)
        let onOffCallBackTop: NSLayoutConstraint = .init(item: onOffCallBack, attribute: .top, relatedBy: .equal, toItem: self.view, attribute: .top, multiplier: 1.0, constant: 0)
        let onOffSendInterfaceTop: NSLayoutConstraint = .init(item: onOffSendInterface, attribute: .top, relatedBy: .equal, toItem: self.view, attribute: .top, multiplier: 1.0, constant: 0)
        let onOffAppLogTop: NSLayoutConstraint = .init(item: onOffAppLog, attribute: .top, relatedBy: .equal, toItem: self.view, attribute: .top, multiplier: 1.0, constant: 0)
        let onOffHiddenTop: NSLayoutConstraint = .init(item: onOffHidden, attribute: .top, relatedBy: .equal, toItem: self.view, attribute: .top, multiplier: 1.0, constant: 0)
        let onOffScrollTop: NSLayoutConstraint = .init(item: onOffScroll, attribute: .top, relatedBy: .equal, toItem: self.view, attribute: .top, multiplier: 1.0, constant: 0)
        let exportScrollTop: NSLayoutConstraint = .init(item: exportButton, attribute: .top, relatedBy: .equal, toItem: self.view, attribute: .top, multiplier: 1.0, constant: 0)
        let clearScrollTop: NSLayoutConstraint = .init(item: clearButton, attribute: .top, relatedBy: .equal, toItem: self.view, attribute: .top, multiplier: 1.0, constant: 0)

        onOffButton.addConstraints([onOffWidth, onOffHeight])
        onOffCallBack.addConstraints([onOff1Width, onOff1Height])
        onOffSendInterface.addConstraints([onOff2Width, onOff2Height])
        onOffAppLog.addConstraints([onOff3Width, onOff3Height])
        onOffHidden.addConstraints([onOff4Width, onOff4Height])
        onOffScroll.addConstraints([onOff5Width, onOff5Height])
        exportButton.addConstraints([onOff6Width, onOff6Height])
        clearButton.addConstraints([onOff7Width, onOff7Height])

        self.view.addConstraints([onOffLeading, onOff1Leading, onOff2Leading, onOff3Leading, onOff4Leading, onOff5Leading, onOff6Leading, onOff7Leading, onOffTop, onOffHiddenTop, onOffAppLogTop, onOffCallBackTop, onOffSendInterfaceTop, onOffScrollTop, exportScrollTop, clearScrollTop])

        self.view.addSubview(tableView)

        let tableViewTop: NSLayoutConstraint = .init(item: tableView, attribute: .top, relatedBy: .equal, toItem: onOffButton, attribute: .bottom, multiplier: 1.0, constant: 0)
        self.view.addConstraint(tableViewTop)
        NSLayoutConstraint.activate([ tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                                      tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                                      tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])

    }

    @objc func shareLogs() {
        let logData = viewModel.logToString()
        guard logData.count > 0 else { return }
        let shareAll:[Any] = [logData]

        let activityViewController = UIActivityViewController(activityItems: shareAll , applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view
        self.present(activityViewController, animated: true, completion: nil)
    }

    @objc func clearLogs() {
        clearLog()
    }

    @objc func didTapOnOffButton(_ sender: UIButton) {
        switch sender {
        case onOffButton:
            self.isOn = !self.isOn
    //window.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width * 0.9, height: UIScreen.main.bounds.size.height / 2)
            guard let x = self.view.window?.frame.origin.x, let y = self.view.window?.frame.origin.y else { return }
            self.view.window?.frame = isOn ? CGRect(x: x, y: y, width: UIScreen.main.bounds.size.width * 0.9, height: UIScreen.main.bounds.size.height / 2) : CGRect(x: x, y: y, width: 40, height: 40)
            break
        case onOffCallBack:
            onOffCallBack.isSelected = !onOffCallBack.isSelected
            viewModel.updateFilter(filter: .callback, isOn: onOffCallBack.isSelected)
            self.tableView.reloadData()
            break
        case onOffSendInterface:
            onOffSendInterface.isSelected = !onOffSendInterface.isSelected
            viewModel.updateFilter(filter: .interface, isOn: onOffSendInterface.isSelected)
            self.tableView.reloadData()
            break
        case onOffHidden:
            ShopLiveViewLogger.shared.setVisible(show: false)
            break
        case onOffAppLog:
            onOffAppLog.isSelected = !onOffAppLog.isSelected
            viewModel.updateFilter(filter: .applog, isOn: onOffAppLog.isSelected)
            self.tableView.reloadData()
            break
        case onOffScroll:
            onOffScroll.isSelected = !onOffScroll.isSelected
            viewModel.autoScroll = onOffScroll.isSelected
            break
        default:
            break
        }

    }

    func addLog(log: ShopLiveViewLog) {
        self.viewModel.addLog(log: log)
    }

    func clearLog() {
        self.viewModel.clearLog()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.viewLogs.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(withIdentifier: "LogCell", for: indexPath) as? ShopLiveViewLoggerCell else {
            return UITableViewCell.init(style: .default, reuseIdentifier: "Cell")
        }

        if let filterLog: ShopLiveViewLog = self.viewModel.viewLogs[safe: indexPath.row] {
            cell.configure(log: filterLog.log)
        }

        return cell
    }

    func scrollToBottom(){
        guard viewModel.autoScroll else { return }
        guard self.viewModel.viewLogs.count > 0 else { return }
        let indexPath = IndexPath.init (row: self.viewModel.viewLogs.count - 1, section: 0)
        self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
    }

}

extension ShopLiveViewLoggerController {

    private func addObserver() {
        self.addObserver(self, forKeyPath: "isOn", options: [.initial, .old, .new], context: nil)
        self.viewModel.addObserver(self, forKeyPath: "needReload", options: [.initial, .old, .new], context: nil)
    }

    private func removeObserver() {
        self.removeObserver(self, forKeyPath: "isOn")
        self.removeObserver(self, forKeyPath: "needReload")
    }

    func handleIsOn() {
        onOffButton.setTitle(isOn ? "닫기" : "열기", for: .normal)
        onOffCallBack.isHidden = !isOn
        onOffSendInterface.isHidden = !isOn
        onOffAppLog.isHidden = !isOn
        onOffHidden.isHidden = !isOn
        onOffScroll.isHidden = !isOn
        exportButton.isHidden = !isOn
        clearButton.isHidden = !isOn
    }

    func handleReload() {
        guard self.viewModel.needReload else { return }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.03) {
            self.tableView.reloadData()
            self.scrollToBottom()
        }
    }

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard let key = keyPath else { return }

        switch key {
        case "isOn":
            handleIsOn()
            break
        case "needReload":
            handleReload()
            break
        default:
            break
        }
    }
}


final class ShopLiveViewLoggerCell: UITableViewCell {

    private lazy var logLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .boldSystemFont(ofSize: 12)
        label.textColor = .white
        label.numberOfLines = 0
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        setupViews()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }

    private func setupViews() {

        self.backgroundColor = .clear

        self.addSubview(logLabel)

        let leadingConstraint: NSLayoutConstraint = .init(item: logLabel, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1.0, constant: 10)
        let trailingConstraint: NSLayoutConstraint = .init(item: logLabel, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1.0, constant: -10)
        let topConstraint: NSLayoutConstraint = .init(item: logLabel, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1.0, constant: 1)
        let bottomConstraint: NSLayoutConstraint = .init(item: logLabel, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1.0, constant: -1)
        self.addConstraints([leadingConstraint, trailingConstraint, topConstraint, bottomConstraint])
    }

    func configure(log: String) {
        self.logLabel.text = log
    }

}
