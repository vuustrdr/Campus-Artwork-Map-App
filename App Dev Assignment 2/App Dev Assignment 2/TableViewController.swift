//
//  TableViewController.swift
//  App Dev Assignment 2
//
//  Created by Dursun Satiroglu on 1/15/21.
//

import UIKit

//simple class to show artworks in a building
class TableViewController: UITableViewController {
    
    @IBOutlet var table: UITableView!
    
    // title, artist, year, info, url
    var infoTuple: [(String, String, String, String, String)] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.table.tableFooterView = UIView()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    //return the count of the tuple used that holds data
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return infoTuple.count
    }

    //fill table
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tableCell", for: indexPath)
        
        cell.accessoryType = UITableViewCell.AccessoryType.disclosureIndicator
        
        cell.textLabel?.text = infoTuple[indexPath.row].0
        
        cell.detailTextLabel?.text = infoTuple[indexPath.row].1

        // Configure the cell...

        return cell
    }
    
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    //use this to send tuple info into detailed view
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier == "toInfoFromBuilding"{
            
            //find indexpath.row
            let indexpath = tableView.indexPath(for: sender as! UITableViewCell)
            let index = indexpath!.row
            
            let infoVC = segue.destination as! detailedInfoController
            
            infoVC.titleVar = infoTuple[index].0
            infoVC.artistVar = infoTuple[index].1
            infoVC.dateVar = infoTuple[index].2
            infoVC.infoVar = infoTuple[index].3
            infoVC.url = infoTuple[index].4
            
        }
    }
    

}
