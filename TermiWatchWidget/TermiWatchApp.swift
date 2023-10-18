//
//  ViewController.swift
//  TermiWatchWidget
//
//  Created by Qianlishun on 2023/10/10.
//

import SwiftUI

@main
struct TermiWatch: App {
    @Environment(\.scenePhase) private var scenePhase
    @StateObject var viewModel = QTermiViewModel()

    
    let locationMgr = WidgetLocationManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView(viewModel: viewModel)
        }
        

        .onChange(of: scenePhase, initial: true) {
            switch scenePhase {
            case .active:
                print("📲 active")
                viewModel.updateModel()
            case .inactive:
                print("📲 inactive")
            case .background:
                print("📲 background")
            @unknown default: break
            }
        }
    }

    
}

