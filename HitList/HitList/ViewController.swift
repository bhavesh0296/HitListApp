//
//  ViewController.swift
//  HitList
//
//  Created by bhavesh on 13/06/21.
//  Copyright © 2021 Bhavesh. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController {

    //MARK:-IBOutlets
    @IBOutlet private weak var hitListTableView: UITableView!

    //MARK:- Member Properties
//    var names: [String] = []
    var persons: [NSManagedObject] = []

    //MARK:- Life cycle method
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Hit List"
        hitListTableView.delegate = self
        hitListTableView.dataSource = self
        hitListTableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let people = self.fetch() {
            persons = people
            self.hitListTableView.reloadData()
        }
    }

    //MARK:- IBAction
    @IBAction func addName(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Add Name", message: "Add a new name", preferredStyle: .alert)
        let saveAction = UIAlertAction(title: "Save", style: .default) { [unowned self] (action) in
            guard let textField = alert.textFields?.first,
                let nameToSave = textField.text else {
                    return
            }
//            self.names.append(nameToSave)
            self.save(name: nameToSave)
            self.hitListTableView.reloadData()
        }

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)

        alert.addTextField()

        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: nil)
    }

    fileprivate func save(name: String) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let managedContext = appDelegate.persistentContainer.viewContext

        let entity = NSEntityDescription.entity(forEntityName: "Person", in: managedContext)!

        let person = NSManagedObject(entity: entity, insertInto: managedContext)

        person.setValue(name, forKey: "name")

        do {
            try managedContext.save()
            persons.append(person)
        } catch {
            print(error.localizedDescription)
        }
    }

    fileprivate func fetch() -> [NSManagedObject]? {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return nil }
        let managedContext = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSManagedObject>(entityName: "Person")

        do {
            let people = try managedContext.fetch(request)
            return people
        } catch {
            print(error.localizedDescription)
        }
        return nil
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return names.count
        return persons.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
//        cell.textLabel?.text = names[indexPath.row]
        let person = persons[indexPath.row]
        cell.textLabel?.text = person.value(forKey: "name") as? String ?? ""
        return cell
    }
}
