//
//  PassthroughManager.h
//  MYPassthrough
//
//  Created by Yaroslav Minaev on 21/09/2017.
//  Copyright © 2017 Yaroslav Minaev All rights reserved.
//

import UIKit

open class PassthroughManager {

    public static let shared = PassthroughManager()
    
    public var bottomOffset: CGFloat = 40
    public var topOffset: CGFloat = 40
    public var dimColor = UIColor.black.withAlphaComponent(0.7) {
        didSet {
            passthroughRootController.maskFillColor = dimColor
        }
    }

    public var closeButton: CloseButton {
        return passthroughRootController.closeButton
    }

    public var animationDuration: CFTimeInterval {
        get {
            return passthroughRootController.animationDuration
        }
        set {
            passthroughRootController.animationDuration = newValue
        }
    }

    public var state: PassthroughState {
        return currentState
    }

    public var infoCommonConfigurator: ((InfoDescriptor) -> Void)?
    public var labelCommonConfigurator: ((LabelDescriptor) -> Void)?

    private var mainView: UIView {
        return passthroughRootController.view
    }

    private var demonstrationView: UIView {
        return passthroughRootController.demonstrationView
    }

    private var currentState: PassthroughState = .loaded {
        didSet {
            guard currentState != oldValue else { return }
            switch currentState {
            case .initialization:
                passthroughRootController.setupInitialMask(withColor: dimColor)
            case .loaded:
                break
            case .demonstration:
                passthroughRootController.prepareToDemonstration()
                handleTask(for: currentTaskIndex)
            }
        }
    }

    private let passthroughWindow: UIWindow
    private let passthroughRootController: PassthroughController
    private var tasks: [PassthroughTask] = []
    private var currentTaskIndex: Int = 0
    private var completion: ((Bool) -> Swift.Void)?
    private var isUserCancel: Bool = false

    private init() {
        let passthroughWindow = UIWindow(frame: UIScreen.main.bounds)
        passthroughWindow.backgroundColor = .clear
        passthroughWindow.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        passthroughWindow.windowLevel = .alert
        self.passthroughWindow = passthroughWindow
        passthroughRootController = PassthroughController()

        bindRootController()
    }

    // MARK: - Public

    public func display(tasks: [PassthroughTask], completion: ((Bool) -> Swift.Void)? = nil) {
        guard !tasks.isEmpty else { return }

        passthroughWindow.isHidden = false
        passthroughWindow.rootViewController = passthroughRootController
        passthroughWindow.windowLevel = .normal + 1
        passthroughWindow.rootViewController?.view.frame = passthroughWindow.frame
        self.tasks = tasks
        self.completion = completion
    }

    public func hide() {
        guard currentState == .demonstration else { return }
        isUserCancel = true
        finishDemonstration()
    }

    // MARK: - Private

    private func bindRootController() {
        passthroughRootController.didTapAction = {
            [weak self] in
            guard let sSelf = self else { return }
            sSelf.passthroughRootController.clean()
            sSelf.didFinishTask(at: sSelf.currentTaskIndex)
            sSelf.currentTaskIndex += 1
            sSelf.handleTask(for: sSelf.currentTaskIndex)
        }

        passthroughRootController.didCancelAction = {
            [weak self] in
            guard let sSelf = self else { return }
            sSelf.isUserCancel = true
            sSelf.finishDemonstration()
        }

        passthroughRootController.didOrientationChange = {
            [weak self] in
            guard let sSelf = self else { return }
            guard sSelf.currentState == .demonstration else { return }
            sSelf.closeButton.position = nil
            let task = sSelf.tasks[sSelf.currentTaskIndex]
            task.orientationDidChange?()
            let overlayPath = sSelf.add(task.holeDescriptors, adjustToOrientation: true)
            sSelf.passthroughRootController.adjust(with: overlayPath, animated: false)
            sSelf.handleTask(for: sSelf.currentTaskIndex)
        }

        passthroughRootController.didFinishedAnimation = {
            [weak self] in
            guard let sSelf = self else { return }

            if sSelf.currentState == .loaded {
                sSelf.cleanUp()
            }
        }

        passthroughRootController.didChangeState = {
            [weak self] state in
            self?.currentState = state
        }
    }

    private func handleTask(for index: Int) {
        guard tasks.count > index else {
            finishDemonstration()
            return
        }
        let task = tasks[index]
        let overlayPath = add(task.holeDescriptors)
        calculateClosePosition(for: task)
        calculateLabelPosition(for: task.infoDescriptor)
        updateLabelsPosition()
        passthroughRootController.adjust(with: overlayPath, animated: true)
    }

    private func finishDemonstration() {
        passthroughRootController.finishDemonstration()
    }

    private func cleanUp() {
        passthroughWindow.isHidden = true
        passthroughWindow.rootViewController = nil
        tasks.removeAll()
        currentTaskIndex = 0
        completion?(isUserCancel)
        isUserCancel = false
    }

    private func add(_ holeDescriptors: [HoleDescriptor], adjustToOrientation: Bool = false) -> UIBezierPath {
        let overlayPath = passthroughRootController.emptyPath
        let currentOrientation = UIDevice.current.orientation
        for descriptor in holeDescriptors {
            if var frame = descriptor.frame(forParentView: mainView, inOrientation: currentOrientation) {
                if adjustToOrientation {
                    frame = startAnimatioRect(for: frame)
                }
                var path: UIBezierPath
                switch descriptor.type {
                case .circle:
                    path = UIBezierPath(circumscribedCircleRect: frame)
                case .rect(let cornerRadius, let margin):
                    path = UIBezierPath(roundedRect: frame.insetBy(dx: -margin, dy: -margin).integral, cornerRadius: cornerRadius)
                }
                overlayPath.append(path)

                calculateLabelPosition(for: frame, withlabelDescriptor: descriptor.labelDescriptor)
            }
        }

        return overlayPath
    }

