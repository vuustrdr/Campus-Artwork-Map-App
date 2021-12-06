//
//  ViewController.swift
//  App Dev Assignment 2
//
//  Dursun Satiroglu
//  ID: 201458316
//
import CoreData
import UIKit
import MapKit
import CoreLocation

//Main view controller class
class ViewController: UIViewController, MKMapViewDelegate, UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate{
    
    //Link outlets
    @IBOutlet weak var map: MKMapView!
    @IBOutlet weak var table: UITableView!
    
    //define class vars
    
    //set up vars used for maps
    var locationManager = CLLocationManager() //used to track location
    var annotation = MKPointAnnotation()
    
    //set up context forr coredata
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var coreDataArray: [Entity] = [] //array of entities (places) from coredata
    var stored: Bool? //to check if any information is stored in coredata
    
    var artworkVar: AllArtworks? = nil //used to access json file
    
    var places = [[String : String]()] //dictionary which holds all places, does bulk of work for holding place attributes
    
    var currentPlace = -1 //used for selecting indexes
    
    var sortedPlaces: [(String?,Double, String?)] = [] //used to organize distance and reorder the table. Sorted places interacts with the tableView, not places var
    
    var given = false //used to set a default location if location is not allowed
    
    var annotationTitle: String?? //used to set annotation title
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        //Set up locationmanager
        locationManager.delegate = self as CLLocationManagerDelegate
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        //Call method to get places from json, fill dicitonary
        
        if places.count > 0{
            places.removeAll()
        }
       
