//
//  MessageListApp.swift
//  MessageList
//
//  Created by David Figueroa on 3/06/22.
//

import SwiftUI

@main
struct MessageListApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
