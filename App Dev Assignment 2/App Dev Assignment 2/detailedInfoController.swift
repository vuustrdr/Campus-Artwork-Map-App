//
//  detailedInfoController.swift
//  App Dev Assignment 2
//
//  Created by Dursun Satiroglu on 1/15/21.
//

import UIKit

//A small class that handles info about the artwork
class detailedInfoController: ViewController{
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var artworkTitle: UILabel!
    @IBOutlet weak var dateMade: UILabel!
    @IBOutlet weak var artworkInfo: UITextView!
    @IBOutlet weak var artistLabel: UILabel!
    
    //define vars
    var imageVar: String = ""
    var titleVar: String = ""
    var dateVar: String = ""
    var infoVar: String = ""
    var artistVar: String = ""
    var url: String = ""
    
    
    
    override func viewDidAppear(_ animated: Bool) {
        
        //set up url
        let access = URL(string: url)
        do {
            let data = try Data(contentsOf: access!)
            image.image = UIImage(data: (data))
        } catch _ {
            //do nothing just dont load image 
        }
        
        //set up text boxes and labels
        artworkTitle.text = titleVar
        dateMade.text = dateVar
        artworkInfo.text = infoVar
        artistLabel.text = "By " + artistVar
        
        
    }
    
    
    
    
    
    
}