        getPlaces()
        
    
        //Call method to set up maps
        setMap()
    }
    
    //Code for location Manager, called every time location is updated
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]){
        
        
        //set given to true so default location is not used
        given = true
        
        //set up map focus point
        
        let locationOfUser = locations[0] //get the first location (ignore any others)
        let latitude = locationOfUser.coordinate.latitude
        let longitude = locationOfUser.coordinate.longitude
        let latDelta: CLLocationDegrees = 0.002
        let lonDelta: CLLocationDegrees = 0.002
        let span = MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: lonDelta)
        let location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let region = MKCoordinateRegion(center: location, span: span)
        self.map?.setRegion(region, animated: true)
        
        //As user location has changed, reload the table to reorganize it by distance
        table?.reloadData()
        
    }
    
    
    //MARK: Table work =====================================
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //define numberofrows
        //call orderByDistance to get the most up to date ordering of distance in sortedPlaces
        //return count of sortedPlaces to get rows
        orderByDistance()
        return sortedPlaces.count
    }
    
    //set up tablerows
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "theCell", for: indexPath)
        
        orderByDistance() //order sortedPlaces tuple just as the table is set up
        
        cell.accessoryType = UITableViewCell.AccessoryType.disclosureIndicator //customize
        
        
        //display building name as subtitle and artwork as title
        cell.textLabel?.text = sortedPlaces[indexPath.row].0
        cell.detailTextLabel?.text = sortedPlaces[indexPath.row].2
        
        return cell
    }
    
    //deal with taps on rows
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //if tableview is selected perform a segue onto selected place
        currentPlace = indexPath.row
        performSegue(withIdentifier: "toInfo", sender: nil)
    }
    
    //fucntion to update the table
    func updateTheTable() {
        table?.reloadData()
    }
    
    //MARK: Segues=====================================
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //if totable, store information in a tuple, pass it to the tableViewController.
        //this will happen if an annotation is tapped
        if segue.identifier == "toTable"{
            
            //define vars
            var infoTuple: [(String, String, String, String, String)] = []
            let urlStem = "https://cgi.csc.liv.ac.uk/~phil/Teaching/COMP228/artwork_images/" //used for concatenation
            var url = ""
        
            let tvc = segue.destination as! TableViewController
            
            for i in 0..<places.count{
                if places[i]["location"] == annotationTitle{
                
                    url = (places[i]["fileName"]!).replacingOccurrences(of: " ", with: "%20") //create link style
                    url = urlStem + "" + url //concatenate
                    
                    //store in prepared tuple
                    infoTuple.append((places[i]["title"] ?? "",places[i]["artist"] ?? "",places[i]["yearOfWork"] ?? "",places[i]["Information"] ?? "",url))
                    
                }
            }
            //send to tvc from tuple
            for i in 0..<infoTuple.count{
                tvc.infoTuple.append((infoTuple[i].0,infoTuple[i].1,infoTuple[i].2,infoTuple[i].3,infoTuple[i].4))
                
            }
            
        }
        
        //table row selected, provide specific info
        if segue.identifier == "toInfo"{
            
            //define vars
            var info = ""
            var yearOfWork = ""
            var artist = ""
            let urlStem = "https://cgi.csc.liv.ac.uk/~phil/Teaching/COMP228/artwork_images/"
            var url = ""
            var name = ""
            
            
            let detailedVC  = segue.destination as! detailedInfoController
            
            
            for i in 0..<places.count{
                
                
                if places[i]["title"] == sortedPlaces[currentPlace].0{
                    
                    info = places[i]["Information"] ?? ""
                    yearOfWork = places[i]["yearOfWork"] ?? ""
                    artist = places[i]["artist"] ?? ""
                    name = places[i]["title"] ?? ""
                    
                    
                    url = (places[i]["fileName"]!).replacingOccurrences(of: " ", with: "%20")
                    
                    url = urlStem + "" + url
                    
                }
            }
            
            detailedVC.titleVar = name
            detailedVC.infoVar = info
            detailedVC.dateVar = yearOfWork
            detailedVC.artistVar = artist
            detailedVC.url = url
        }
    }
    
    
    //MARK: Map work ================================
    
    //set up the map, only IF location is not given
    func setMap(){
        
        if given == false{
            let latitude:CLLocationDegrees =  53.406566//insert latitutde
            
            let longitude:CLLocationDegrees = -2.966531//insert longitude
            
            let latDelta:CLLocationDegrees = 0.005
            let lonDelta:CLLocationDegrees = 0.005
            
            let span = MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: lonDelta)
            
            let location = CLLocationCoordinate2DMake(latitude, longitude)
            
            let region = MKCoordinateRegion(center: location, span: span)
            
            map?.setRegion(region, animated: true)
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = location
            annotation.title = ""
            map?.addAnnotation(annotation)
        }
    }
    
    //func to add annotations to map
    func addAnnotations(){
        
        
        for index in 0..<places.count{
            //array to store previously added buildings
            var locationAdded: [String] = []
            
            //prevent duplicates from appearing
            if locationAdded.contains(places[index]["location"] ?? ""){
                //do nothing
            }
            else{
                if Int(places[index]["enabled"] ?? "") == 1{
                    
                    //set up annotation
                    let latitude = Double(places[index]["lat"] ?? "")
                    let longitude = Double(places[index]["long"] ?? "")
                    let title = places[index]["location"]
                    
                    let loc = MKPointAnnotation()
                    loc.title = title
                    loc.coordinate = CLLocationCoordinate2D(latitude: latitude ?? 0, longitude: longitude ?? 0)
                    
                    locationAdded.append(places[index]["location"] ?? "")
                    
                    map?.addAnnotation(loc)
                }
            }
        }
    }
    
    //deals with tapping on annotations
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
        annotationTitle = view.annotation?.title
        
        if annotationTitle == ""{
        }else{
            performSegue(withIdentifier: "toTable", sender: nil)
        }
        
    }
    
    //func to order sortedPlaces tuple by its distance attribute
    func orderByDistance(){
        //set up intermediate array
        var placesTArray: [(String?,Double, String?)] = []
        
        //iterate over the dictionary's items, pin to sortedPlaces
        for i in 0..<places.count{
            
            if (places[i]["enabled"]) == "1"{
                let loc1 = CLLocation(latitude: Double(places[i]["lat"] ?? "")!, longitude: Double(places[i]["long"] ?? "")!)
                
                
                let loc2 = locationManager.location
                let loc2spare = CLLocation(latitude: Double(53.406566), longitude:Double(-2.966531)) //if not found location is the ashton building
                
                
                let distance = loc1.distance(from: loc2 ?? loc2spare)
                
                
                
                //organize tuple array by distance
                placesTArray.append((places[i]["title"], Double(distance),places[i]["location"]))
                
                sortedPlaces = placesTArray.sorted(by: { $0.1 < $1.1 })
                
            }
        }
    }
    
    
    
    
    //MARK: Data work =========================================
    
    //this will get data, either using json file or using coreData if jsonfile has already been read.
    func getPlaces(){
    
        //run this method, if entity.count is 0 then stored == false will be returned else the dictionary will be filled
        coreDataFetch()
        
        
        //if no data is found
        if stored == false{
            
            //start session
            if let url = URL(string: "https://cgi.csc.liv.ac.uk/~phil/Teaching/COMP228/artworksOnCampus/data.php?class=artworks&lastModified=2020-12-13") {
                let session = URLSession.shared
                session.dataTask(with: url) { (data, response, err) in
                    guard let jsonData = data else {
                        
                        return
                    }
                    do {
                        let decoder = JSONDecoder()
                        let artList = try decoder.decode(AllArtworks.self, from: jsonData)
                        self.artworkVar = artList
                        DispatchQueue.main.async {
                            //call this to edit anything that has to do with UI
                            self.fillDict()
                            self.addAnnotations()
                            self.updateTheTable()
                        }
                        
                    } catch let jsonErr {
                        print("Error decoding JSON", jsonErr)
                    }
                }.resume()
            }
            
            
        }
        
    }
    
    //called to use json data or core data to fill the places dicitonary.
    func fillDict(){
        
        if places.count > 0{
            
            places.removeAll()
        }
        
        //for loop to fill places
        var index = 0
        while index < ((artworkVar?.artworks.count)!){
            places.append(["id": (artworkVar?.artworks[index].id) ?? "", "title" : (artworkVar?.artworks[index].title) ?? "", "artist": (artworkVar?.artworks[index].artist) ?? "", "yearOfWork": (artworkVar?.artworks[index].yearOfWork) ?? "", "type": (artworkVar?.artworks[index].type) ?? "", "Information": (artworkVar?.artworks[index].Information) ?? "", "lat": (artworkVar?.artworks[index].lat) ?? "", "long": (artworkVar?.artworks[index].long) ?? "","location": (artworkVar?.artworks[index].location) ?? "" , "locationNotes": (artworkVar?.artworks[index].locationNotes) ?? "","fileName": (artworkVar?.artworks[index].fileName) ?? "", "lastModified": (artworkVar?.artworks[index].lastModified) ?? "", "enabled": (artworkVar?.artworks[index].enabled) ?? ""])
            
            index += 1
        }
        
        
        //store inside coredata
        for i in 0..<places.count{
            let newEntity = Entity(context: self.context)
            newEntity.id = places[i]["id"]
            newEntity.title = places[i]["title"]
            newEntity.artist = places[i]["artist"]
            newEntity.yearOfWork = places[i]["yearOfWork"]
            newEntity.type = places[i]["type"]
            newEntity.information = places[i]["Information"]
            newEntity.lat = places[i]["lat"]
            newEntity.long = places[i]["long"]
            newEntity.location = places[i]["location"]
            newEntity.locationNotes = places[i]["locationNotes"]
            newEntity.fileName = places[i]["fileName"]
            newEntity.lastModified = places[i]["lastModified"]
            newEntity.enabled = places[i]["enabled"]
        }
        //save in core data
        do {
            try self.context.save()
            stored = true
        } catch  {
            
        }
        
        
        
    }
        
    //MARK: Core Data Work =================================================
    //fetch method for coredata
    func coreDataFetch(){
        do {
            
            
            self.coreDataArray = try context.fetch(Entity.fetchRequest())
            
            
            if places.count > 0{
                places.removeAll()
            }
            
            //deleteStoredData() //used for testing
            
            for i in 0..<coreDataArray.count {
               //fill dict
                places.append(["id": (coreDataArray[i].id) ?? "", "title" : (coreDataArray[i].title) ?? "", "artist": (coreDataArray[i].artist) ?? "", "yearOfWork": (coreDataArray[i].yearOfWork) ?? "", "type": (coreDataArray[i].type) ?? "", "Information": (coreDataArray[i].information) ?? "", "lat": (coreDataArray[i].lat) ?? "", "long": (coreDataArray[i].long) ?? "","location": (coreDataArray[i].location) ?? "" , "locationNotes": (coreDataArray[i].locationNotes) ?? "","fileName": (coreDataArray[i].fileName) ?? "", "lastModified": (coreDataArray[i].lastModified) ?? "", "enabled": (coreDataArray[i].enabled) ?? ""])
                
            }
            //if count is 0 use json file
            if coreDataArray.count == 0{
                stored = false
            }
            
            DispatchQueue.main.async {
                //since it is background update everything ui here
                self.addAnnotations()
                self.updateTheTable()
            }
            
        }catch{
        }
        
        
        
    }
    //used for testing to remove data and see if json file is used
    func deleteStoredData(){
        for i in 0..<coreDataArray.count{
            self.context.delete(self.coreDataArray[i])
            
        }
        
        do {
            try self.context.save()
        } catch {
            
        }
    }
}

