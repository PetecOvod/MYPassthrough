//
//  PassthroughEntities.h
//  MYPassthrough
//
//  Created by Yaroslav Minaev on 21/09/2017.
//  Copyright © 2017 Yaroslav Minaev All rights reserved.
//

import UIKit

public enum PassthroughState {
    case initialization
    case loaded
    case demonstration
}

public enum HoleType {
    case circle
    case rect(cornerRadius: CGFloat, margin: CGFloat)
}

public enum PassthroughOrientation: Int {
    case any
    case portrait
    case landscape

    init?(_ orientation: UIDeviceOrientation) {
        switch orientation {
        case .landscapeLeft, .landscapeRight:
            self = .landscape
        case .portrait, .portraitUpsideDown:
            self = .portrait
        default:
            return nil
        }
    }
}

public enum ButtonPosition: Equatable {
    case bottomLeft(xMargin: CGFloat, yMargin: CGFloat)
    case bottomRight(xMargin: CGFloat, yMargin: CGFloat)
    case topLeft(xMargin: CGFloat, yMargin: CGFloat)
    case topRight(xMargin: CGFloat, yMargin: CGFloat)

    public static func == (lhs: ButtonPosition, rhs: ButtonPosition) -> Bool {
        switch (lhs, rhs) {
        case (.bottomLeft(let lhsxMargin, let lhsyMargin), .bottomLeft(let rhsxMargin, let rhsyMargin)):
            return lhsxMargin == rhsxMargin && lhsyMargin == rhsyMargin
        case (.bottomRight(let lhsxMargin, let lhsyMargin), .bottomRight(let rhsxMargin, let rhsyMargin)):
            return lhsxMargin == rhsxMargin && lhsyMargin == rhsyMargin
        case (.topLeft(let lhsxMargin, let lhsyMargin), .topLeft(let rhsxMargin, let rhsyMargin)):
            return lhsxMargin == rhsxMargin && lhsyMargin == rhsyMargin
        case (.topRight(let lhsxMargin, let lhsyMargin), .topRight(let rhsxMargin, let rhsyMargin)):
            return lhsxMargin == rhsxMargin && lhsyMargin == rhsyMargin
        default: return false
        }
    }
}

public enum LabelPosition: Int {
    case bottom
    case left
    case right
    case top
}

public enum LabelAligment: Int {
    case left
    case center
    case right
}

protocol HoleLocation: class {
    func frame(forParentView parentView: UIView, inOrientation orientation: UIDeviceOrientation) -> CGRect?
}

public struct PassthroughTask {
    public var holeDescriptors: [HoleDescriptor]
    public var closeButtonPosition: ButtonPosition = .bottomRight(xMargin: 20, yMargin: 20)
    public var infoDescriptor: InfoDescriptor?
    public var didFinishTask: (() -> Void)?
    public var orientationDidChange: (() -> Void)?

    public init(with holeDescriptors: [HoleDescriptor]) {
        self.holeDescriptors = holeDescriptors
    }
}

open class CloseButton: UIButton {
    public var closeButtonPosition: ButtonPosition? {
        return position
    }

    var position: ButtonPosition?
    var touchUpInsideHandler: (() -> Void)?

