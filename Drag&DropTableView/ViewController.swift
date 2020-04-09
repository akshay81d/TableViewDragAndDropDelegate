//
//  ViewController.swift
//  Drag&DropTableView
//
//  Created by Akshay Dochania on 09/04/20.
//  Copyright © 2020 app-developerz. All rights reserved.
//

import UIKit
import MobileCoreServices

class ViewController: UIViewController {
    //MARK:- Outlets
    @IBOutlet weak var leftTableView: UITableView!
    @IBOutlet weak var rightTableView: UITableView!
    //MARK:- Variables
    var leftItems = [String](repeating: "Left", count: 21)
    var rightItems = [String](repeating: "Right", count: 21)
    
    
//MARK:-View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        initialSetup()
    }


}

extension ViewController {
    func initialSetup() {
        leftTableView.dataSource = self
        leftTableView.dragDelegate = self
        leftTableView.dropDelegate = self
        leftTableView.dragInteractionEnabled = true
        leftTableView.register(UITableViewCell.self, forCellReuseIdentifier: "UITableViewCell")
        
        rightTableView.dataSource = self
        rightTableView.dragDelegate = self
        rightTableView.dropDelegate = self
        rightTableView.dragInteractionEnabled = true
        rightTableView.register(UITableViewCell.self, forCellReuseIdentifier: "UITableViewCell")
        
    }
}

//MARK:- UITableViewDataSource
extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableView == rightTableView ? rightItems.count: leftItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UITableViewCell", for: indexPath)
        cell.textLabel?.text = tableView == rightTableView ? rightItems[indexPath.row]: leftItems[indexPath.row]
        cell.detailTextLabel?.text = "\(indexPath.row)"
        return cell
    }
}

//MARK- UITableViewDragDelegate
extension ViewController: UITableViewDragDelegate {
    func tableView(_ tableView: UITableView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        let text = tableView == rightTableView ? rightItems[indexPath.row]: leftItems[indexPath.row]
        guard let data = text.data(using: .utf8) else {
            return []
        }
        
        let itemProvider = NSItemProvider(item: data as NSData, typeIdentifier: kUTTypePlainText as String)
        return [UIDragItem(itemProvider: itemProvider)]
    }
}

//MARK:- UITableViewDropDelegate
extension ViewController: UITableViewDropDelegate {
    func tableView(_ tableView: UITableView, performDropWith coordinator: UITableViewDropCoordinator) {
        let destinationIndexPath: IndexPath
        if let indexPath = coordinator.destinationIndexPath {
            destinationIndexPath = indexPath
        } else {
            let section = tableView.numberOfSections - 1
            let row = tableView.numberOfRows(inSection: section - 1)
            destinationIndexPath = IndexPath(row: section, section: row)
        }
        
        coordinator.session.loadObjects(ofClass: NSString.self) { (items) in
            // convert the item provider array to a string array
            guard let strings = items as? [String] else {
                return
            }
            
            // create an empty array to track rows we have copied
            var indexPaths = [IndexPath]()
            
            // loop over all the strings we received
            for (index, item) in strings.enumerated() {
                let indexPath = IndexPath(row: destinationIndexPath.row + index, section: destinationIndexPath.section)
                
                // insert the copy into the correct way
                if tableView == self.rightTableView {
                    self.rightItems.insert(item, at: indexPath.row)
                } else {
                    self.leftItems.insert(item, at: indexPath.row)
                }
                // keep track of this new indexPath
                indexPaths.append(indexPath)
            }
            //insert them all into the tableView at once
            tableView.insertRows(at: indexPaths, with: .automatic)
        }
    }
}
