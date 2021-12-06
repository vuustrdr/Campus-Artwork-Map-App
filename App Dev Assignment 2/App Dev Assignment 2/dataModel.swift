//
//  dataModel.swift
//  App Dev Assignment 2
//
//  Created by Dursun Satiroglu on 1/12/21.
//

import Foundation

struct Artwork: Decodable {
    
    let id: String
    let title: String
    let artist: String
    let yearOfWork: String?
    let type: String?
    let Information: String?
    var lat: String
    var long: String
    var location: String
    let locationNotes: String?
    let fileName: String?
    let lastModified: String
    let enabled: String?
}
struct AllArtworks: Decodable {
    let artworks: [Artwork]
}