    public override init(frame: CGRect) {
        super.init(frame: frame)
        addTarget(self, action: #selector(touchUpInsideAction), for: .touchUpInside)
        configureAppearance()
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc func touchUpInsideAction() {
        touchUpInsideHandler?()
    }

    // MARK: - Private

    private func configureAppearance() {
        tintColor = UIColor.white
        titleLabel?.textColor = UIColor.white
        titleLabel?.font = UIFont.systemFont(ofSize: 15)
        setTitle("Label", for: .normal)
    }
}

open class HoleDescriptor: HoleLocation {
    public var labelDescriptor: LabelDescriptor?
    public let type: HoleType
    public let frame: CGRect
    public let orientation: PassthroughOrientation

    public init(frame: CGRect, type: HoleType, forOrientation orientation: PassthroughOrientation) {
        self.frame = frame.integral
        self.type = type
        self.orientation = orientation
    }

    func frame(forParentView parentView: UIView, inOrientation orientation: UIDeviceOrientation) -> CGRect? {
        switch self.orientation {
        case .any:
            return frame
        case .portrait:
            return orientation.isPortrait ? frame : nil
        case .landscape:
            return orientation.isLandscape ? frame : nil
        }
    }
}

open class HoleViewDescriptor: HoleDescriptor {
    public let view: UIView
    public let paddingX: CGFloat
    public let paddingY: CGFloat

    public init(view: UIView, paddingX: CGFloat, paddingY: CGFloat, type: HoleType, forOrientation orientation: PassthroughOrientation) {
        self.view = view
        self.paddingX = paddingX
        self.paddingY = paddingY
        let highlightedFrame = view.frame.insetBy(dx: -paddingX, dy: -paddingY)

        super.init(frame: highlightedFrame, type: type, forOrientation: orientation)
    }

    public convenience init(view: UIView, type: HoleType) {
        self.init(view: view, paddingX: 0, paddingY: 0, type: type, forOrientation: .any)
    }

    public convenience init(view: UIView, type: HoleType, forOrientation orientation: PassthroughOrientation) {
        self.init(view: view, paddingX: 0, paddingY: 0, type: type, forOrientation: orientation)
    }

    override func frame(forParentView parentView: UIView, inOrientation orientation: UIDeviceOrientation) -> CGRect? {
        let convertedFrame = view.superview?.convert(view.frame, to: parentView)
        let highlightedFrame = convertedFrame?.insetBy(dx: -paddingX, dy: -paddingY).integral

        switch self.orientation {
        case .any:
            return highlightedFrame
        case .portrait:
            return orientation.isPortrait ? highlightedFrame : nil
        case .landscape:
            return orientation.isLandscape ? highlightedFrame : nil
        }
    }
}

open class CellViewDescriptor: HoleDescriptor {
    public let indexPath: IndexPath
    public let tableView: UITableView

    public init(tableView: UITableView, indexPath: IndexPath, forOrientation orientation: PassthroughOrientation) {
        self.tableView = tableView
        self.indexPath = indexPath
        let highlightedFrame = tableView.cellForRow(at: indexPath)?.frame ?? CGRect.zero

        super.init(frame: highlightedFrame, type: .rect(cornerRadius: 5, margin: 0), forOrientation: orientation)
    }

    override func frame(forParentView parentView: UIView, inOrientation orientation: UIDeviceOrientation) -> CGRect? {
        guard let cell = tableView.cellForRow(at: indexPath) else { return nil }
        let highlightedFrame = cell.superview?.convert(cell.frame, to: parentView)

        switch self.orientation {
        case .any:
            return highlightedFrame
        case .portrait:
            return orientation.isPortrait ? highlightedFrame : nil
        case .landscape:
            return orientation.isLandscape ? highlightedFrame : nil
        }
    }
}

public enum WidthControl {
    case ratio(CGFloat)
    case precise(CGFloat)
}

open class Descriptor {
    public let label = UILabel(frame: .zero)
    public let text: String
    public var aligment: LabelAligment = .center
    public var widthControl: WidthControl = .ratio(0.7)

    init(for text: String) {
        self.text = text
        initialSetup()
    }

    // MARK: Private

    private func initialSetup() {
        label.backgroundColor = UIColor.clear
        label.textColor = UIColor.white
        label.font = UIFont.systemFont(ofSize: 20)
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 0
        label.textAlignment = .center
    }
}

open class LabelDescriptor: Descriptor {
    public var position: LabelPosition = .bottom
    public var margin: CGFloat = 20

    public override init(for text: String) {
        super.init(for: text)
        PassthroughManager.shared.labelCommonConfigurator?(self)
    }
}

open class InfoDescriptor: Descriptor {
    public var offset = CGPoint.zero

    public override init(for text: String) {
        super.init(for: text)
        PassthroughManager.shared.infoCommonConfigurator?(self)
    }
}

// MARK: - CGFloat Extensions

private extension CGFloat {
    var radians: CGFloat {
        return .pi * (self / 180)
    }
}
