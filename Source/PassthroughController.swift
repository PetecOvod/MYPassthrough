//
//  PassthroughController.h
//  MYPassthrough
//
//  Created by Yaroslav Minaev on 21/09/2017.
//  Copyright © 2017 Yaroslav Minaev All rights reserved.
//

import UIKit

class PassthroughController: UIViewController, CAAnimationDelegate {
    private var mask = CAShapeLayer()
    private var frameInset: CGFloat {
        return -max(view.frame.width, view.frame.height)
    }

    private var initialPath: UIBezierPath {
        let fullFrame = UIBezierPath(rect: view.frame.insetBy(dx: frameInset, dy: frameInset))
        let cutFrame = UIBezierPath(roundedRect: view.frame.insetBy(dx: frameInset / 2, dy: frameInset / 2), cornerRadius: 30)
        fullFrame.append(cutFrame)
        return fullFrame
    }

    var emptyPath: UIBezierPath {
        return UIBezierPath(rect: view.frame.insetBy(dx: frameInset, dy: frameInset))
    }

    var animationDuration: CFTimeInterval = 0.5
    var closeButton = CloseButton(frame: .zero)
    var maskFillColor: UIColor! {
        didSet {
            mask.fillColor = maskFillColor.cgColor
        }
    }

    var demonstrationView: UIView!
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    private var tapGestureRecognizer: UITapGestureRecognizer!
    private var lastOrientation: PassthroughOrientation?
    private var lastSize: CGSize?

    // MARK: - Events

    var didTapAction: (() -> Void)?
    var didCancelAction: (() -> Void)?
    var didOrientationChange: (() -> Void)?
    var didFinishedAnimation: (() -> Void)?
    var didChangeState: ((PassthroughState) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        didChangeState?(.initialization)
        configDemonstrationView()
        configCloseButton()

        tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapAction))
        view.addGestureRecognizer(tapGestureRecognizer)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        didChangeState?(.demonstration)
    }

    func setupInitialMask(withColor color: UIColor) {
        mask.fillRule = .evenOdd
        mask.fillColor = color.cgColor
        view.layer.addSublayer(mask)
        mask.path = initialPath.cgPath
    }

    func prepareToDemonstration() {
        lastOrientation = PassthroughOrientation(UIDevice.current.orientation)
        tapGestureRecognizer.isEnabled = true
    }

    func adjust(with overlayPath: UIBezierPath, animated: Bool) {
        if animated {
            let anim = CABasicAnimation(keyPath: "path")
            anim.timingFunction = CAMediaTimingFunction(name: .easeOut)
            anim.duration = animationDuration
            anim.delegate = self
            anim.isRemovedOnCompletion = true
            anim.fillMode = .forwards
            anim.fromValue = mask.path
            anim.toValue = overlayPath.cgPath
            mask.add(anim, forKey: "path")
        } else {
            mask.removeAnimation(forKey: "path")
        }

        mask.path = overlayPath.cgPath
    }

    func clean() {
        demonstrationView.subviews.forEach { $0.removeFromSuperview() }
    }

    func finishDemonstration() {
        tapGestureRecognizer.isEnabled = false
        clean()
        closeButton.alpha = 0.0
        closeButton.position = nil
        adjust(with: initialPath, animated: true)
        didChangeState?(.loaded)
    }

    // MARK: - Private

    private func configDemonstrationView() {
        let demonstrationView = UIView(frame: view.bounds)
        demonstrationView.backgroundColor = UIColor.clear
        demonstrationView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(demonstrationView)
        self.demonstrationView = demonstrationView
    }

    private func configCloseButton() {
        closeButton.alpha = 0.0
        view.addSubview(closeButton)
        closeButton.sizeToFit()
        closeButton.touchUpInsideHandler = { [weak self] in
            self?.didCancelAction?()
        }
    }

    // MARK: - Orientation

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        coordinator.animate(alongsideTransition: { [unowned self] _ in
            self.clean()
            self.adjust(with: self.emptyPath, animated: false)
        }) { [unowned self] _ in
            self.orientationDidChange(newSize: size)
        }
    }

    // MARK: - Action

    @objc func tapAction() {
        didTapAction?()
    }

    func orientationDidChange(newSize: CGSize) {
        guard let currentOrientation = PassthroughOrientation(UIDevice.current.orientation) else { return }
        guard lastOrientation != currentOrientation || lastSize != newSize else { return }
        didOrientationChange?()
        lastSize = newSize
        lastOrientation = currentOrientation
    }

    // MARK: - CAAnimationDelegate

    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if flag {
            didFinishedAnimation?()
        }
    }
}
