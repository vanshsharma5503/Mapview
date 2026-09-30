//
//  IndianState.swift
//  MapStory
//
//  Created by Vansh Sharma on 30/08/26.
//

import Foundation

struct IndianState: Identifiable, Codable, Hashable {

    let id: String
    let name: String
    let imageName: String
    let puzzleImageName: String
    let coloringImageName: String
    let tagline: String

    let flora: Flora
    let fauna: Fauna
}
