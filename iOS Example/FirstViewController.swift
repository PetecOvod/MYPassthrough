//
//  FirstViewController.swift
//  iOS Example
//
//  Created by Yaroslav Minaev on 23/09/2017.
//  Copyright © 2017 Minaev.pro. All rights reserved.
//

import UIKit
import MYPassthrough

class FirstViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var rightView: UIView!
    @IBOutlet weak var leftView: UIView!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        PassthroughManager.shared.labelCommonConfigurator = {
            labelDescriptor in
            
            labelDescriptor.label.font = .systemFont(ofSize: 15)
            labelDescriptor.widthControl = .precise(300)
        }
        
        PassthroughManager.shared.infoCommonConfigurator = {
            infoDescriptor in
            
            infoDescriptor.label.font = .systemFont(ofSize: 15)
            infoDescriptor.widthControl = .precise(300)
        }
        
        PassthroughManager.shared.closeButton.setTitle("Skip", for: .normal)
    }
    
    // MARK: Action
    
    @IBAction func startAction(_ sender: UIButton) {
        startDemonstration()
    }
    
    // MARK: Private
    
    private func startDemonstration() {
        let infoDesc = InfoDescriptor(for: "Welcome to the demo of MYPassthrough. Let's see what it can do. Tap the screen")
        var infoTask = PassthroughTask(with: [])
        infoTask.infoDescriptor = infoDesc
        
        let infoDesc2 = InfoDescriptor(for: "First of all, support rotation. For example...")
        var infoTask2 = PassthroughTask(with: [])
        infoTask2.infoDescriptor = infoDesc2
        
        let rotationTask = createDemoTextPositionBottomTopTask()

        let rightDesc = LabelDescriptor(for: "From right")
        rightDesc.position = .right
        rightDesc.label.textColor = .magenta
        let rightHoleDesc = HoleViewDescriptor(view: leftView, type: .circle)
        rightHoleDesc.labelDescriptor = rightDesc
        
        let leftDesc = LabelDescriptor(for: "From left")
        leftDesc.position = .left
        leftDesc.label.textColor = .green
        let leftHoleDesc = HoleViewDescriptor(view: rightView, type: .circle)
        leftHoleDesc.labelDescriptor = leftDesc
        let rightLeftTask = PassthroughTask(with: [leftHoleDesc, rightHoleDesc])
        
        let handleTask = createDemoHandlersOfTask()
        
        let cellDesc = LabelDescriptor(for: "It also supports working with cells")
        cellDesc.position = .bottom
        let cellHoleDesc = CellViewDescriptor(tableView: tableView, indexPath: IndexPath(row: 0, section: 0), forOrientation: .any)
        var cellTask = PassthroughTask(with: [cellHoleDesc])
        
        cellTask.didFinishTask = {
            guard let tabBarController = self.parent as? UITabBarController else { return }
            
            tabBarController.selectedIndex = 1
        }
        
        let infoDesc3 = InfoDescriptor(for: "Thank you for attention")
        infoDesc3.offset = CGPoint(x: 0, y: -100)
        var infoTask3 = PassthroughTask(with: [])
        infoTask3.infoDescriptor = infoDesc3
        
        PassthroughManager.shared.display(tasks: [infoTask, infoTask2, rotationTask, rightLeftTask, handleTask, cellTask, infoTask3]) {
            isUserSkipDemo in
            
            print("isUserSkipDemo: \(isUserSkipDemo)")
        }
    }
    
    func createDemoTextPositionBottomTopTask() -> PassthroughTask {
        let labelDesc = LabelDescriptor(for: "The text can be from bottom and center in a portrait orientation. Try to rotate.")
        labelDesc.position = .bottom
        let holeDesc = HoleViewDescriptor(view: startButton, type: .rect(cornerRadius: 5, margin: 10), forOrientation: .portrait)
        holeDesc.labelDescriptor = labelDesc
        
        let labelDesc2 = LabelDescriptor(for: "The text can be from top and left in a portrait orientation")
        labelDesc2.position = .top
        labelDesc2.aligment = .left
        let holeDesc2 = HoleViewDescriptor(view: startButton, type: .rect(cornerRadius: 5, margin: 10), forOrientation: .landscape)
        holeDesc2.labelDescriptor = labelDesc2
        
        return PassthroughTask(with: [holeDesc, holeDesc2])
    }
    
    func createDemoHandlersOfTask() -> PassthroughTask {
        let labelDesc = LabelDescriptor(for: "Handlers for turns and end of task are also available")
        labelDesc.position = .bottom
        let holeDesc = HoleViewDescriptor(view: startButton, type: .rect(cornerRadius: 5, margin: 10), forOrientation: .portrait)
        holeDesc.labelDescriptor = labelDesc
        
        let labelDesc2 = LabelDescriptor(for: "Handlers for turns and end of task are also available")
        labelDesc2.position = .top
        labelDesc2.aligment = .left
        let holeDesc2 = HoleViewDescriptor(view: startButton, type: .rect(cornerRadius: 5, margin: 10), forOrientation: .landscape)
        holeDesc2.labelDescriptor = labelDesc2
        
        var task = PassthroughTask(with: [holeDesc, holeDesc2])
        
        task.orientationDidChange = {
            [unowned self] in
            self.startButton.backgroundColor = arc4random_uniform(100) % 2 == 0 ? .red : .green
        }
        
        task.didFinishTask = {
            [unowned self] in
            self.startButton.backgroundColor = #colorLiteral(red: 0.4620226622, green: 0.8382837176, blue: 1, alpha: 1)
        }
        
        return task
    }
    
    // MARK: UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        cell.textLabel?.text = "Name:"
        cell.detailTextLabel?.text = "John"
        
        return cell
    }
}
