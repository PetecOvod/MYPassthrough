//
//  ThirdViewController.swift
//  iOS Example
//
//  Created by Yaroslav Minaev on 28/08/2018.
//  Copyright © 2018 Minaev.pro. All rights reserved.
//

import UIKit
import MYPassthrough

class ThirdViewController: UIViewController {

    @IBOutlet weak var button: UIButton!
    
    var isNeedСontinueTutorial = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard isNeedСontinueTutorial else { return }
        continueTutorial()
    }
    
    // MARK: Action
    
    @IBAction func closeAction(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: Private
    
    private func continueTutorial() {
        let infoButton = LabelDescriptor(for: "Button description")
        infoButton.position = .top
        let buttonHoleDesc = HoleViewDescriptor(view: button, type: .circle)
        buttonHoleDesc.labelDescriptor = infoButton
        let task = PassthroughTask(with: [buttonHoleDesc])
        
        PassthroughManager.shared.display(tasks: [task]) {
            [weak self] isUserSkipDemo in
            
            self?.isNeedСontinueTutorial = false
            
            print("isUserSkipDemo: \(isUserSkipDemo)")
            if !isUserSkipDemo {
                
                self?.performSegue(withIdentifier: "unwindSegueToFirstViewController", sender: nil)
            }
        }
    }
}
