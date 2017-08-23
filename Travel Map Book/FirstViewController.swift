//
//  FirstViewController.swift
//  Travel Map Book
//
//  Created by Kornet Project on 17/08/2017.
//  Copyright © 2017 Kornet Project. All rights reserved.
//

import UIKit
import CoreData

class FirstViewController: UIViewController, UITableViewDelegate, UITableViewDataSource
{

    @IBOutlet weak var tableView: UITableView!
    var titleArray = [String]()
    var subtitleArray = [String]()
    var latitudeArray = [Double]()
    var longtitudeArray = [Double]()
    
    var chosenTitle = ""
    var chosenSubtitle = ""
    var chosenLatitude : Double = 0
    var chosenLongitude : Double = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        
        fetchData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(FirstViewController.fetchData), name: NSNotification.Name(rawValue:"newLocationCreated"), object: nil )
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = titleArray[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return titleArray.count
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        chosenTitle = titleArray[indexPath.row]
        chosenSubtitle = subtitleArray[indexPath.row]
        chosenLatitude = latitudeArray[indexPath.row] 
        chosenLongitude = longtitudeArray[indexPath.row]
        
        performSegue(withIdentifier: "toMapVC", sender: nil)
    }
    
    @IBAction func addButtonClicked(_ sender: Any) {
        performSegue(withIdentifier: "toMapVC", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toMapVC"{
            let destinationVC = segue.destination as! ViewController
            destinationVC.transmittedTitle = chosenTitle
            destinationVC.transmittedSubitle = chosenSubtitle
            destinationVC.transmittedLongtitude = chosenLongitude
            destinationVC.transmittedLatitude = chosenLatitude
        }
    }
    
    func fetchData(){
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Locations")
        request.returnsObjectsAsFaults = false
        do {
            let results = try context.fetch(request)
            if results.count > 0{
                self.titleArray.removeAll(keepingCapacity: false)
                self.subtitleArray.removeAll(keepingCapacity: false)
                self.longtitudeArray.removeAll(keepingCapacity: false)
                self.latitudeArray.removeAll(keepingCapacity: false)
                
                
                for result in results as! [NSManagedObject]{
                    if let title = result.value(forKey: "title") as? String{
                        self.titleArray.append(title)
                    }
                    if let subtitle = result.value(forKey: "subtitle") as? String{
                        self.subtitleArray.append(subtitle)
                    }
                    if let latitude = result.value(forKey: "latitude") as? Double{
                        self.latitudeArray.append(latitude)
                    }
                    if let longtitude = result.value(forKey: "longtitude") as? Double{
                        self.longtitudeArray.append(longtitude)
                    }
                    
                    self.tableView.reloadData()
                }
            }
        } catch {
            print("error")
        }
    }

}
