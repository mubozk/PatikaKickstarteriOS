//
//  ViewController.swift
//  ListApp
//
//  Created by Sarp Bozkurt on 24.11.2023.
//

import UIKit
import CoreData

class ViewController: UIViewController {
    
    var alertController = UIAlertController()
    @IBOutlet weak var tableView: UITableView!
    
    var data = [NSManagedObject]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        fetch()
    }
    
    @IBAction func removeBarButtonPressed(_ sender: UIBarButtonItem) {
        presentAlert(title: "warning", message: "", defaultButtonTitle: "evet", cancelButtonTitle: "no") { _ in
            self.presentAlert(title: "warning", message: "Are you sure you want to remove all items?", defaultButtonTitle: "Yes", cancelButtonTitle: "No") { _ in
                self.removeAllData()
            }
        }
        
    }
    func removeAllData() {
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        let managedObjectContext = appDelegate?.persistentContainer.viewContext
        
        // Fetch all items in the Core Data entity
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ListItem")
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            // Perform batch delete to remove all items
            try managedObjectContext?.execute(batchDeleteRequest)
            
            // Clear the local data array
            self.data.removeAll()
            
            // Reload the table view
            self.tableView.reloadData()
        } catch {
            print("Error deleting all items: \(error.localizedDescription)")
        }
    }
    
    @IBAction func addBarButtonPressed(_ sender: UIBarButtonItem) {
        presentAddAlert()
    }
    
    
    func presentAddAlert() {
        
        presentAlert(title: "add new item",
                     message: nil,
                     defaultButtonTitle: "add",
                     cancelButtonTitle: "cancel",
                     isTextFieldAvailable: true,
                     defaultButtonHandler: { _ in
            let text = self.alertController.textFields?.first?.text
            if text != "" {
                let appDelegate = UIApplication.shared.delegate as? AppDelegate
                
                let managedObjectContext = appDelegate?.persistentContainer.viewContext
                
                let entity = NSEntityDescription.entity(forEntityName: "ListItem", in: managedObjectContext!)
                
                let listItem = NSManagedObject(entity: entity!, insertInto: managedObjectContext)
                
                listItem.setValue(text, forKey:  "title")
                try? managedObjectContext?.save()
                //                self.data.append(text!)
                //                self.tableView.reloadData()
                self.fetch()
            } else {
                self.presentWarningAlert()
            }
        })
        
        
    }
    
    func presentWarningAlert() {
        presentAlert(title: "warning",
                     message: "list item cant be empty",
                     cancelButtonTitle: "ok")
    }
    
    func presentAlert(title: String?,
                      message: String?,
                      preferredStyle: UIAlertController.Style = .alert,
                      defaultButtonTitle: String? = nil,
                      cancelButtonTitle: String?,
                      isTextFieldAvailable: Bool = false,
                      defaultButtonHandler: ((UIAlertAction) -> Void)? = nil) {
        
        alertController = UIAlertController(title: title, message: message, preferredStyle: preferredStyle)
        
        if defaultButtonTitle != nil {
            let defaultButton = UIAlertAction(title: defaultButtonTitle, style: .default, handler: defaultButtonHandler)
            alertController.addAction(defaultButton)
        }
        
        let cancelButton = UIAlertAction(title: cancelButtonTitle, style: .cancel)
        
        if isTextFieldAvailable {
            alertController.addTextField()
        }
        
        alertController.addAction(cancelButton)
        present(alertController, animated: true)
    }
    func fetch() {
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        let managedObjectContext = appDelegate?.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "ListItem")
        data = try! managedObjectContext!.fetch(fetchRequest)
        tableView.reloadData()
    }
}

extension ViewController:  UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "defaultCell", for: indexPath)
        let listItem = data[indexPath.row ]
        cell.textLabel?.text = listItem.value(forKey: "title") as? String
        return cell
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .normal,
                                              title: "delete") { _, _, _ in
            //            self.data.remove(at: indexPath.row)
            let appDelegate = UIApplication.shared.delegate as? AppDelegate
            
            let managedObjectContext = appDelegate?.persistentContainer.viewContext
            managedObjectContext?.delete(self.data[indexPath.row]  )
            try?  managedObjectContext?.save()
            self.fetch()
            //            tableView.reloadData()
        }
        deleteAction.backgroundColor = .systemRed
        
        let editAction = UIContextualAction(style: .normal, title: "edit") { _, _, _ in
            self.presentAlert(title: "edit item" ,
                              message: "do you want to edit",
                              defaultButtonTitle: "yes",
                              cancelButtonTitle: "no",
                              isTextFieldAvailable: true,
                              defaultButtonHandler: { _ in
                let text = self.alertController.textFields?.first?.text
                if text != "" {
                    //                    self.data[indexPath .row] = text!
                    let appDelegate = UIApplication.shared.delegate as? AppDelegate
                    
                    let managedObjectContext = appDelegate?.persistentContainer.viewContext
                    self.data[indexPath.row].setValue(text, forKey: "title")
                    if managedObjectContext!.hasChanges {
                        try?  managedObjectContext?.save()
                    }
                    self.tableView.reloadData()
                } else {
                    self.presentWarningAlert()
                }
            })
        }
        
        let config = UISwipeActionsConfiguration(actions: [deleteAction, editAction])
        return config
    }
}
