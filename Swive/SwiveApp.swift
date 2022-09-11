//
//  SwiveApp.swift
//  Swive
//
//  Created by Jonas Mårtensson on 2021-06-09.
//

import SwiftUI

// '@main' denotes the entrypoint for the application
@main struct SwiveApp: App {
    var body: some Scene {
        // The 'some' keyword works similarly to type<T> with the difference
        // being that the implementation (instead of the caller) decides the
        // type (in this case `WindowGroup` which adhears to the Scene
        // protocol)
        WindowGroup {
            ContentView()
        }
    }
}
