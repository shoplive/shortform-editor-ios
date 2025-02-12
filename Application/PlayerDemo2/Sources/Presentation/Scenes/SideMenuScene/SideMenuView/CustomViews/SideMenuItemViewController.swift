//
//  SideMenuItemViewController.swift
//  PlayerDemo2
//
//  Created by Tabber on 1/20/25.
//  Copyright © 2025 com.app. All rights reserved.
//

import UIKit

class SideMenuItemViewController: UIViewController {

    var tapGesture: UITapGestureRecognizer?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = .white
        setupEdgeGesture()
        setupTapGesture()
        setupBackButton()
    }

    func setupBackButton() {
        let backButton = UIBarButtonItem(image: PlayerDemo2Asset.back.image, style: .plain, target: self, action: #selector(handleNaviBack)
        )
        backButton.tintColor = .white
        self.navigationItem.leftBarButtonItem = backButton

        self.navigationController?.navigationBar.topItem?.backBarButtonItem = nil
    }

    @objc func handleNaviBack() {
        shopliveHideKeyboard_SL()
        self.navigationController?.popViewController(animated: true)
    }

    @objc private func handleEdgeGesture(_ gesture: UIScreenEdgePanGestureRecognizer) {
        guard gesture.state == .recognized else {
            return
        }
        shopliveHideKeyboard_SL()
        self.navigationController?.popViewController(animated: true)
    }

    private func setupEdgeGesture() {
        let edgePanGesture = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(handleEdgeGesture(_:)))
        edgePanGesture.edges = .left
        self.view.addGestureRecognizer(edgePanGesture)
    }

    @objc private func handleTapGesture(_ gesture: UITapGestureRecognizer) {
        guard gesture.state == .recognized else {
            return
        }
        shopliveHideKeyboard_SL()
    }

    private func setupTapGesture() {
        tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture(_:)))
        self.view.addGestureRecognizer(tapGesture!)
    }

    func removeTapGesture() {
        guard let gestureRecognizers = self.view.gestureRecognizers,
                gestureRecognizers.contains(where: {$0 == tapGesture}) else { return }

        self.view.removeGestureRecognizer(tapGesture!)
    }
}

