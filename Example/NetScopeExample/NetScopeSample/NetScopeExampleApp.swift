//
//  NetScopeExampleApp.swift
//  NetScopeExample
//
//  Created by Sai Prasanth Amuluru on 02/03/26.
//

import SwiftUI
import NetScopeCore
import NetScopeURLSession
import NetScopeUI

@main
struct NetScopeExampleApp: App {

    init() {
        #if DEBUG
        NetScopeUniversal.startCapturing()
        #endif
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    #if DEBUG
                    NetScopeController.shared.install()
                    #endif
                }
        }
    }
}
