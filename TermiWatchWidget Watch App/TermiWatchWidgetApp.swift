//
//  WatchKitAppApp.swift
//  WatchKitApp Watch App
//
//  Created by Qianlishun on 2023/10/10.
//

import SwiftUI
import WidgetKit

@main
struct TermiWatchWidgetApp: App {
    @Environment(\.scenePhase) private var scenePhase
    @State var viewModel = QTermiViewModel()

    
    var body: some Scene {
        WindowGroup {
            ContentView(viewModel: viewModel)
        }
        
        .onChange(of: scenePhase, initial: true) {
            switch scenePhase {
            case .active:
                print("📲 active")
                viewModel.updateModel()
                WidgetCenter.shared.reloadAllTimelines()
            case .inactive:
                print("📲 inactive")
            case .background:
                print("📲 background")
            @unknown default: break
            }
        }

    }
    
}

#Preview {
    
    VStack{
        Text("100")
        let img = UIImage(named: "100")!

        Image(uiImage: img).frame(width: 100, height: 100, alignment: .center).backgroundStyle(.white).foregroundStyle(.red)

    }
}
