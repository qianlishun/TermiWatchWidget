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

    @AppStorage("WidgetRowHeight", store: UserDefaults(suiteName: "group.com.void.termiWatch"))
    var lastLocation: String = "10.0" {
        didSet{
            print("WidgetRowHeight didset")
        }
    }
    
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
                WidgetCenter.shared.reloadAllTimelines()
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
                WidgetCenter.shared.reloadAllTimelines()
            }
        }
#endif
    }
    
}

#Preview {
    
    VStack{
        Text("100")
        let img = UIImage(named: "100")!

        Image(uiImage: img).frame(width: 100, height: 100, alignment: .center).backgroundStyle(.white).foregroundStyle(.red)

    }
}
