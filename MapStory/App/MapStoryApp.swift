//
//  MapStoryApp.swift
//  MapStory
//
//  Created by Vansh Sharma on 10/07/26.
//

import SwiftUI

@main
struct MapStoryAppApp: App {

    var body: some Scene {

        WindowGroup {

            NavigationStack {
                MainStateView()
            } .preferredColorScheme(.dark)
        }
    }
}
