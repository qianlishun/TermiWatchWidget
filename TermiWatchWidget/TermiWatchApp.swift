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
    @State var viewModel = QTermiViewModel()

    
    let locationMgr = WidgetLocationManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView(viewModel: viewModel)
        }
//  如果这里报错，要兼容iOS17以下，true 修改为 false
//  If an error is reported here, it should be compatible with iOS17 or below, and true should be changed to false
#if true
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
#else
        .onChange(of: scenePhase) { phase in

            if(phase == .active){
                viewModel.updateModel()
            }
        }
#endif

    }

    
}