    private func startAnimatioRect(for rect: CGRect) -> CGRect {
        return CGRect(x: rect.midX - 2, y: rect.midY - 2, width: 4, height: 4).integral
    }

    private func didFinishTask(at index: Int) {
        let task = tasks[index]
        task.didFinishTask?()
    }

    private func calculateClosePosition(for task: PassthroughTask) {
        if task.closeButtonPosition != closeButton.position {
            closeButton.alpha = 0.0

            let bounds = mainView.bounds
            var x: CGFloat = 0
            var y: CGFloat = 0

            switch task.closeButtonPosition {
            case .bottomLeft(let xMargin, let yMargin):
                closeButton.position = .bottomLeft(xMargin: xMargin, yMargin: yMargin)
                x = xMargin
                y = bounds.height - yMargin - closeButton.frame.height
            case .bottomRight(let xMargin, let yMargin):
                closeButton.position = .bottomRight(xMargin: xMargin, yMargin: yMargin)
                x = bounds.width - xMargin - closeButton.frame.width
                y = bounds.height - yMargin - closeButton.frame.height
            case .topLeft(let xMargin, let yMargin):
                closeButton.position = .topLeft(xMargin: xMargin, yMargin: yMargin)
                x = xMargin
                y = yMargin
            case .topRight(let xMargin, let yMargin):
                closeButton.position = .topRight(xMargin: xMargin, yMargin: yMargin)
                x = bounds.width - xMargin - closeButton.frame.width
                y = yMargin
            }

            closeButton.frame.origin = CGPoint(x: x, y: y)

            UIView.animate(withDuration: animationDuration) { [weak self] in
                self?.closeButton.alpha = 1.0
            }
        }
    }

    private func configLabel(with descriptor: Descriptor) -> UILabel {
        let bounds = mainView.bounds
        let label = descriptor.label
        demonstrationView.addSubview(label)
        label.alpha = 0.0
        switch descriptor.widthControl {
        case .precise(let value):
            label.frame = CGRect(x: 0, y: 0, width: value, height: 0).integral
        case .ratio(let value):
            label.frame = CGRect(x: 0, y: 0, width: bounds.width * value, height: 0).integral
        }
        label.text = descriptor.text
        label.sizeToFit()

        return label
    }

    private func calculateLabelPosition(for overlayRect: CGRect, withlabelDescriptor labelDescriptor: LabelDescriptor?) {
        guard let labelDescriptor = labelDescriptor else { return }
        let bounds = mainView.bounds
        let label = configLabel(with: labelDescriptor)

        var x: CGFloat = 0
        var y: CGFloat = 0

        switch labelDescriptor.aligment {
        case .right:
            x = bounds.width - label.frame.width - labelDescriptor.margin
        case .center:
            x = (bounds.width - label.frame.width) / 2
        case .left:
            x = labelDescriptor.margin
        }

        switch labelDescriptor.position {
        case .top:
            y = overlayRect.origin.y - label.frame.height - labelDescriptor.margin

            if y < topOffset {
                y = overlayRect.origin.y + overlayRect.height + labelDescriptor.margin
            }
        case .bottom:
            y = overlayRect.origin.y + overlayRect.height + labelDescriptor.margin
            let maxY = y + label.frame.height + bottomOffset
            if maxY > bounds.height {
                y = overlayRect.origin.y - label.frame.height - labelDescriptor.margin
            }
        case .right:
            y = overlayRect.origin.y + overlayRect.height / 2 - label.frame.height / 2
            x = overlayRect.origin.x + overlayRect.width + labelDescriptor.margin
        case .left:
            y = overlayRect.origin.y + overlayRect.height / 2 - label.frame.height / 2
            x = overlayRect.origin.x - label.frame.width - labelDescriptor.margin
        }

        label.frame.origin = CGPoint(x: x, y: y)
    }

    private func calculateLabelPosition(for infoDescriptor: InfoDescriptor?) {
        guard let infoDescriptor = infoDescriptor else { return }
        let bounds = mainView.bounds
        let label = configLabel(with: infoDescriptor)

        var x: CGFloat = 0
        var y: CGFloat = 0

        switch infoDescriptor.aligment {
        case .right:
            x = bounds.width - label.frame.width - infoDescriptor.offset.x
        case .center:
            x = (bounds.width - label.frame.width) / 2
        case .left:
            x = infoDescriptor.offset.x
        }

        y = (bounds.height - label.frame.height) / 2 + infoDescriptor.offset.y

        label.frame.origin = CGPoint(x: x, y: y)
    }

    private func updateLabelsPosition() {
        for view in demonstrationView.subviews {
            UIView.animate(withDuration: animationDuration) { [weak view] in
                view?.alpha = 1.0
            }
        }
    }
}

// MARK: - UIBezierPath Extensions

private extension UIBezierPath {
    convenience init(circumscribedCircleRect rect: CGRect) {
        let halfWidth = rect.width / 2
        let halfHeight = rect.height / 2
        let radius = sqrt(halfWidth * halfWidth + halfHeight * halfHeight)
        let center = CGPoint(x: rect.midX, y: rect.midY)

        self.init(roundedRect: CGRect(x: center.x - radius, y: center.y - radius, width: radius * 2, height: radius * 2).integral, cornerRadius: radius)
    }
}
